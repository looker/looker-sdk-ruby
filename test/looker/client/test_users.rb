require_relative '../../helper'

describe Looker::Client::Users do

  before(:each) do
    Looker.reset!
    @client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
  end

  describe ".all_users", :vcr do
    it "returns all Looker users" do
      users = Looker.all_users
      users.must_be_kind_of Array
    end
  end
end

