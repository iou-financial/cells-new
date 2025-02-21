require 'test_helper'

class SongWithLayoutCellNew < CellNew::ViewModel
  self.view_paths = ['test/fixtures']
  # include CellNew::Erb

  def show
    render layout: :merry
  end

  def unknown
    render layout: :no_idea_what_u_mean
  end

  def what
    "Xmas"
  end

  def string
    "Right"
  end

private
  def title
    "<b>Papertiger</b>"
  end
end

class SongWithLayoutOnClassCellNew < SongWithLayoutCellNew
  # inherit_views SongWithLayoutCellNew
  layout :merry

  def show
    render
  end

  def show_with_layout
    render layout: :happy
  end
end

class LayoutTest < Minitest::Spec
  # render show.haml calling method.
  # same context as content view as layout call method.
  it { assert_equal "Merry Xmas, <b>Papertiger</b>\n", SongWithLayoutCellNew.new(nil).show }

  # raises exception when layout not found!
  it { assert_raises(CellNew::TemplateMissingError) { SongWithLayoutCellNew.new(nil).unknown } }

  # with ::layout.
  it { assert_equal "Merry Xmas, <b>Papertiger</b>\n", SongWithLayoutOnClassCellNew.new(nil).show }

  # with ::layout and :layout, :layout wins.
  it { assert_equal "Happy Friday!", SongWithLayoutOnClassCellNew.new(nil).show_with_layout }
end

module Comment
  class ShowCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures']
    include Layout::External

    def show
      render + render
    end
  end

  class LayoutCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures']
  end
end

class ExternalLayoutTest < Minitest::Spec
  it do
    result = Comment::ShowCellNew.new(nil, layout: Comment::LayoutCellNew, context: { beer: true }).()

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
      assert_equal "$layout.erb{$show.erb, {:beer=>true}\n$show.erb, {:beer=>true}\n, {:beer=>true}}\n", result
    else
      assert_equal "$layout.erb{$show.erb, {beer: true}\n$show.erb, {beer: true}\n, {beer: true}}\n", result
    end
  end

  # collection :layout
  it do
    result = CellNew::ViewModel.cell_new("comment/show", collection: [Object, Module], layout: Comment::LayoutCellNew).()
    assert_equal "$layout.erb{$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n$show.erb, nil\n, nil}\n", result
  end
end
