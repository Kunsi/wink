class Item < ActiveRecord::Base
  has_many :item_comments
  has_many :items

  belongs_to :case
  belongs_to :item, optional: true
  belongs_to :item_type, optional: true

  validates :name, presence: true
  validates :case, presence: true
end
