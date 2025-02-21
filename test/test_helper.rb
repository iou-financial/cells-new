require "minitest/autorun"
require "cell_new"
require "cells-erb"
require "debug"
require "pry"
CellNew::ViewModel.send(:include, Cell::Erb) if Cell.const_defined?(:Erb) # FIXME: should happen in inititalizer.

Minitest::Spec.class_eval do
  include CellNew::Testing
end

class BassistCellNew < CellNew::ViewModel
  self.view_paths = ['test/fixtures']
end
