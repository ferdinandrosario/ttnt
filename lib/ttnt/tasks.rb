require 'rake/testtask'
require 'rake/file_list'
require 'ttnt/testtask'

# https://github.com/bundler/bundler/blob/master/lib/bundler/gem_helper.rb
module TTNT
  class TaskHelper
    include Rake::DSL if defined? Rake::DSL

    def self.install_tasks
      new.install
    end

    def install
      namespace :ttnt do
        desc 'Generate test-to-code mapping for current commit object'
        task 'anchor' do
          # TODO: what if multiple test tasks are defined?
          test_task = TTNT::TestTask.instances.first
          test_files = []
          test_files += test_task.test_files.to_a if test_task.test_files
          test_files += Rake::FileList[test_task.pattern] if test_task.pattern

          # TODO: properly regard run options defined for Rake::TestTask
          gem_root = File.expand_path('..', File.dirname(File.expand_path(__FILE__)))
          args = "-I#{gem_root} -r ttnt/anchor"
          args += " -I#{test_task.libs.join(':')}" unless test_task.libs.empty?
          test_files.each do |test_file|
            ruby "#{args} #{test_file}"
          end
        end
      end
    end
  end
end

TTNT::TaskHelper.install_tasks
