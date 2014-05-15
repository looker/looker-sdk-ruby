require_relative '../helper'

describe Looker::Client do

  before do
    Looker.reset!
  end

  after do
    Looker.reset!
  end

  describe "module configuration" do

    before do
      Looker.reset!
      Looker.configure do |config|
        Looker::Configurable.keys.each do |key|
          config.send("#{key}=", "Some #{key}")
        end
      end
    end

    after do
      Looker.reset!
    end

    it "inherits the module configuration" do
      client = Looker::Client.new
      Looker::Configurable.keys.each do |key|
        client.instance_variable_get(:"@#{key}").must_equal("Some #{key}")
      end
    end

    describe "with class level configuration" do

      before do
        @opts = {
            :connection_options => {:ssl => {:verify => false}},
            :per_page => 40,
            :login    => "looker_login",
            :password => "password2"
        }
      end

      it "overrides module configuration" do
        client = Looker::Client.new(@opts)
        client.per_page.must_equal(40)
        client.login.must_equal("looker_login")
        client.instance_variable_get(:"@password").must_equal("password2")
        client.auto_paginate.must_equal(Looker.auto_paginate)
        client.client_id.must_equal(Looker.client_id)
      end

      it "can set configuration after initialization" do
        client = Looker::Client.new
        client.configure do |config|
          @opts.each do |key, value|
            config.send("#{key}=", value)
          end
        end
        client.per_page.must_equal(40)
        client.login.must_equal("looker_login")
        client.instance_variable_get(:"@password").must_equal("password2")
        client.auto_paginate.must_equal(Looker.auto_paginate)
        client.client_id.must_equal(Looker.client_id)
      end

      it "masks passwords on inspect" do
        client = Looker::Client.new(@opts)
        inspected = client.inspect
        inspected.wont_include("password2")
      end

      it "masks tokens on inspect" do
        client = Looker::Client.new(:access_token => '87614b09dd141c22800f96f11737ade5226d7ba8')
        inspected = client.inspect
        inspected.wont_equal("87614b09dd141c22800f96f11737ade5226d7ba8")
      end

      it "masks client secrets on inspect" do
        client = Looker::Client.new(:client_secret => '87614b09dd141c22800f96f11737ade5226d7ba8')
        inspected = client.inspect
        inspected.wont_equal("87614b09dd141c22800f96f11737ade5226d7ba8")
      end

      describe "with .netrc" do
        it "can read .netrc files" do
          Looker.reset!
          client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'))
          client.login.must_equal("netrc_looker")
          client.instance_variable_get(:"@password").must_equal("netrc_looker1")
        end

        it "can read non-standard API endpoint creds from .netrc" do
          Looker.reset!
          client = Looker::Client.new(:netrc => true, :netrc_file => File.join(fixture_path, '.netrc'), :api_endpoint => 'http://api.github.dev')
          client.login.must_equal("netrc_looker")
          client.instance_variable_get(:"@password").must_equal("netrc_looker1")
        end
      end
    end
  end

  # looker TODO before release, ensure we pass these tests (modified as appropriate)
  #
  # describe "authentication" do
  #   before do
  #     Looker.reset!
  #     @client = Looker.client
  #   end
  #
  #   describe "with module level config" do
  #     before do
  #       Looker.reset!
  #     end
  #     it "sets basic auth creds with .configure" do
  #       Looker.configure do |config|
  #         config.login = 'pengwynn'
  #         config.password = 'il0veruby'
  #       end
  #       expect(Looker.client).to be_basic_authenticated
  #     end
  #     it "sets basic auth creds with module methods" do
  #       Looker.login = 'pengwynn'
  #       Looker.password = 'il0veruby'
  #       expect(Looker.client).to be_basic_authenticated
  #     end
  #     it "sets oauth token with .configure" do
  #       Looker.configure do |config|
  #         config.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       end
  #       expect(Looker.client).not_to be_basic_authenticated
  #       expect(Looker.client).to be_token_authenticated
  #     end
  #     it "sets oauth token with module methods" do
  #       Looker.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       expect(Looker.client).not_to be_basic_authenticated
  #       expect(Looker.client).to be_token_authenticated
  #     end
  #     it "sets oauth application creds with .configure" do
  #       Looker.configure do |config|
  #         config.client_id     = '97b4937b385eb63d1f46'
  #         config.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       end
  #       expect(Looker.client).not_to be_basic_authenticated
  #       expect(Looker.client).not_to be_token_authenticated
  #       expect(Looker.client).to be_application_authenticated
  #     end
  #     it "sets oauth token with module methods" do
  #       Looker.client_id     = '97b4937b385eb63d1f46'
  #       Looker.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       expect(Looker.client).not_to be_basic_authenticated
  #       expect(Looker.client).not_to be_token_authenticated
  #       expect(Looker.client).to be_application_authenticated
  #     end
  #   end
  #
  #   describe "with class level config" do
  #     it "sets basic auth creds with .configure" do
  #       @client.configure do |config|
  #         config.login = 'pengwynn'
  #         config.password = 'il0veruby'
  #       end
  #       expect(@client).to be_basic_authenticated
  #     end
  #     it "sets basic auth creds with instance methods" do
  #       @client.login = 'pengwynn'
  #       @client.password = 'il0veruby'
  #       expect(@client).to be_basic_authenticated
  #     end
  #     it "sets oauth token with .configure" do
  #       @client.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       expect(@client).not_to be_basic_authenticated
  #       expect(@client).to be_token_authenticated
  #     end
  #     it "sets oauth token with instance methods" do
  #       @client.access_token = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       expect(@client).not_to be_basic_authenticated
  #       expect(@client).to be_token_authenticated
  #     end
  #     it "sets oauth application creds with .configure" do
  #       @client.configure do |config|
  #         config.client_id     = '97b4937b385eb63d1f46'
  #         config.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       end
  #       expect(@client).not_to be_basic_authenticated
  #       expect(@client).not_to be_token_authenticated
  #       expect(@client).to be_application_authenticated
  #     end
  #     it "sets oauth token with module methods" do
  #       @client.client_id     = '97b4937b385eb63d1f46'
  #       @client.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #       expect(@client).not_to be_basic_authenticated
  #       expect(@client).not_to be_token_authenticated
  #       expect(@client).to be_application_authenticated
  #     end
  #   end
  #
  #   describe "when basic authenticated"  do
  #     it "makes authenticated calls" do
  #       Looker.configure do |config|
  #         config.login = 'pengwynn'
  #         config.password = 'il0veruby'
  #       end
  #
  #       root_request = stub_get("https://pengwynn:il0veruby@api.github.com/")
  #       Looker.client.get("/")
  #       assert_requested root_request
  #     end
  #   end
  #
  #   describe "when token authenticated", :vcr do
  #     it "makes authenticated calls" do
  #       client = oauth_client
  #
  #       root_request = stub_get("/").
  #           with(:headers => {:authorization => "token #{test_github_token}"})
  #       client.get("/")
  #       assert_requested root_request
  #     end
  #     it "fetches and memoizes login" do
  #       client = oauth_client
  #
  #       expect(client.login).to eq(test_github_login)
  #       assert_requested :get, github_url('/user')
  #     end
  #   end
  #   describe "when application authenticated" do
  #     it "makes authenticated calls" do
  #       client = Looker.client
  #       client.client_id     = '97b4937b385eb63d1f46'
  #       client.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #
  #       root_request = stub_get("/?client_id=97b4937b385eb63d1f46&client_secret=d255197b4937b385eb63d1f4677e3ffee61fbaea")
  #       client.get("/")
  #       assert_requested root_request
  #     end
  #   end
  # end
  #
  # describe ".agent" do
  #   before do
  #     Looker.reset!
  #   end
  #   it "acts like a Sawyer agent" do
  #     expect(Looker.client.agent).to respond_to :start
  #   end
  #   it "caches the agent" do
  #     agent = Looker.client.agent
  #     expect(agent.object_id).to eq(Looker.client.agent.object_id)
  #   end
  # end
  #
  # describe ".root" do
  #   it "fetches the API root" do
  #     Looker.reset!
  #     VCR.use_cassette 'root' do
  #       root = Looker.client.root
  #       expect(root.rels[:issues].href).to eq("https://api.github.com/issues")
  #     end
  #   end
  #
  #   it "passes app creds in the query string" do
  #     root_request = stub_get("/?client_id=97b4937b385eb63d1f46&client_secret=d255197b4937b385eb63d1f4677e3ffee61fbaea")
  #     client = Looker.client
  #     client.client_id     = '97b4937b385eb63d1f46'
  #     client.client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #     client.root
  #     assert_requested root_request
  #   end
  # end
  #
  # describe ".last_response", :vcr do
  #   it "caches the last agent response" do
  #     Looker.reset!
  #     client = Looker.client
  #     expect(client.last_response).to be_nil
  #     client.get "/"
  #     expect(client.last_response.status).to eq(200)
  #   end
  # end
  #
  # describe ".get", :vcr do
  #   before(:each) do
  #     Looker.reset!
  #   end
  #   it "handles query params" do
  #     Looker.get "/", :foo => "bar"
  #     assert_requested :get, "https://api.github.com?foo=bar"
  #   end
  #   it "handles headers" do
  #     request = stub_get("/zen").
  #         with(:query => {:foo => "bar"}, :headers => {:accept => "text/plain"})
  #     Looker.get "/zen", :foo => "bar", :accept => "text/plain"
  #     assert_requested request
  #   end
  # end
  #
  # describe ".head", :vcr do
  #   it "handles query params" do
  #     Looker.reset!
  #     Looker.head "/", :foo => "bar"
  #     assert_requested :head, "https://api.github.com?foo=bar"
  #   end
  #   it "handles headers" do
  #     Looker.reset!
  #     request = stub_head("/zen").
  #         with(:query => {:foo => "bar"}, :headers => {:accept => "text/plain"})
  #     Looker.head "/zen", :foo => "bar", :accept => "text/plain"
  #     assert_requested request
  #   end
  # end
  #
  # describe "when making requests" do
  #   before do
  #     Looker.reset!
  #     @client = Looker.client
  #   end
  #   it "Accepts application/vnd.github.v3+json by default" do
  #     VCR.use_cassette 'root' do
  #       root_request = stub_get("/").
  #           with(:headers => {:accept => "application/vnd.github.v3+json"})
  #       @client.get "/"
  #       assert_requested root_request
  #       expect(@client.last_response.status).to eq(200)
  #     end
  #   end
  #   it "allows Accept'ing another media type" do
  #     root_request = stub_get("/").
  #         with(:headers => {:accept => "application/vnd.github.beta.diff+json"})
  #     @client.get "/", :accept => "application/vnd.github.beta.diff+json"
  #     assert_requested root_request
  #     expect(@client.last_response.status).to eq(200)
  #   end
  #   it "sets a default user agent" do
  #     root_request = stub_get("/").
  #         with(:headers => {:user_agent => Looker::Default.user_agent})
  #     @client.get "/"
  #     assert_requested root_request
  #     expect(@client.last_response.status).to eq(200)
  #   end
  #   it "sets a custom user agent" do
  #     user_agent = "Mozilla/5.0 I am Spartacus!"
  #     root_request = stub_get("/").
  #         with(:headers => {:user_agent => user_agent})
  #     client = Looker::Client.new(:user_agent => user_agent)
  #     client.get "/"
  #     assert_requested root_request
  #     expect(client.last_response.status).to eq(200)
  #   end
  #   it "sets a proxy server" do
  #     Looker.configure do |config|
  #       config.proxy = 'http://proxy.example.com:80'
  #     end
  #     conn = Looker.client.send(:agent).instance_variable_get(:"@conn")
  #     expect(conn.proxy[:uri].to_s).to eq('http://proxy.example.com')
  #   end
  #   it "passes along request headers for POST" do
  #     headers = {"X-GitHub-Foo" => "bar"}
  #     root_request = stub_post("/").
  #         with(:headers => headers).
  #         to_return(:status => 201)
  #     client = Looker::Client.new
  #     client.post "/", :headers => headers
  #     assert_requested root_request
  #     expect(client.last_response.status).to eq(201)
  #   end
  #   it "adds app creds in query params to anonymous requests" do
  #     client = Looker::Client.new
  #     client.client_id     = key = '97b4937b385eb63d1f46'
  #     client.client_secret = secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #     root_request = stub_get "/?client_id=#{key}&client_secret=#{secret}"
  #
  #     client.get("/")
  #     assert_requested root_request
  #   end
  #   it "omits app creds in query params for basic requests" do
  #     client = Looker::Client.new :login => "login", :password => "passw0rd"
  #     client.client_id     = key = '97b4937b385eb63d1f46'
  #     client.client_secret = secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #     root_request = stub_get basic_github_url("/?foo=bar", :login => "login", :password => "passw0rd")
  #
  #     client.get("/", :foo => "bar")
  #     assert_requested root_request
  #   end
  #   it "omits app creds in query params for token requests" do
  #     client = Looker::Client.new(:access_token => '87614b09dd141c22800f96f11737ade5226d7ba8')
  #     client.client_id     = key = '97b4937b385eb63d1f46'
  #     client.client_secret = secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #     root_request = stub_get(github_url("/?foo=bar")).with \
  #       :headers => {"Authorization" => "token 87614b09dd141c22800f96f11737ade5226d7ba8"}
  #
  #     client.get("/", :foo => "bar")
  #     assert_requested root_request
  #   end
  # end
  #
  # describe "auto pagination", :vcr do
  #   before do
  #     Looker.reset!
  #     Looker.configure do |config|
  #       config.auto_paginate = true
  #       config.per_page = 1
  #     end
  #   end
  #
  #   after do
  #     Looker.reset!
  #   end
  #
  #   it "fetches all the pages" do
  #     url = '/search/users?q=user:joeyw user:pengwynn user:sferik'
  #     Looker.client.paginate url
  #     assert_requested :get, github_url("#{url}&per_page=1")
  #     (2..3).each do |i|
  #       assert_requested :get, github_url("#{url}&per_page=1&page=#{i}")
  #     end
  #   end
  #
  #   it "accepts a block for custom result concatination" do
  #     results = Looker.client.paginate("/search/users?per_page=1&q=user:pengwynn+user:defunkt",
  #                                       :per_page => 1) { |data, last_response|
  #       data.items.concat last_response.data.items
  #     }
  #
  #     expect(results.total_count).to eq(2)
  #     expect(results.items.length).to eq(2)
  #   end
  # end
  #
  # describe ".as_app" do
  #   before do
  #     @client_id = '97b4937b385eb63d1f46'
  #     @client_secret = 'd255197b4937b385eb63d1f4677e3ffee61fbaea'
  #
  #     Looker.reset!
  #     Looker.configure do |config|
  #       config.access_token  = 'a' * 40
  #       config.client_id     = @client_id
  #       config.client_secret = @client_secret
  #       config.per_page      = 50
  #     end
  #
  #     @root_request = stub_get basic_github_url "/",
  #                                               :login => @client_id, :password => @client_secret
  #   end
  #
  #   it "uses preconfigured client and secret" do
  #     client = Looker.client
  #     login = client.as_app do |c|
  #       c.login
  #     end
  #     expect(login).to eq(@client_id)
  #   end
  #
  #   it "requires a client and secret" do
  #     Looker.reset!
  #     client = Looker.client
  #     expect {
  #       client.as_app do |c|
  #         c.get
  #       end
  #     }.to raise_error Looker::ApplicationCredentialsRequired
  #   end
  #
  #   it "duplicates the client" do
  #     client = Looker.client
  #     page_size = client.as_app do |c|
  #       c.per_page
  #     end
  #     expect(page_size).to eq(client.per_page)
  #   end
  #
  #   it "uses client and secret as Basic auth" do
  #     client = Looker.client
  #     app_client = client.as_app do |c|
  #       c
  #     end
  #     expect(app_client).to be_basic_authenticated
  #   end
  #
  #   it "makes authenticated requests" do
  #     stub_get github_url("/user")
  #
  #     client = Looker.client
  #     client.get "/user"
  #     client.as_app do |c|
  #       c.get "/"
  #     end
  #
  #     assert_requested @root_request
  #   end
  # end
  #
  # context "error handling" do
  #   before do
  #     Looker.reset!
  #     VCR.turn_off!
  #   end
  #
  #   after do
  #     VCR.turn_on!
  #   end
  #
  #   it "raises on 404" do
  #     stub_get('/booya').to_return(:status => 404)
  #     expect { Looker.get('/booya') }.to raise_error Looker::NotFound
  #   end
  #
  #   it "raises on 500" do
  #     stub_get('/boom').to_return(:status => 500)
  #     expect { Looker.get('/boom') }.to raise_error Looker::InternalServerError
  #   end
  #
  #   it "includes a message" do
  #     stub_get('/boom').
  #         to_return \
  #       :status => 422,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:message => "No repository found for hubtopic"}.to_json
  #     begin
  #       Looker.get('/boom')
  #     rescue Looker::UnprocessableEntity => e
  #       expect(e.message).to include("GET https://api.github.com/boom: 422 - No repository found")
  #     end
  #   end
  #
  #   it "includes an error" do
  #     stub_get('/boom').
  #         to_return \
  #       :status => 422,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:error => "No repository found for hubtopic"}.to_json
  #     begin
  #       Looker.get('/boom')
  #     rescue Looker::UnprocessableEntity => e
  #       expect(e.message).to include("GET https://api.github.com/boom: 422 - Error: No repository found")
  #     end
  #   end
  #
  #   it "includes an error summary" do
  #     stub_get('/boom').
  #         to_return \
  #       :status => 422,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {
  #           :message => "Validation Failed",
  #           :errors => [
  #               :resource => "Issue",
  #               :field    => "title",
  #               :code     => "missing_field"
  #           ]
  #       }.to_json
  #     begin
  #       Looker.get('/boom')
  #     rescue Looker::UnprocessableEntity => e
  #       expect(e.message).to include("GET https://api.github.com/boom: 422 - Validation Failed")
  #       expect(e.message).to include("  resource: Issue")
  #       expect(e.message).to include("  field: title")
  #       expect(e.message).to include("  code: missing_field")
  #     end
  #   end
  #
  #   it "exposes errors array" do
  #     stub_get('/boom').
  #         to_return \
  #       :status => 422,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {
  #           :message => "Validation Failed",
  #           :errors => [
  #               :resource => "Issue",
  #               :field    => "title",
  #               :code     => "missing_field"
  #           ]
  #       }.to_json
  #     begin
  #       Looker.get('/boom')
  #     rescue Looker::UnprocessableEntity => e
  #       expect(e.errors.first[:resource]).to eq("Issue")
  #       expect(e.errors.first[:field]).to eq("title")
  #       expect(e.errors.first[:code]).to eq("missing_field")
  #     end
  #   end
  #
  #   it "knows the difference between Forbidden and rate limiting" do
  #     stub_get('/some/admin/stuffs').to_return(:status => 403)
  #     expect { Looker.get('/some/admin/stuffs') }.to raise_error Looker::Forbidden
  #
  #     stub_get('/users/mojomobo').to_return \
  #       :status => 403,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:message => "API rate limit exceeded"}.to_json
  #     expect { Looker.get('/users/mojomobo') }.to raise_error Looker::TooManyRequests
  #
  #     stub_get('/user').to_return \
  #       :status => 403,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:message => "Maximum number of login attempts exceeded"}.to_json
  #     expect { Looker.get('/user') }.to raise_error Looker::TooManyLoginAttempts
  #   end
  #
  #   it "raises on unknown client errors" do
  #     stub_get('/user').to_return \
  #       :status => 418,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:message => "I'm a teapot"}.to_json
  #     expect { Looker.get('/user') }.to raise_error Looker::ClientError
  #   end
  #
  #   it "raises on unknown server errors" do
  #     stub_get('/user').to_return \
  #       :status => 509,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {:message => "Bandwidth exceeded"}.to_json
  #     expect { Looker.get('/user') }.to raise_error Looker::ServerError
  #   end
  #
  #   it "handles documentation URLs in error messages" do
  #     stub_get('/user').to_return \
  #       :status => 415,
  #       :headers => {
  #           :content_type => "application/json",
  #       },
  #       :body => {
  #           :message => "Unsupported Media Type",
  #           :documentation_url => "http://developer.github.com/v3"
  #       }.to_json
  #     begin
  #       Looker.get('/user')
  #     rescue Looker::UnsupportedMediaType => e
  #       msg = "415 - Unsupported Media Type"
  #       expect(e.message).to include(msg)
  #       expect(e.documentation_url).to eq("http://developer.github.com/v3")
  #     end
  #   end
  #
  #   it "handles an error response with an array body" do
  #     stub_get('/user').to_return \
  #       :status => 500,
  #       :headers => {
  #           :content_type => "application/json"
  #       },
  #       :body => [].to_json
  #     expect { Looker.get('/user') }.to raise_error Looker::ServerError
  #   end
  # end
  #
  # it "knows the difference between unauthorized and needs OTP" do
  #   stub_get('/authorizations').to_return(:status => 401)
  #   expect { Looker.get('/authorizations') }.to raise_error Looker::Unauthorized
  #
  #   stub_get('/authorizations/1').to_return \
  #       :status => 401,
  #       :headers => {
  #           :content_type => "application/json",
  #           "X-GitHub-OTP" => "required; sms"
  #       },
  #       :body => {:message => "Must specify two-factor authentication OTP code."}.to_json
  #   expect { Looker.get('/authorizations/1') }.to raise_error Looker::OneTimePasswordRequired
  # end
  #
  # it "knows the password delivery mechanism when needs OTP" do
  #   stub_get('/authorizations/1').to_return \
  #     :status => 401,
  #     :headers => {
  #         :content_type => "application/json",
  #         "X-GitHub-OTP" => "required; app"
  #     },
  #     :body => {:message => "Must specify two-factor authentication OTP code."}.to_json
  #
  #   begin
  #     Looker.get('/authorizations/1')
  #   rescue Looker::OneTimePasswordRequired => otp_error
  #     expect(otp_error.password_delivery).to eql 'app'
  #   end
  # end

end
