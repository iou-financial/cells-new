require 'test_helper'

class CellNewTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures']

    def show
    end

    def show_with_block(&block)
      render(&block)
    end
  end

  # #options
  it { assert_equal "Punkrock", SongCellNew.new(nil, genre: "Punkrock").send(:options)[:genre] }

  # #block
  it { assert_equal "<b>hello</b>\n", SongCellNew.new(nil, genre: "Punkrock").(:show_with_block) { "hello" } }
end
