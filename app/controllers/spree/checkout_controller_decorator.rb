module Spree
  if defined? Spree::Frontend
    CheckoutController.class_eval do
      # Override because we don't want to remove unshippable items from the order
      # A bundle itself is an unshippable item
      def before_payment
        if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
          @payment_sources = try_spree_current_user.payment_sources
        end
      end
    end
  end
end
