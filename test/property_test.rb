require "test_helper"

class PropertyTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    property :title

    def title
      super + "</b>"
    end
  end

  let (:song) { Struct.new(:title).new("<b>She Sells And Sand Sandwiches") }
  # ::property creates automatic accessor.
  it { assert_equal "<b>She Sells And Sand Sandwiches</b>", SongCellNew.(song).title }
end

class EscapedPropertyTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    include Escaped
    property :title
    property :artist
    property :copyright, :lyrics

    def title(*)
      "#{super}</b>" # super + "</b>" still escapes, but this is Rails.
    end

    def raw_title
      title(escape: false)
    end
  end

  let (:song) do
    Struct
      .new(:title, :artist, :copyright, :lyrics)
      .new("<b>She Sells And Sand Sandwiches", Object, "<a>Copy</a>", "<i>Words</i>")
  end

  # ::property escapes, everywhere.
  it { assert_equal "&lt;b&gt;She Sells And Sand Sandwiches</b>", SongCellNew.(song).title }
  it { assert_equal "&lt;a&gt;Copy&lt;/a&gt;", SongCellNew.(song).copyright }
  it { assert_equal "&lt;i&gt;Words&lt;/i&gt;", SongCellNew.(song).lyrics }
  # no escaping for non-strings.
  it { assert_equal Object, SongCellNew.(song).artist }
  # no escaping when escape: false
  it { assert_equal "<b>She Sells And Sand Sandwiches</b>", SongCellNew.(song).raw_title }
end
