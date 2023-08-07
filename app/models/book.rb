class Book < ApplicationRecord
  belongs_to :user
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :post_book_tags, dependent: :destroy
  has_many :book_tags, through: :post_book_tags

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}

  scope :latest, -> {order(created_at: :desc)}
  scope :old, -> {order(created_at: :asc)}
  scope :star_count, -> {order(star: :desc)}

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  def save_book_tags(tags)
    current_tags = self.book_tags.pluck(:name) unless self.book_tags.nil?
    old_tags = current_tags - tags
    new_tags = tags - current_tags

    old_tags.each do |old_name|
      self.book_tags.delete BookTag.find_by(name:old_name)
    end

    new_tags.each do |new_name|
      book_tag = BookTag.find_or_create_by(name:new_name)
      self.book_tags << book_tag
    end
  end
end
