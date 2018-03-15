module Spree
  if defined? Spree::Frontend
    CheckoutController.class_eval do
      # Override because we don't want to remove unshippable items from the order
      # A bundle itself is an unshippable item
      def before_payment
        if @order.checkout_steps.include? "delivery"
          packages = @order.shipments.map { |s| s.to_package }
          @differentiator = Spree::Stock::Differentiator.new(@order, packages)
          @differentiator.missing.each do |variant, quantity|
            @order.contents.remove(variant, quantity)
          end

          # @order.contents.remove did transitively call reload in the past.
          # Hiding the fact that the machine advanced already to "payment" state.
          #
          # As an intermediary step to optimize reloads out of high volume code path
          # the reload was lifted here and will be removed by later passes.
          @order.reload

          # BMC Override - the reload above resets the state based off the param which prevented
          # the user from being able to go back to the payment step and change their payment
          set_state_if_present
          # / BMC Override
        end

        if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
          @payment_sources = try_spree_current_user.payment_sources
        end
      end
    end
  end
end
