require 'test_helper'

class TemplatesTest < Minitest::Spec
  Templates = CellNew::Templates

  # existing.
  it { assert_equal 'test/fixtures/bassist/play.erb', Templates.new[['test/fixtures/bassist'], 'play.erb', {template_class: Cell::Erb::Template}].file }

  # not existing.
  it { assert_nil(Templates.new[['test/fixtures/bassist'], 'not-here.erb', {}]) }
end

class TemplatesCachingTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures']
    # include CellNew::Erb

    def show
      render
    end
  end

  # templates are cached once and forever.
  it do
    cell_new = cell_new("templates_caching_test/song")

    assert_equal 'The Great Mind Eraser', cell_new.call(:show)

    SongCellNew.templates.instance_eval do
      def create; raise; end
    end

    # cached, NO new tilt template.
    assert_equal 'The Great Mind Eraser', cell_new.call(:show)
  end
end
