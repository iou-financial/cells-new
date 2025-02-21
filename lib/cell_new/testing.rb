require "uber/inheritable_attr"

module CellNew
  # Builder methods and Capybara support.
  # This gets included into Test::Unit, MiniTest::Spec, etc.
  module Testing
    def cell_new(name, *args)
      cell_new_for(ViewModel, name, *args)
    end

    def concept(name, *args)
      cell_new_for(Concept, name, *args)
    end

  private
    def cell_new_for(baseclass, name, model=nil, options={})
      options[:context] ||= {}
      options[:context][:controller] = controller

      cell_new = baseclass.cell_new(name, model, options)

      cell_new.extend(Capybara) if CellNew::Testing.capybara? # leaving this here as most people use Capybara.
      # apparently it's ok to only override ViewModel#call and capybararize the result.
      # when joining in a Collection, the joint will still be capybararized.
      cell_new
    end


    # Set this to true if you have Capybara loaded. Happens automatically in CellNew::TestCase.
    def self.capybara=(value)
      @capybara = value
    end

    def self.capybara?
      @capybara
    end

    # Extends ViewModel#call by injecting Capybara support.
    module Capybara
      module ToS
        def to_s
          native.to_s
        end
      end

      def call(*)
        ::Capybara.string(super).extend(ToS)
      end
    end

    module ControllerFor
      # This method is provided by the cell_news-rails gem.
      def controller_for(controller_class)
        # raise "[CellNews] Please install (or update?) the cell_news-rails gem."
      end
    end
    include ControllerFor

    def controller # FIXME: this won't allow us using let(:controller) in MiniTest.
      controller_for(self.class.controller_class)
    end

    def self.included(base)
      base.class_eval do
        extend Uber::InheritableAttr
        inheritable_attr :controller_class

        def self.controller(name) # DSL method for the test.
          self.controller_class = name
        end
      end
    end
  end # Testing
end
