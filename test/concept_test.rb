require 'test_helper'

CellNew::Concept.class_eval do
  self.view_paths = ['test/fixtures/concepts']
end

# Trailblazer style:
module Record
  class CellNew < ::CellNew::Concept # cell_new("record")
    include ::Cell::Erb

    def show
      render # Party On, #{model}
    end

    # cell_new(:song, concept: :record)
    class Song < self # cell_new("record/cell_new/song")
      def show
        render view: :song#, layout: "layout"
        # TODO: test layout: .. in ViewModel
      end
    end

    class Hit < ::CellNew::Concept
      inherit_views Record::CellNew
    end

    def description
      "A Tribute To Rancid, with #{@options[:tracks]} songs! [#{context}]"
    end
  end
end

module Record
  module CellNews
    class CellNew < ::CellNew::Concept
      class Song < ::CellNew::Concept
      end
    end
  end
end

class ConceptTest < Minitest::Spec
  describe "::controller_path" do
    it { assert_equal "record", Record::CellNew.new.class.controller_path }
    it { assert_equal "record/song", Record::CellNew::Song.new.class.controller_path }
    it { assert_equal "record/cell_news", Record::CellNews::CellNew.new.class.controller_path }
    it { assert_equal "record/cell_news/song", Record::CellNews::CellNew::Song.new.class.controller_path }
  end

  describe "#_prefixes" do
    it { assert_equal ["test/fixtures/concepts/record/views"], Record::CellNew.new._prefixes }
    it { assert_equal ["test/fixtures/concepts/record/song/views", "test/fixtures/concepts/record/views"], Record::CellNew::Song.new._prefixes }
    it { assert_equal ["test/fixtures/concepts/record/hit/views", "test/fixtures/concepts/record/views"], Record::CellNew::Hit.new._prefixes } # with inherit_views.
  end

  it { assert_equal "Party on, Wayne!", Record::CellNew.new("Wayne").call(:show) }

  describe "::cell_new" do
    it { assert_instance_of Record::CellNew, CellNew::Concept.cell_new("record/cell_new") }
    it { assert_instance_of Record::CellNew::Song, CellNew::Concept.cell_new("record/cell_new/song") }
  end

  describe "#render" do
    it { assert_equal "Lalala", CellNew::Concept.cell_new("record/cell_new/song").show }
  end

  describe "#cell_new (in state)" do
    it { assert_instance_of Record::CellNew, CellNew::Concept.cell_new("record/cell_new", nil, context: { controller: Object }).cell_new("record/cell_new", nil) }
    it do
      result = CellNew::Concept.cell_new("record/cell_new", nil, context: { controller: Object }).concept("record/cell_new", nil, tracks: 24).(:description)

      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
        assert_equal "A Tribute To Rancid, with 24 songs! [{:controller=>Object}]", result
      else
        assert_equal "A Tribute To Rancid, with 24 songs! [{controller: Object}]", result
      end
    end

    it do
      result = CellNew::Concept.cell_new("record/cell_new", nil, context: { controller: Object }).concept("record/cell_new", collection: [1,2], tracks: 24).(:description)

      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
        assert_equal "A Tribute To Rancid, with 24 songs! [{:controller=>Object}]A Tribute To Rancid, with 24 songs! [{:controller=>Object}]", result
      else
        assert_equal "A Tribute To Rancid, with 24 songs! [{controller: Object}]A Tribute To Rancid, with 24 songs! [{controller: Object}]", result
      end
    end
  end
end
