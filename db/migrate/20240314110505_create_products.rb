class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :price
      t.text :description
      t.string :price_cents
      t.string :currency
      t.string :stripe_product_id
      t.string :stripe_price_id

      t.timestamps
    end
  end
end
