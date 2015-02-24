module Spree
  module Stock
    class Quantifier
      attr_reader :stock_items

      def initialize(variant)
        @variant = variant
        @stock_items = @variant.stock_items.select { |si| si.stock_location.active? }
      end

      def total_on_hand
        if @variant.should_track_inventory?
          stock_items.map(&:count_on_hand).sum
        else
          Float::INFINITY
        end
      end

      def backorderable?
        stock_items.any?(&:backorderable)
      end

      def can_supply?(required)
        total_on_hand >= required || backorderable?
      end

    end
  end
end
