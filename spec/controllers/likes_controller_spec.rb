require 'rails_helper'

describe LikesController do
    let(:post1) { Fabricate(:post) }
    let(:comment1) { Fabricate(:comment) }
    let(:user) { Fabricate(:user) }
  describe "POST #create" do
    context "user likes a post" do

      before do
        set_current_user user
        post :create, id: post1.id, type: 'Post'
      end

      it_behaves_like "requires sign in" do
        let(:action) { post :create, id: post1.id, type: 'Post'}
      end

      it "sets @like" do
        expect(assigns(:like)).to be_instance_of Like
      end

      it "associates @like with current user" do
        expect(Like.first.user).to eq(user)
      end

      it "sets likeable_id to post id" do
        expect(Like.first.likeable_id).to eq(post1.id)
      end
      it "creates saves like to db" do
        expect(Like.count).to eq(1)
      end

      it "sets likeable to post object if likeable is post" do
        expect(assigns[:likeable]).to be_instance_of Post
      end

      it "renders json @like in response" do
        expect(response.body).to eq({ "likers"=> Like.first.likeable.likers}.to_json)
      end

    end

    it "sets likeable to comment object if likeable is comment" do
      set_current_user user
      post :create, id: comment1.id, type: 'Comment'
      expect(assigns[:likeable]).to be_instance_of Comment
    end
  end

  describe "DELETE #destroy" do
    let!(:like) { Like.create(likeable_id: post1.id, likeable_type: 'Post', user: user) }
    it_behaves_like "requires sign in" do
      let(:action) { delete :destroy, id: post1.id, type: 'Post' }
    end

    it "deletes like from database" do
      set_current_user user
      expect(Like.count).to eq(1)
      delete :destroy, id: post1.id, type: 'Post'
      expect(Like.count).to eq(0)
    end
  end
end
