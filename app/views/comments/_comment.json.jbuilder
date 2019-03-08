json.extract! comment, :id, :user_id, :commentable_id, :commentable_type, :body, :created_at, :updated_at
json.url comment_url(comment, format: :json)
