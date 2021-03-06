require 'test_helper'
require 'ttnt/task_helper'

class TasksTest < Minitest::Test
  def test_define_rake_tasks
    TTNT::TaskHelper.define_tasks
    assert Rake::Task.task_defined?('ttnt:anchor'),
      '`ttnt:anchor` task should be defined'
    assert Rake::Task.task_defined?('ttnt:test'),
      '`ttnt:test` task should be defined'
  end
end
