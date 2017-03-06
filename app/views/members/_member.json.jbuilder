json.extract! member, :id, :member_id, :fullname, :email, :upline_id, :created_at, :updated_at
json.url member_url(member, format: :json)
