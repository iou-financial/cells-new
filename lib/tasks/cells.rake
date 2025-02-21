require "rake/testtask"

namespace "test" do
  Rake::TestTask.new(:cell_news) do |t|
    t.libs << "test"
    t.pattern = 'test/cell_news/**/*_test.rb'
  end
end
