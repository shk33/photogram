class Post < ActiveRecord::Base
  # Validations
  validates :image,   presence: true
  validates :caption, presence: true
  validates :user_id, presence: true
  has_attached_file :image, styles: { :medium => "640x" }
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


  #Relationships
  belongs_to :user

end
