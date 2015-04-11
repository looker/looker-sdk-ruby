require_relative '../helper'

describe LookerSDK::Client do

  before(:each) do
   setup_sdk
  end

  after(:each) do
   teardown_sdk
  end

  describe "module configuration" do

    before do
      LookerSDK.reset!
      LookerSDK.configure do |config|
        LookerSDK::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      LookerSDK.reset!
    end

    it "inherits the module configuration" do
      client = LookerSDK::Client.new
      LookerSDK::Configurable.keys.each do |key|
        client.instance_variable_get(:"@#{key}").must_equal("Some #{key}")
      end
    end

    describe "with class level configuration" do

      before do
        @opts = {
            :connection_options => {:ssl => {:verify => false}},
            :per_page => 40,
            :client_id    => "looker_client_id",
            :client_secret => "client_secret2"
        }
      end

      it "overrides module configuration" do
        client = LookerSDK::Client.new(@opts)
        client.per_page.must_equal(40)
        client.client_id.must_equal("looker_client_id")
        client.instance_variable_get(:"@client_secret").must_equal("client_secret2")
        client.auto_paginate.must_equal(LookerSDK.auto_paginate)
        client.client_id.wont_equal(LookerSDK.client_id)
      end

      it "can set configuration after initialization" do
        client = LookerSDK::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
        client.per_page.must_equal(40)
        client.client_id.must_equal("looker_client_id")
        client.instance_variable_get(:"@client_secret").must_equal("client_secret2")
        client.auto_paginate.must_equal(LookerSDK.auto_paginate)
        client.client_id.wont_equal(LookerSDK.client_id)
      end

      it "masks client_secrets on inspect" do
        client = LookerSDK::Client.new(@opts)
        inspected = client.inspect
        inspected.wont_include("client_secret2")
      end

      it "masks tokens on inspect" do
        client = LookerSDK::Client.new(:access_token => '87614b09dd141c22800f96f11737ade5226d7ba8')
        inspected = client.inspect
        inspected.wont_equal("87614b09dd141c22800f96f11737ade5226d7ba8")
      end

      it "masks client secrets on inspect" do
        client = LookerSDK::Client.new(:client_secret => '87614b09dd141c22800f96f11737ade5226d7ba8')
        inspected = client.inspect
        inspected.wont_equal("87614b09dd141c22800f96f11737ade5226d7ba8")
      end

      unless ENV["CONTINUOUS_INTEGRATION"] == "true"
        describe "with .netrc"  do
          it "can read .netrc files" do
            LookerSDK.reset!
            client = LookerSDK::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
            client.client_id.wont_be_nil
            client.client_secret.wont_be_nil
          end
        end
      end
    end

    describe "config tests" do

      before do
        LookerSDK.reset!
      end

      it "sets oauth token with .configure" do
        client = LookerSDK::Client.new
        client.configure do |config|
          config.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        client.application_credentials?.must_equal false
        client.token_authenticated?.must_equal true
      end

      it "sets oauth token with initializer block" do
        client = LookerSDK::Client.new do |config|
          config.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        client.application_credentials?.must_equal false
        client.token_authenticated?.must_equal true
      end

      it "sets oauth token with instance methods" do
        client = LookerSDK::Client.new
        client.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        client.application_credentials?.must_equal false
        client.token_authenticated?.must_equal true
      end

      it "sets oauth application creds with .configure" do
        client = LookerSDK::Client.new
        client.configure do |config|
          config.client_id     = '97b4937b385eb63d1f46'
          config.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        client.application_credentials?.must_equal true
        client.token_authenticated?.must_equal false
      end

      it "sets oauth application creds with initializer block" do
        client = LookerSDK::Client.new do |config|
          config.client_id     = '97b4937b385eb63d1f46'
          config.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        end
        client.application_credentials?.must_equal true
        client.token_authenticated?.must_equal false
      end

      it "sets oauth token with module methods" do
        client = LookerSDK::Client.new
        client.client_id     = '97b4937b385eb63d1f46'
        client.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
        client.application_credentials?.must_equal true
        client.token_authenticated?.must_equal false
      end
    end

  end

  unless ENV["CONTINUOUS_INTEGRATION"] == "true"
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

  # TODO: Convert the old tests that were here to deal with swagger/dynamic way of doing things. Perhaps
  # with a dedicated server that serves swagger customized to the test suite. Also, bring the auth tests
  # to life here on the SDK client end.

end
