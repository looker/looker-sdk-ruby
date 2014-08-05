require_relative '../../helper'

describe Looker::Client::Roles do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  def role_options
    {
      :models => 'all',
      :name => 'test_role',
      :permissions => [:access_data, :explore, :see_dashboards]
    }
  end

  describe ".all_roles", :vcr do
    it "returns all Looker roles" do

      roles = Looker.all_roles
      roles.must_be_kind_of Array
      roles.length.must_equal 2
      roles.each do |user|
        user.must_be_kind_of Sawyer::Resource
      end
    end
  end

  describe ".create_role", :vcr do

  end
end
