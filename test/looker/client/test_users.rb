require_relative '../../helper'

describe LookerSDK::Client::Users do

  before(:each) do
    LookerSDK.reset!
    @client = LookerSDK::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_users", :vcr do
    it "returns all Looker users" do
      u1 = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      u2 = LookerSDK.create_user({:first_name => "Jonathan1", :last_name => "Swenson1"})
      users = LookerSDK.all_users
      users.must_be_kind_of Array
      users.length.must_equal 2
      users.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".user", :vcr do
    it "returns single Looker user" do
      u1 = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      u2 = LookerSDK.create_user({:first_name => "Jonathan1", :last_name => "Swenson1"})

      user = LookerSDK.user(1)
      user.must_be_kind_of Sawyer::Resource

      user = LookerSDK.user(2)
      user.must_be_kind_of Sawyer::Resource
    end

    it "gets current user with no user_id", :vcr do
      user = LookerSDK.user
      user.must_be_kind_of Sawyer::Resource
    end
  end

  describe ".create_user", :vcr do
    it "creates user with valid email" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      user.must_be_kind_of Sawyer::Resource
    end
  end

  describe ".create_credentials_email", :vcr do
    it "create user and add credentials email" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      credentials_email = LookerSDK.create_credentials_email(user[:id], "jonathan+9@looker.com")
      credentials_email.must_be_kind_of Sawyer::Resource
    end

    it "will not create two credentials emails for same user", :vcr do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.create_credentials_email(user[:id], "jonathan+10@looker.com")
      assert_raises LookerSDK::Conflict do
        credentials_email2 = LookerSDK.create_credentials_email(user[:id], "jonathan+11@looker.com")
      end
    end
  end

  describe ".update_credentials_email", :vcr do
    it "update credentials_email email address" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.create_credentials_email(user[:id], "jonathan+12@looker.com")
      LookerSDK.update_credentials_email(user[:id], {:email => "jonathan+13@looker.com"})
      LookerSDK.get_credentials_email(user[:id])[:email].must_equal "jonathan+13@looker.com"
    end
  end

  describe ".remove_credentials_email", :vcr do
    it "removes credentials email" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.create_credentials_email(user[:id], "jonathan+16@looker.com")
      LookerSDK.delete_credentials_email(user[:id]).must_equal true
      assert_raises LookerSDK::NotFound do
        LookerSDK.get_credentials_email(user[:id])
      end
    end

    it "will not remove credentials_email if it doesn't exist" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.delete_credentials_email(user[:id]).must_equal false
    end
  end

  describe ".get_credentials_email", :vcr do
    it "gets corresponding credentials email" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.create_credentials_email(user[:id], "jonathan+14@looker.com")
      LookerSDK.get_credentials_email(user[:id])[:email].must_equal "jonathan+14@looker.com"
    end

    it "will not find credentials email that does not exist" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      assert_raises LookerSDK::NotFound do
        LookerSDK.get_credentials_email(user[:id])
      end
    end
  end

  describe ".delete_user", :vcr do
    it "deletes user" do
      user = LookerSDK.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      LookerSDK.delete_user(user[:id])
      LookerSDK.last_response.status.must_equal 204
    end

    # look TODO: When we allow for actually logging in we need this to pass.
    # it "will not delete self" do
    #   user = LookerSDK.user
    #   assert_raises LookerSDK::Forbidden do
    #     LookerSDK.delete_user(user[:id])
    #   end
    # end

    it "will not delete user that does not exist" do
      LookerSDK.delete_user(9999).must_equal false # doesn't exist
    end
  end

  describe ".roles", :vcr do
    it "gets roles of user" do
      user = LookerSDK.user(4)
      roles = LookerSDK.user_roles(user[:id])
    end
  end
end

