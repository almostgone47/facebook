class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]
  has_many :posts, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :inverse_friends, class_name: 'Friendship', foreign_key: :friend_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  after_create :send_welcome_email

  def send_welcome_email
    UserMailer.welcome_email(self).deliver
  end
  
  def friends
    friends = friendships.map{ |friendship| friendship.friend if friendship.accepted }.compact
    friends + inverse_friends.map{ |friendship| friendship.user if friendship.accepted }.compact
  end

  def pending_requests
    friends = friendships.map{ |friendship| friendship.friend if !friendship.accepted }.compact
  end

  def received_requests
    friends = inverse_friends.map{ |friendship| friendship.user if !friendship.accepted }.compact
  end

  def friends?(user)
    self.friends.include?(user)
  end

  def nonfriendable?(user)
    self.friends.include?(user) || self.pending_requests.include?(user) || self.received_requests.include?(user)
  end

  def feed
    friend_ids = "SELECT friend_id FROM friendships WHERE user_id = :user_id"
    user_ids = "SELECT user_id FROM friendships WHERE friend_id = :user_id" 
    feed = Post.where("user_id IN (#{friend_ids}) OR user_id = :user_id", user_id: id) 
    feed + Post.where("user_id IN (#{user_ids})", user_id: id)
  end
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
    end
  end
end
