json.extract! transaction, :id, :member_id, :product_name, :price, :quantity, :note, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
