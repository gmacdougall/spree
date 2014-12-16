module Spree
  module Adjustable
    class AdjustmentsUpdater
      def self.update(adjustable)
        new(adjustable).update
      end

      def initialize(adjustable)
        @adjustable = adjustable
        adjustable.reload if shipment? && persisted?
      end

      def update
        return unless persisted?
        update_promo_adjustments
        update_tax_adjustments
        # FIXME: This used to persist all totals early, but they were wrong...
        # The would then get updated later in the request to be correct
        # This is likely incorrect on many levels
        persist_totals unless adjustable.is_a?(Spree::Order)
      end

      private

      attr_reader :adjustable
      delegate :adjustments, :persisted?, to: :adjustable

      def update_promo_adjustments
        # FIXME: Still slow
        promo_adjustments = promotion_adjustments.map { |a| a.update!(adjustable) }
        promotion_total = promo_adjustments.compact.sum
        choose_best_promotion_adjustment unless promotion_total == 0
        @promo_total = best_promotion_adjustment.try(:amount).to_f
      end

      def update_tax_adjustments
        # FIXME: Used to use all_adjustments
        tax = adjustable.adjustments.select(&:tax?)
        @included_tax_total = tax.select(&:included?).map(&:update!).compact.sum
        @additional_tax_total = tax.reject(&:included).map(&:update!).compact.sum
      end

      def persist_totals
        adjustable.promo_total = @promo_total
        adjustable.included_tax_total = @included_tax_total
        adjustable.additional_tax_total = @additional_tax_total
        adjustable.adjustment_total = @promo_total + @additional_tax_total
        adjustable.save! if adjustable.changed?
      end

      def shipment?
        adjustable.is_a?(Shipment)
      end

      # Picks one (and only one) promotion to be eligible for this order
      # This promotion provides the most discount, and if two promotions
      # have the same amount, then it will pick the latest one.
      def choose_best_promotion_adjustment
        if best_promotion_adjustment
          other_promotions = promotion_adjustments.reject { |a| a.id == best_promotion_adjustment.id }
          other_promotions.each do |promo|
            promo.eligible = false
          end
        end
      end

      def best_promotion_adjustment
        # FIXME: add created_at, id tiebreaker
        @best_promotion_adjustment ||= adjustments.max_by { |x| x.amount }
      end

      def promotion_adjustments
        adjustments.select(&:promotion?)
      end
    end
  end
end
