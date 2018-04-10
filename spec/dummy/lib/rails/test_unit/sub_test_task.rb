# monkey patch deprecated `sub_test_task`
require 'rake/testtask'
class Rails::SubTestTask < Rake::TestTask
end
