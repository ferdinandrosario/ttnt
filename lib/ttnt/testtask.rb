require 'rugged'
require 'rake/testtask'
require 'ttnt/test_selector'

module TTNT
  class TestTask < Rake::TestTask
    def initialize(rake_test_task)
      copy_instance_variables(rake_test_task, self)
      # Since test_files is not exposed in Rake::TestTask
      @test_files = rake_test_task.instance_variable_get('@test_files')
      self.class.class_eval('attr_accessor :test_files')

      @anchor_description = 'Generate test-to-code mapping' + (@name == :test ? '' : " for #{@name}")
      @run_description = 'Run selected tests' + (@name == :test ? '' : "for #{@name}")
      define_tasks
    end

    private

    # Task definitions are taken from Rake::TestTask
    # https://github.com/ruby/rake/blob/e644af3/lib/rake/testtask.rb#L98-L112
    def define_tasks
      namespace :ttnt do
        namespace @name do
          define_run_task
          define_anchor_task
        end
      end
    end

    def define_run_task
      desc @run_description
      task 'run' do
        repo = Rugged::Repository.discover('.')
        target_sha = ENV['TARGET_SHA'] || repo.head.target_id
        base_sha = ENV['BASE_SHA'] || repo.merge_base(target_sha, repo.rev_parse('master'))
        ts = TTNT::TestSelector.new(repo, target_sha, base_sha)
        selected_tests = ts.select_tests.select { |f| File.exist?(f) }.to_a
        if selected_tests.empty?
          STDERR.puts 'No test selected.'
          exit
        end

        runner_name = "temporary_#{self.name}_runner"
        Rake::TestTask.new do |t|
          copy_instance_variables(self, t)
          t.name = runner_name
          t.test_files = selected_tests
          t.pattern = nil
        end
        Rake::Task[runner_name].invoke
      end
    end

    def define_anchor_task
      desc @anchor_description
      task 'anchor' do
        Rake::FileUtilsExt.verbose(@verbose) do
          args = "#{ruby_opts_string} #{option_list} -r ttnt/anchor"

          # FIXME: For some reason needs this $LOAD_PATH injection...
          gem_root = File.expand_path('../..', __FILE__)
          args += " -I#{gem_root}"

          # Since Rake::TestTask#file_list does not glob @pattern
          test_files = file_list.map { |fn| Rake::FileList[fn] }.flatten.uniq
          test_files.each do |test_file|
            ruby "#{args} #{test_file}" do |ok, status|
              if !ok && status.respond_to?(:signaled?) && status.signaled?
                raise SignalException.new(status.termsig)
              elsif !ok
                fail "Command failed with status (#{status.exitstatus}): " +
                  "[ruby #{args}]"
              end
            end
          end
        end
      end
    end

    def copy_instance_variables(src, dest)
      ivars = src.instance_variables
      ivars.map! { |ivar| ivar[1..-1] }

      ivars.each do |ivar|
        if dest.respond_to?(:"#{ivar}=") && src.respond_to?(:"#{ivar}")
          dest.send(:"#{ivar}=", src.send(:"#{ivar}"))
        end
      end
    end
  end
end
