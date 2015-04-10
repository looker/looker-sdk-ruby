require_relative '../helper'

describe LookerSDK::Client do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  describe "call looker" do
    before do
      @opts = {
          :connection_options => {:ssl => {:verify => false}},
          :netrc      => true,
          :netrc_file => "test/fixtures/.netrc",
      }
    end

    it "can make a simple call to looker using stored credentials" do
      client = LookerSDK::Client.new(@opts)
      user = client.me
      user.wont_be_nil
      user[:id].wont_be_nil
      user[:credentials_api3].wont_be_nil
    end
  end
end
