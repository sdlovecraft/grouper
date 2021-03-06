class Comment < ActiveRecord::Base
  include AutoHtml
  belongs_to :user
  belongs_to :post
  has_many :likes, ->{ order('created_at DESC') }, as: :likeable
  validates_presence_of :body

  auto_html_for :body do
    html_escape
    image
    youtube(:width => 340, :height => 212)
    soundcloud
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

  def likers 
    likes.map(&:user)
  end
end
