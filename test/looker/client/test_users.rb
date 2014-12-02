require_relative '../../helper'

describe LookerSDK::Client::Users do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  describe ".all_users" do
    it "returns all Looker users" do

      prev_count = LookerSDK.all_users.length
      prev_count.wont_equal 0

      u1 = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      u2 = LookerSDK.create_user({:first_name => mk_name("user_2_first"), :last_name => mk_name("user_2_last")})

      users = LookerSDK.all_users
      users.must_be_kind_of Array
      users.length.must_equal prev_count + 2
      users.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end

      LookerSDK.delete_user(u1.id)
      LookerSDK.delete_user(u2.id)
      LookerSDK.all_users.length.must_equal prev_count
    end
  end

  describe ".user" do
    it "returns single Looker user" do
      u1 = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      u2 = LookerSDK.create_user({:first_name => mk_name("user_2_first"), :last_name => mk_name("user_2_last")})

      user = LookerSDK.user(u1[:id])
      user.must_be_kind_of Sawyer::Resource

      user = LookerSDK.user(u2[:id])
      user.must_be_kind_of Sawyer::Resource

      LookerSDK.delete_user(u1.id)
      LookerSDK.delete_user(u2.id)
    end

    it "gets current user with no user_id" do
      user = LookerSDK.user
      user.must_be_kind_of Sawyer::Resource
    end
  end


  describe ".create_user" do
    it "creates user without email" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      user.must_be_kind_of Sawyer::Resource
      LookerSDK.delete_user(user.id)
    end
  end

  describe ".create_credentials_email" do
    it "create user and add credentials email" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      credentials_email = LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      credentials_email.must_be_kind_of Sawyer::Resource
      LookerSDK.delete_user(user.id)
    end

    it "will not create two credentials emails for same user" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      assert_raises LookerSDK::Conflict do
        credentials_email2 = LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      end
      LookerSDK.delete_user(user.id)
    end
  end


  describe ".update_credentials_email" do
    it "update credentials_email email address" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      LookerSDK.update_credentials_email(user[:id], {:email => mk_name("email_2@example.com")})
      LookerSDK.get_credentials_email(user[:id])[:email].must_equal mk_name("email_2@example.com")
      LookerSDK.delete_user(user.id)
    end
  end


  describe ".remove_credentials_email" do
    it "removes credentials email" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      LookerSDK.delete_credentials_email(user[:id]).must_equal true
      assert_raises LookerSDK::NotFound do
        LookerSDK.get_credentials_email(user[:id])
      end
      LookerSDK.delete_user(user.id)
    end

    it "will not remove credentials_email if it doesn't exist" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.delete_credentials_email(user[:id]).must_equal false
      LookerSDK.delete_user(user.id)
    end
  end

  describe ".get_credentials_email" do
    it "gets corresponding credentials email" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.create_credentials_email(user[:id], mk_name("email_1@example.com"))
      LookerSDK.get_credentials_email(user[:id])[:email].must_equal mk_name("email_1@example.com")
      LookerSDK.delete_user(user.id)
    end

    it "will not find credentials email that does not exist" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      assert_raises LookerSDK::NotFound do
        LookerSDK.get_credentials_email(user[:id])
      end
      LookerSDK.delete_user(user.id)
    end
  end


  describe ".delete_user" do
    it "deletes user" do
      user = LookerSDK.create_user({:first_name => mk_name("user_1_first"), :last_name => mk_name("user_1_last")})
      LookerSDK.delete_user(user[:id]).must_equal true
    end

    it "will not delete self" do
      user = LookerSDK.user
      assert_raises LookerSDK::Forbidden do
        LookerSDK.delete_user(user[:id])
      end
    end

    it "will not delete user that does not exist" do
      LookerSDK.delete_user(9999).must_equal false # doesn't exist
    end
  end

  describe ".roles" do
    it "gets roles of user" do
      user = LookerSDK.user
      roles = LookerSDK.user_roles(user[:id])
    end
  end

  describe ".set_user_roles" do
    it "sets the users roles" do
      user = LookerSDK.create_user
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set"), :permissions => ["see_looks"])
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => ["abcde"])
      roles = (1..5).map {|i| LookerSDK.create_role(:name => mk_name("test_role#{i}"), :model_set_id => model_set.id, :permission_set_id => permission_set.id) }

      new_role_ids = LookerSDK.set_user_roles(user.id, roles.map {|role| role.id}).map {|role| role.id}

      roles.each do |role|
        new_role_ids.must_include role.id
      end

      roles.each do |role|
        LookerSDK.delete_role(role.id).must_equal true
      end
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
      LookerSDK.delete_model_set(model_set.id).must_equal true
      LookerSDK.delete_user(user.id)
    end

    it "wont set duplicate roles" do
      user = LookerSDK.create_user
      permission_set = LookerSDK.create_permission_set(:name => mk_name("permission_set"), :permissions => ["see_looks"])
      model_set = LookerSDK.create_model_set(:name => mk_name("model_set"), :models => ["abcde"])
      roles = (1..5).map {|i| LookerSDK.create_role(:name => mk_name("test_role#{i}"), :model_set_id => model_set.id, :permission_set_id => permission_set.id) }

      new_role_ids = LookerSDK.set_user_roles(user.id, roles.map {|role| role.id} << roles.first.id).map {|role| role.id}
      new_role_ids.select {|role_id| role_id == roles.first.id}.length.must_equal 1

      roles.each do |role|
        LookerSDK.delete_role(role.id).must_equal true
      end
      LookerSDK.delete_permission_set(permission_set.id).must_equal true
      LookerSDK.delete_model_set(model_set.id).must_equal true
      LookerSDK.delete_user(user.id)
    end
  end
end

