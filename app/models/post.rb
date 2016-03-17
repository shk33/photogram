class Post < ActiveRecord::Base
  # Validations
  validates :image,   presence: true
  validates :caption, presence: true, length: { minimum: 4, maximum: 300 }
  validates :user_id, presence: true
  has_attached_file :image, styles: { :medium => "640x" }
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  #Relationships
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
  # For Liking Posts
  acts_as_votable

  # Scopes
  scope :of_followed_users, -> (following_users) { where user_id: following_users }
  
end
