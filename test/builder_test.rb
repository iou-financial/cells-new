require 'test_helper'

class BuilderTest < Minitest::Spec
  Song = Struct.new(:title)
  Hit  = Struct.new(:title)

  class SongCellNew < CellNew::ViewModel
    include CellNew::Builder

    builds do |model, options|
      if model.is_a? Hit
        HitCellNew
      elsif options[:evergreen]
        EvergreenCellNew
      end
    end

    def options
      @options
    end

    def show
      "* #{title}"
    end

    property :title
  end

  class HitCellNew < SongCellNew
    def show
      "* **#{title}**"
    end
  end

  class EvergreenCellNew < SongCellNew
  end

  # the original class is used when no builder matches.
  it { assert_instance_of SongCellNew, SongCellNew.(Song.new("Nation States"), {}) }

  it do
    cell_new = SongCellNew.(Hit.new("New York"), {})
    assert_instance_of HitCellNew, cell_new
    assert_equal({}, cell_new.options)
  end

  it do
    cell_new = SongCellNew.(Song.new("San Francisco"), evergreen: true)
    assert_instance_of EvergreenCellNew, cell_new
    assert_equal({evergreen: true}, cell_new.options)
  end

  # without arguments.
  it { assert_instance_of HitCellNew, SongCellNew.(Hit.new("Frenzy")) }

  # with collection.
  it { assert_equal "* Nation States* **New York**", SongCellNew.(collection: [Song.new("Nation States"), Hit.new("New York")]).() }

  # with Concept
  class Track < CellNew::Concept
  end
  it { assert_instance_of Track, Track.() }
end
