require "tilt"
require "uber/inheritable_attr"
require "cell_new/version"

module CellNew
  autoload :Testing,  "cell_new/testing"

  class TemplateMissingError < RuntimeError
    def initialize(prefixes, view)
      super("Template missing: view: `#{view.to_s}` prefixes: #{prefixes.inspect}")
    end
  end # Error
end

require "cell_new/option"
require "cell_new/caching"
require "cell_new/prefixes"
require "cell_new/layout"
require "cell_new/templates"
require "cell_new/abstract"
require "cell_new/util"
require "cell_new/view_model"
require "cell_new/concept"
require "cell_new/escaped"
require "cell_new/builder"
require "cell_new/collection"
