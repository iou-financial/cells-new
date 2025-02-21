require 'test_helper'

class TestCaseTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    def show
      "Give It All!"
    end
  end

  class Song
    class CellNew < CellNew::Concept
    end
  end

  let (:song) { Object.new }

  # #cell_new returns the instance
  describe "#cell_new" do
    subject { cell_new("test_case_test/song", song) }

    it { assert_instance_of SongCellNew, subject }
    it { assert_equal song, subject.model }

    it { assert_equal "Give It All!Give It All!", cell_new("test_case_test/song", collection: [song, song]).() }
  end

  describe "#concept" do
    subject { concept("test_case_test/song/cell_new", song) }

    it { assert_instance_of Song::CellNew, subject }
    it { assert_equal song, subject.model }
  end
end

# capybara support
require "capybara"

class CapybaraTest < Minitest::Spec
  class CapybaraCellNew < CellNew::ViewModel
    def show
      "<b>Grunt</b>"
    end
  end

  describe "capybara support" do
    subject { cell_new("capybara_test/capybara", nil) }

    before { CellNew::Testing.capybara = true  } # yes, a global switch!
    after  { CellNew::Testing.capybara = false }

    it { assert subject.(:show).has_selector?('b') }
    it { assert cell_new("capybara_test/capybara", collection: [1, 2]).().has_selector?('b') }

    # FIXME: this kinda sucks, what if you want the string in a Capybara environment?
    it { assert_match "<b>Grunt</b>", subject.(:show).to_s }
  end
end
