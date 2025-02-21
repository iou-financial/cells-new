require 'test_helper'

class BassistCellNew::FenderCellNew < CellNew::ViewModel
end

class BassistCellNew::IbanezCellNew < BassistCellNew
end

class WannabeCellNew < BassistCellNew::IbanezCellNew
end

# engine: shopify
# shopify/cart/cell_new

class EngineCellNew < CellNew::ViewModel
  self.view_paths << "/var/engine/app/cell_news"
end
class InheritingFromEngineCellNew < EngineCellNew
end

class PrefixesTest < Minitest::Spec
  class SingerCellNew < CellNew::ViewModel
  end

  class BackgroundVocalsCellNew < SingerCellNew
  end

  class ChorusCellNew < BackgroundVocalsCellNew
  end

  class GuitaristCellNew < SingerCellNew
    def self._local_prefixes
      ["stringer"]
    end
  end

  class BassistCellNew < SingerCellNew
    def self._local_prefixes
      super + ["basser"]
    end
  end

  describe "::controller_path" do
    it { assert_equal "bassist", ::BassistCellNew.new(@controller).class.controller_path }
    it { assert_equal "prefixes_test/singer", SingerCellNew.new(@controller).class.controller_path }
  end

  describe "#_prefixes" do
    it { assert_equal ["test/fixtures/bassist"], ::BassistCellNew.new(@controller)._prefixes }
    it { assert_equal ["app/cell_news/bassist_cell_new/fender"], ::BassistCellNew::FenderCellNew.new(@controller)._prefixes }
    it { assert_equal ["test/fixtures/bassist_cell_new/ibanez", "test/fixtures/bassist"], ::BassistCellNew::IbanezCellNew.new(@controller)._prefixes }

    it { assert_equal ["app/cell_news/prefixes_test/singer"], SingerCellNew.new(@controller)._prefixes }
    it { assert_equal ["app/cell_news/prefixes_test/background_vocals", "app/cell_news/prefixes_test/singer"], BackgroundVocalsCellNew.new(@controller)._prefixes }
    it { assert_equal ["app/cell_news/prefixes_test/chorus", "app/cell_news/prefixes_test/background_vocals", "app/cell_news/prefixes_test/singer"], ChorusCellNew.new(@controller)._prefixes }

    it { assert_equal ["stringer", "app/cell_news/prefixes_test/singer"], GuitaristCellNew.new(@controller)._prefixes }
    it { assert_equal ["app/cell_news/prefixes_test/bassist", "basser", "app/cell_news/prefixes_test/singer"], BassistCellNew.new(@controller)._prefixes }

    # multiple view_paths.
    it { assert_equal ["app/cell_news/engine", "/var/engine/app/cell_news/engine"], EngineCellNew.prefixes }
    it do
      expected = [
        "app/cell_news/inheriting_from_engine", "/var/engine/app/cell_news/inheriting_from_engine",
        "app/cell_news/engine", "/var/engine/app/cell_news/engine"
      ]
      assert_equal expected, InheritingFromEngineCellNew.prefixes
    end

    # ::_prefixes is cached.
    it do
      assert_equal ["test/fixtures/wannabe", "test/fixtures/bassist_cell_new/ibanez", "test/fixtures/bassist"], WannabeCellNew.prefixes
      WannabeCellNew.instance_eval { def _local_prefixes; ["more"] end }
      # _prefixes is cached.
      assert_equal ["test/fixtures/wannabe", "test/fixtures/bassist_cell_new/ibanez", "test/fixtures/bassist"], WannabeCellNew.prefixes
      # superclasses don't get disturbed.
      assert_equal ["test/fixtures/bassist"], ::BassistCellNew.prefixes
    end
  end
end

class InheritViewsTest < Minitest::Spec
  class SlapperCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures'] # todo: REMOVE!
    include Cell::Erb

    inherit_views ::BassistCellNew

    def play
      render
    end
  end

  class FunkerCellNew < SlapperCellNew
  end

  it { assert_equal ["test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"], SlapperCellNew.new(nil)._prefixes }
  it { assert_equal ["test/fixtures/inherit_views_test/funker", "test/fixtures/inherit_views_test/slapper", "test/fixtures/bassist"], FunkerCellNew.new(nil)._prefixes }

  # test if normal cell_news inherit views.
  it { assert_equal 'Doo', cell_new('inherit_views_test/slapper').play }
  it { assert_equal 'Doo', cell_new('inherit_views_test/funker').play }

  # TapperCellNew
  class TapperCellNew < CellNew::ViewModel
    self.view_paths = ['test/fixtures']
    # include Cell::Erb

    def play
      render
    end

    def tap
      render
    end
  end

  class PopperCellNew < TapperCellNew
  end

  # Tapper renders its play
  it { assert_equal 'Dooom!', cell_new('inherit_views_test/tapper').call(:play) }
  # Tapper renders its tap
  it { assert_equal 'Tap tap tap!', cell_new('inherit_views_test/tapper').call(:tap) }

  # Popper renders Tapper's play
  it { assert_equal 'Dooom!', cell_new('inherit_views_test/popper').call(:play) }
  #  Popper renders its tap
  it { assert_equal "TTttttap I'm not good enough!", cell_new('inherit_views_test/popper').call(:tap) }
end
