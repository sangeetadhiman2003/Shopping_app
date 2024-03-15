class CheckoutController < ApplicationController

  def create
    if @cart.pluck(:currency).uniq.length > 1
      redirect_to products_path, alert: "You cannot select products with different currencies in one checkout."
    else
      customer = Stripe::Customer.create(
        email: current_user.email,
        description: "Customer id: #{current_user.id}"
      )

      line_items = @cart.map do |item|
        {
          price_data: {
            currency: item.currency,
            product_data: {
              name: item.name,
              description: item.description
            },
            unit_amount: item.price,
          },
          quantity: 1
        }
      end

      if line_items.empty?
        redirect_to products_path, alert: "Your cart is empty."
        return
      end

      @session = Stripe::Checkout::Session.create(
        customer: customer.id,
        payment_method_types: ['card'],
        line_items: line_items,
        allow_promotion_codes: true,
        mode: 'payment',
        success_url: success_url + "?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cancel_url
      )
      redirect_to @session.url, allow_other_host: true

    end

  end

  def success
    if params[:session_id].present?
      # session.delete(:cart)
      session[:cart] = [] # empty cart = empty array
      @session_with_expand = Stripe::Checkout::Session.retrieve({ id: params[:session_id], expand: ["line_items"]})
      @session_with_expand.line_items.data.each do |line_item|
        product = Product.find_by(stripe_product_id: line_item.price.product)
      end
    else
      redirect_to cancel_url, alert: "No info to display"
    end
  end

  def cancel
  end

end
