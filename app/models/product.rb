class Product < ApplicationRecord
  validates :name, :price, presence: true

  has_one_attached :product_image

  def to_s
    name
  end



  # transform shopping cart products into an array of line items
  def to_builder
    Jbuilder.new do |product|
      product.price stripe_price_id
      product.quantity 1
    end
  end

  # create stripe product and assign to this product
  after_create do
    product = Stripe::Product.create(name: name)
    price = Stripe::Price.create(product: product, unit_amount: self.price, currency: self.currency)
    update(stripe_product_id: product.id, stripe_price_id: price.id)
  end

end
