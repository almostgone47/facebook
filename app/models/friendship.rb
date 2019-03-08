class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  
  def confirm_friend(user)
    friend = user
    friend.accepted = true
    friend.save
  end
end
