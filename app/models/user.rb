class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Model Validations
  validates :user_name, presence: true, length: { minimum: 4, maximum: 16 }

  # Relationships
  has_many :posts,    dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_attached_file :avatar, styles: { medium: '152x152#' }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # Because User can like posts
  acts_as_voter

  def owns_post? post
    post.user.id == id
  end

  def owns_comment? post
    post.user.id == id
  end
end
