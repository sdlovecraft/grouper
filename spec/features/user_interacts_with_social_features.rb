require 'rails_helper'

feature 'User Interacts With Social Features' do
  scenario 'User friends some users and views friends page' do
    sam = Fabricate(:user)
    discussion1 = Fabricate(:discussion)
    discussion2 = Fabricate(:discussion)
    alice = Fabricate(:user)
    bob = Fabricate(:user)
    post1 = Fabricate(:post, discussion: discussion1, user: alice)
    post2 = Fabricate(:post, discussion: discussion2, user: bob)
    sign_in sam

    add_user_as_friend(alice, discussion1)
    add_user_as_friend(bob, discussion2)

    click_link("friends")

    expect(page).to have_link(alice.name)
    expect(page).to have_link(bob.name)

    remove_user_as_friend(alice, discussion1)

  end

end

def add_user_as_friend(user, discussion)
    click_link(discussion.name)
    expect(page).to have_content(discussion.description)
    click_link(user.name)
    click_link("add friend")
    expect(page).to have_content("you have added a friend!")
    click_link("GARP")
end

def remove_user_as_friend(user, discussion)
    click_link(discussion.name)
    expect(page).to have_content(discussion.description)
    click_link(user.name)
    click_link("remove friend")
    expect(page).to have_content("you have deleted friend!")
    click_link("friends")
    expect(page).to_not have_content(user.name)
end
