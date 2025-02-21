require 'test_helper'

class PublicTest < Minitest::Spec
  class SongCellNew < CellNew::ViewModel
    def initialize(*args)
      @initialize_args = *args
    end
    attr_reader :initialize_args

    def show
      initialize_args.inspect
    end

    def detail
      "* #{initialize_args}"
    end
  end

  class Songs < CellNew::Concept
  end

  # ViewModel.cell_new returns the cell_new instance.
  it { assert_instance_of SongCellNew, CellNew::ViewModel.cell_new("public_test/song") }
  it { assert_instance_of SongCellNew, CellNew::ViewModel.cell_new(PublicTest::SongCellNew) }

  # Concept.cell_new simply camelizes the string before constantizing.
  it { assert_instance_of Songs, CellNew::Concept.cell_new("public_test/songs") }
  it { assert_instance_of Songs, CellNew::Concept.cell_new(PublicTest::Songs) }

  # ViewModel.cell_new passes options to cell_new.
  it { assert_equal [Object, {genre:"Metal"}], CellNew::ViewModel.cell_new("public_test/song", Object, genre: "Metal").initialize_args }

  # ViewModel.cell_new(collection: []) renders cell_news.
  it { assert_equal '[Object, {}][Module, {}]', CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).to_s }

  # DISCUSS: should cell_new.() be the default?
  # ViewModel.cell_new(collection: []) renders cell_news with custom join.
  it do
    Gem::Deprecate::skip_during do
      result = CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).join('<br/>') do |cell_new|
        cell_new.()
      end
      assert_equal '[Object, {}]<br/>[Module, {}]', result
    end
  end

  # ViewModel.cell_new(collection: []) passes generic options to cell_new.
  it do
    result = CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module], genre: 'Metal', context: { ready: true }).to_s

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
      assert_equal "[Object, {:genre=>\"Metal\", :context=>{:ready=>true}}][Module, {:genre=>\"Metal\", :context=>{:ready=>true}}]", result
    else
      assert_equal "[Object, {genre: \"Metal\", context: {ready: true}}][Module, {genre: \"Metal\", context: {ready: true}}]", result
    end
  end

  # ViewModel.cell_new(collection: [], method: :detail) invokes #detail instead of #show.
  # TODO: remove in 5.0.
  it do
    Gem::Deprecate::skip_during do
      assert_equal '* [Object, {}]* [Module, {}]', CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module], method: :detail).to_s
    end
  end

  # ViewModel.cell_new(collection: []).() invokes #show.
  it { assert_equal '[Object, {}][Module, {}]', CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).() }

  # ViewModel.cell_new(collection: []).(:detail) invokes #detail instead of #show.
  it { assert_equal '* [Object, {}]* [Module, {}]', CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).(:detail) }

  # #cell_new(collection: [], genre: "Fusion").() doesn't change options hash.
  it do
    options = { genre: "Fusion", collection: [Object] }
    CellNew::ViewModel.cell_new("public_test/song", options).()

    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.4.0')
      assert_equal "{:genre=>\"Fusion\", :collection=>[Object]}", options.to_s
    else
      assert_equal "{genre: \"Fusion\", collection: [Object]}", options.to_s
    end
  end

  # cell_new(collection: []).join captures return value and joins it for you.
  it do
    result = CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).join do |cell_new, i|
      i == 1 ? cell_new.(:detail) : cell_new.()
    end
    assert_equal '[Object, {}]* [Module, {}]', result
  end

  # cell_new(collection: []).join("<") captures return value and joins it for you with join.
  it do
    result = CellNew::ViewModel.cell_new("public_test/song", collection: [Object, Module]).join(">") do |cell_new, i|
      i == 1 ? cell_new.(:detail) : cell_new.()
    end
    assert_equal '[Object, {}]>* [Module, {}]', result
  end

  # 'join' can be used without a block:
  it do
    assert_equal '[Object, {}]---[Module, {}]', CellNew::ViewModel.cell_new(
      "public_test/song", collection: [Object, Module]
    ).join('---')
  end
end
