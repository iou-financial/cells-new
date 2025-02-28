require 'test_helper'

class SongCellNew < CellNew::ViewModel
  self.view_paths = ['test/fixtures']
  # include ::CellNew::Erb

  def show
    render
  end

  def ivar
    @title = "Carnage"
    render
  end

  def unknown
    render
  end

  def string
    "Right"
  end

  def with_locals
    render locals: {length: 280, title: "Shot Across The Bow"}
  end

  def with_erb
    render template_engine: :erb
  end

  def with_view_name
    @title = "Man Of Steel"
    render :ivar
  end

  def receiving_options(layout=:default)
    "#{layout}"
  end

  def with_html
    render
  end

  def send
    "send"
  end

  def with_block
    render { "Clean Sheets" + render(:with_html) }
  end

  def with_options(options)
    @title = options[:title]
    render
  end

private
  def title
    "Papertiger"
  end
end

class RenderTest < Minitest::Spec
  # render show.haml calling method, implicit render.
  it { assert_equal "Papertiger\n", SongCellNew.new(nil).show }

  # render ivar.haml using instance variable.
  it { assert_equal "Carnage\n", SongCellNew.new(nil).ivar }

  # render string.
  it { assert_equal "Right", SongCellNew.new(nil).string }

  # #call renders :show
  it { assert_equal "Papertiger\n", SongCellNew.new(nil).call }

  # call(:form) renders :form
  it { assert_equal "Man Of Steel\n", SongCellNew.new(nil).call(:with_view_name) }

  # works with state called `send`
  it { assert_equal "send", SongCellNew.new(nil).call(:send) }

  # throws an exception when not found.
  it do
    exception = assert_raises(CellNew::TemplateMissingError) { SongCellNew.new(nil).unknown }
    assert_equal "Template missing: view: `unknown.erb` prefixes: [\"test/fixtures/song\"]", exception.message
  end

  # allows locals
  it { assert_equal "Shot Across The Bow\n280\n", SongCellNew.new(nil).with_locals }

  # render :form is a shortcut.
  it { assert_equal "Man Of Steel\n", SongCellNew.new(nil).with_view_name }

  # allows passing in options DISCUSS: how to handle that in cache block/builder?
  it { assert_equal "default", SongCellNew.new(nil).receiving_options }
  it { assert_equal "fancy", SongCellNew.new(nil).receiving_options(:fancy) }
  it { assert_equal "fancy", SongCellNew.new(nil).call(:receiving_options, :fancy) }
  it { assert_equal "A new song\n", SongCellNew.new(nil).call(:with_options, title: 'A new song') }

  # doesn't escape HTML.
  it { assert_equal "<p>Yew!</p>", SongCellNew.new(nil).call(:with_html) }

  # render {} with block
  it { assert_equal "Yo! Clean Sheets<p>Yew!</p>\n", SongCellNew.new(nil).with_block }
end
