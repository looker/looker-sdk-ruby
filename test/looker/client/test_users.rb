require_relative '../../helper'

describe Looker::Client::Users do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_users", :vcr do
    it "returns all Looker users" do
      u1 = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      u2 = Looker.create_user({:first_name => "Jonathan1", :last_name => "Swenson1"})
      users = Looker.all_users
      users.must_be_kind_of Array
      users.length.must_equal 2
      users.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".user", :vcr do
    it "returns single Looker user" do
      u1 = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      u2 = Looker.create_user({:first_name => "Jonathan1", :last_name => "Swenson1"})

      user = Looker.user(1)
      user.must_be_kind_of Sawyer::Resource

      user = Looker.user(2)
      user.must_be_kind_of Sawyer::Resource
    end

    it "gets current user with no user_id", :vcr do
      user = Looker.user
      user.must_be_kind_of Sawyer::Resource
    end
  end

  describe ".create_user", :vcr do
    it "creates user with valid email" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      user.must_be_kind_of Sawyer::Resource
    end
  end

  describe ".create_credentials_email", :vcr do
    it "create user and add credentials email" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      credentials_email = Looker.create_credentials_email(user[:id], "jonathan+9@looker.com")
      credentials_email.must_be_kind_of Sawyer::Resource
    end

    it "will not create two credentials emails for same user", :vcr do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.create_credentials_email(user[:id], "jonathan+10@looker.com")
      assert_raises Looker::Conflict do
        credentials_email2 = Looker.create_credentials_email(user[:id], "jonathan+11@looker.com")
      end
    end
  end

  describe ".update_credentials_email", :vcr do
    it "update credentials_email email address" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.create_credentials_email(user[:id], "jonathan+12@looker.com")
      Looker.update_credentials_email(user[:id], {:email => "jonathan+13@looker.com"})
      Looker.get_credentials_email(user[:id])[:email].must_equal "jonathan+13@looker.com"
    end
  end

  describe ".remove_credentials_email", :vcr do
    it "removes credentials email" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.create_credentials_email(user[:id], "jonathan+16@looker.com")
      Looker.delete_credentials_email(user[:id]).must_equal true
      assert_raises Looker::NotFound do
        Looker.get_credentials_email(user[:id])
      end
    end

    it "will not remove credentials_email if it doesn't exist" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.delete_credentials_email(user[:id]).must_equal false
    end
  end

  describe ".get_credentials_email", :vcr do
    it "gets corresponding credentials email" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.create_credentials_email(user[:id], "jonathan+14@looker.com")
      Looker.get_credentials_email(user[:id])[:email].must_equal "jonathan+14@looker.com"
    end

    it "will not find credentials email that does not exist" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      assert_raises Looker::NotFound do
        Looker.get_credentials_email(user[:id])
      end
    end
  end

  describe ".delete_user", :vcr do
    it "deletes user" do
      user = Looker.create_user({:first_name => "Jonathan", :last_name => "Swenson"})
      Looker.delete_user(user[:id])
      Looker.last_response.status.must_equal 204
    end

    # look TODO: When we allow for actually logging in we need this to pass.
    # it "will not delete self" do
    #   user = Looker.user
    #   assert_raises Looker::Forbidden do
    #     Looker.delete_user(user[:id])
    #   end
    # end

    it "will not delete user that does not exist" do
      Looker.delete_user(9999).must_equal false # doesn't exist
    end
  end
end

