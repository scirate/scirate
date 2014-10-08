require 'spec_helper'

describe CommentChange do
  it { should belong_to(:user) }
  it { should belong_to(:comment) }

  let(:user) { FactoryGirl.create(:user) }
  let(:comment) { FactoryGirl.create(:comment) }

  it "records creation" do
    change = comment.history.last
    expect(change.event).to eq(CommentChange::CREATED)
    expect(change.user_id).to eq(comment.user_id)
    expect(change.content).to eq(comment.content)
  end

  it "records edits" do
    comment.edit!("waffles", user.id)

    change = comment.history.last
    expect(change.event).to eq(CommentChange::EDITED)
    expect(change.user_id).to eq(user.id)
    expect(change.content).to eq("waffles")

    expect(comment.last_change_id).to eq(change.id)
  end

  it "records deletions" do
    comment.soft_delete!(user.id)

    change = comment.history.last
    expect(change.event).to eq(CommentChange::DELETED)
    expect(change.user_id).to eq(user.id)
  end

  it "records restoration" do
    comment.restore!(user.id)

    change = comment.history.last
    expect(change.event).to eq(CommentChange::RESTORED)
    expect(change.user_id).to eq(user.id)
  end
end
