require 'set'
require 'rugged'
require_relative './test_to_code_mapping'

module TTNT
  class TestSelector
    def initialize(repo, target_sha, base_sha)
      @repo = repo
      @target_obj = @repo.lookup(target_sha)

      # Base should be the commit `ttnt:anchor` has run on.
      # NOT the one test-to-code mapping was commited to.
      ttnt_tree = @repo.lookup(@repo.lookup(base_sha).tree['.ttnt'][:oid])
      base_sha = @repo.lookup(ttnt_tree['commit_obj.txt'][:oid]).content
      @base_obj = @repo.lookup(base_sha)
    end

    def select_tests
      tests = Set.new
      mapping = TTNT::TestToCodeMapping.new(@repo, @base_obj.oid)
      # TODO: if mapping is not found (ttnt-anchor has not been run)

      diff = @base_obj.diff(@target_obj)
      diff.each_patch do |patch|
        file = patch.delta.old_file[:path]
        patch.each_hunk do |hunk|
          # TODO: think if this selection covers all possibilities
          hunk.each_line do |line|
            case line.line_origin
            when :addition
              # FIXME: new_lineno is suspicious
              #        (what if hunk1 adds 100 lines and hunk2 add 1 line?)
              tests += mapping.get_tests(file: file, lineno: line.new_lineno)
            when :deletion
              tests += mapping.get_tests(file: file, lineno: line.old_lineno)
            else
              # do nothing
            end
          end
        end
      end
      tests.delete(nil)
    end
  end
end
