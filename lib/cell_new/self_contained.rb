# Enforces the new trailblazer directory layout where cell_news (or concepts in general) are
# fully self-contained in its own directory.
module CellNew::SelfContained
  def self_contained!
    extend Prefixes
  end

  module Prefixes
    def _local_prefixes
      super.collect { |prefix| "#{prefix}/views" }
    end
  end
end