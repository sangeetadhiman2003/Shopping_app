class Product < ApplicationRecord
  validates :name, :price, presence: true

  has_one_attached :product_image
end
