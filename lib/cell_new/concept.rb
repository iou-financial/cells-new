require "cell_new/self_contained"

module CellNew
  # CellNew::Concept is no longer under active development. Please switch to Trailblazer::CellNew.
  class Concept < CellNew::ViewModel
    abstract!
    self.view_paths = ["app/concepts"]
    extend SelfContained

    # TODO: this should be in Helper or something. this should be the only entry point from controller/view.
    class << self
      def class_from_cell_new_name(name)
        util.constant_for(name)
      end

      def controller_path
        @controller_path ||= util.underscore(name.sub(/(::CellNew$|CellNew::)/, ''))
      end
    end

    alias_method :concept, :cell_new

    self_contained!
  end
end
