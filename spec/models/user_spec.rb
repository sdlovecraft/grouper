require 'rails_helper'

describe User do
  it { should have_many(:discussions).through(:discussion_users) } 
  it { should have_many(:posts) }
  it { should have_many(:comments) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username) }
  it { should have_many(:friends).through(:friendships) }
  it { should have_many(:likes).order('created_at DESC') }
  it { should have_many(:notifications).order('created_at DESC') }

  let(:user) { Fabricate(:user) }
  let(:new_post) { Fabricate(:post) }
  let(:new_comment) { Fabricate(:comment) }
  let(:sender) { Fabricate(:user) }
  let(:receiver) { Fabricate(:user) }
  let(:message) { Fabricate(:message, author: sender) }
  let(:discussion) { Fabricate(:discussion) }
  let(:discussion1) { Fabricate(:discussion, last_updated: 2.days.ago) }
  let(:discussion2) { Fabricate(:discussion, last_updated: 1.day.ago) }
  let(:discussion3) { Fabricate(:discussion) }
  let(:friend) { Fabricate(:user) }

  describe ".search_by_name" do
    it "returns array of users that contain query in their name" do
      sam = Fabricate(:user, name: "Sam Hains")
      sam2 = Fabricate(:user, name: "Sam Dean")
      expect(User.search_by_name('Sa')).to include(sam, sam2)
    end

    it "should limit searches to 5" do
      6.times { Fabricate(:user, name: "Sam Hains") }
      expect(User.search_by_name('Sa').count).to eq(5)
    end

    it "returns array of users that contain query in their username" do
      sam = Fabricate(:user, username: "sdhains")
      sam2 = Fabricate(:user, username: "2_sdhains")
      expect(User.search_by_name('sdhai')).to include(sam, sam2)
    end

    it "is case insensitive" do
      sam = Fabricate(:user, name: "Sam Hains")
      sam2 = Fabricate(:user, name: "Sam Dean")
      expect(User.search_by_name('sa')).to include(sam, sam2)
    end

    it "return users for partially matching query string" do
      sam = Fabricate(:user, name: "Sam Hains")
      sam2 = Fabricate(:user, name: "Sam Dean")
      expect(User.search_by_name('am').count).to eq(2)
    end


    it "does not return users that do not contain query in name" do
      ben = Fabricate(:user, name: "Ben Jones")
      expect(User.search_by_name('sa')).to_not include(ben)
    end
  end


  describe "#new_notifications_count" do
    it "returns the number of unchecked notifications from the user" do
      notification1 = Fabricate(:notification, user:user, user_checked: true)
      notification2 = Fabricate(:notification, user:user)
      notification3 = Fabricate(:notification, user:user)
      expect(user.new_notifications_count).to eq(2)
     
    end

    it "returns 0 if user doesn't have any" do
      expect(user.new_notifications_count).to eq(0)
    end
  end

  describe "#check_notifications" do
    it "should mark all notifications belonging to user as true" do
      notification = Fabricate(:notification, user: user)
      notification1 = Fabricate(:notification, user: user)
      notification3 = Fabricate(:notification, user: user)

      expect(user.new_notifications_count).to eq(3)
      user.check_notifications
      expect(user.new_notifications_count).to eq(0)
    end
  end

  describe "#frienship" do
    it "returns friendship for current_user " do
      friendship = Friendship.create(user: user, friend: friend)
      expect(friend.friendship(user)).to eq(friendship)
    end
  end

  describe "#get_like" do
    it "returns the like object for a post likeable" do
        like = Like.create(likeable_id: new_post.id, likeable_type: 'Post', user: user) 
        expect(user.get_like(new_post)).to eq(like)
    end

    it "returns the like object for a comment likeable" do
        like = Like.create(likeable_id: new_comment.id, likeable_type: 'Comment', user: user) 
        expect(user.get_like(new_comment)).to eq(like)
    end
  end

  describe "#likes?" do
    context "likeable is post" do
      it "returns true if user has liked" do
        Like.create(likeable_id: new_post.id, likeable_type: 'Post', user: user) 
        expect(user.likes?(new_post)).to eq(true)
      end

      it "returns false if user has not liked" do
        expect(user.likes?(new_post)).to eq(false)
      end
    end

    context "likeable is comment" do
      it "returns true if user has liked" do
        Like.create(likeable_id: new_comment.id, likeable_type: 'Comment', user: user) 
        expect(user.likes?(new_comment)).to eq(true)
      end

      it "returns false if user has not liked" do
        expect(user.likes?(new_comment)).to eq(false)
      end
    end
  end

  describe "#is_friend?" do
    it "returns true if the user is a friend" do
      Friendship.create(user: user, friend: friend)
      expect(user.is_friend?(friend)).to eq(true)
    end

    it "returns false if the user is not a friend" do
      expect(user.is_friend?(friend)).to eq(false)
    end

    it "returns false if the user is not a friend" do
    end
  end

  describe "#get_followed_discussions" do

    before { user.discussions << [discussion1, discussion2] }
    
    it "gets a list of all of the discussions threads the user belongs to" do
      expect(user.get_followed_discussions).to include(discussion1, discussion2)
    end

    it "does not return discussions that the user is not involved with" do
      expect(user.get_followed_discussions).to_not include(discussion3)
    end

    it "returns the discussions in reverse last_updated order" do
      expect(user.get_followed_discussions).to eq([discussion2, discussion1])
    end
  end

  describe "#get_my_discussions" do
    it "gets all the discussions which the current user created" do
      discussion1 = Fabricate(:discussion, creator: user)
      discussion2 = Fabricate(:discussion)
      discussion3 = Fabricate(:discussion, creator: user)
      expect(user.get_my_discussions).to include(discussion1, discussion3)
      expect(user.get_my_discussions).to_not include(discussion2)

    end

    it "returns discussions in reverse chronological order" do

      discussion1 = Fabricate(:discussion, last_updated: 1.day.ago, creator: user)
      discussion2 = Fabricate(:discussion, last_updated: 3.days.ago, creator: user)
      discussion3 = Fabricate(:discussion, last_updated: 2.days.ago, creator: user)
      expect(user.get_my_discussions).to eq([discussion1, discussion3, discussion2])
    end
  end
  
  describe "#is_read?" do
    before do
      sender_message = MessageUser.create(message: message, placeholder: "Sent", is_read: true, user_id: sender.id)
      receiver_message = MessageUser.create(message: message, placeholder: "Inbox", is_read: false, user_id: receiver.id)
    end

    it "returns true if the message has been read" do
      expect(sender.is_read?(message, "Sent")).to eq(true)
    end

    it "returns false if the message has not been read" do
      expect(receiver.is_read?(message, "Inbox")).to eq(false)
    end

  end

  describe "#mark_as_read" do
    it "marks the unread message as read" do
      sender_message = MessageUser.create(message: message, placeholder: "Sent", is_read: true, user_id: sender.id)
      receiver_message = MessageUser.create(message: message, placeholder: "Inbox", is_read: false, user_id: receiver.id)

      expect(receiver.is_read?(message, "Inbox")).to eq(false)
      receiver.mark_as_read(message)
      expect(receiver.is_read?(message, "Inbox")).to eq(true)
    end

  end
  describe "#belongs_to_discussion?" do
    it "returns true if user belongs to discussion" do
      user.discussions << discussion
      expect(User.first.belongs_to_discussion?(discussion.id)).to eq(true)
    end

    it "returns false if user doesn't belong to discussion" do
      user.save
      expect(User.first.belongs_to_discussion?(discussion.id)).to eq(false)
    end
  end

  describe "#created_comment?" do
    it "returns true if the user created the comment" do
      user.comments << new_comment
      user.save
      expect(User.first.created_comment?(new_comment.id)).to eq(true)
    end

    it "returns false if the user did not create the new_comment" do
      user.save
      expect(User.first.created_comment?(new_comment.id)).to eq(false)
    end
  end

  describe "#get_messages" do
   
  end

  describe "#created_post?" do
    it "returns true if the user created the comment" do
      user.posts << new_post
      user.save
      expect(User.first.created_post?(new_post.id)).to eq(true)
    end

    it "returns false if the user did not create the new_post" do
      user.save
      expect(User.first.created_post?(new_post.id)).to eq(false)
    end
  end


end

