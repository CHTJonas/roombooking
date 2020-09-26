require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save user without name" do
    user = User.new(email: "joe.bloggs@example.com")
    assert_not user.save
  end

  test "should not save user without email" do
    user = User.new(name: "Joe Bloggs")
    assert_not user.save
  end

  test "should save user with name and email" do
    user = User.new(name: "Joe Bloggs", email: "joe.bloggs@example.com")
    assert user.save
    MailDeliveryJob.jobs.clear
  end

  test "should not save user with duplicate email" do
    user = User.new(name: "Joe Bloggs", email: "charlie@charliejonas.co.uk")
    assert_not user.save
  end

  test "User#revoke_admin! should revoke user admin rights" do
    user = users(:charlie)
    user.update(admin: true)
    user.revoke_admin!
    assert_not user.admin
  end

  test "User#make_admin! should revoke user admin rights" do
    user = users(:charlie)
    user.update(admin: false)
    user.make_admin!
    assert user.admin
  end

  test "User#block! should block a user" do
    user = users(:charlie)
    user.update(blocked: false)
    user.block!
    assert user.blocked
  end

  test "User#unblock! should unblock a user" do
    user = users(:charlie)
    user.update(blocked: true)
    user.unblock!
    assert_not user.blocked
  end

  test "should validate a user's account" do
    user = User.create!(name: "Jean-Luc Picard", email: "noreply@example.com")
    MailDeliveryJob.jobs.clear
    assert user.validation_token.present?
    assert user.validated_at.nil?
    token = user.validation_token
    user.validate(token)
    assert user.validation_token.nil?
    assert user.validated_at.present?
    assert user.validated_at.to_date == Time.zone.today
  end

  test "should not save with both a validation token and validation date present" do
    user = User.new(name: "Jean-Luc Picard", email: "noreply@example.com")
    user.validated_at = Time.zone.now
    user.validation_token = SecureRandom.alphanumeric(48)
    assert_not user.save
  end
end
