require_relative '../helper'

describe LookerSDK::Client::Dynamic do

  def access_token
    '87614b09dd141c22800f96f11737ade5226d7ba8'
  end

  def sdk_client(swagger, engine)
    faraday = Faraday.new do |conn|
      conn.use LookerSDK::Response::RaiseError
      conn.adapter :rack, engine
    end

    LookerSDK::Client.new do |config|
      config.swagger = swagger
      config.access_token = access_token
      config.faraday = faraday
    end
  end

  def default_swagger
    @swagger ||= JSON.parse(File.read(File.join(File.dirname(__FILE__), 'swagger.json')), :symbolize_names => true)
  end

  def response
    [200, {'Content-Type' => 'application/vnd.looker.v3+json'}, [{}.to_json]]
  end

  def delete_response
    [204, {}, []]
  end

  def confirm_env(env, method, path, body, query)
    req = Rack::Request.new(env)
    req_body = req.body.gets || ''

    req.base_url.must_equal 'https://localhost:19999'
    req.request_method.must_equal method.to_s.upcase
    req.path_info.must_equal path

    env["HTTP_AUTHORIZATION"].must_equal  "token #{access_token}"

    JSON.parse(req.params.to_json, :symbolize_names => true).must_equal query

    begin
      JSON.parse(req_body, :symbolize_names => true).must_equal body
    rescue JSON::ParserError => e
      req_body.must_equal body
    end

    # puts env
    # puts req.inspect
    # puts req.params.inspect
    # puts req_body
    # puts req.content_type

    true
  end

  def verify(response, method, path, body='', query={})
    mock = MiniTest::Mock.new.expect(:call, response){|env| confirm_env(env, method, path, body, query)}
    yield sdk_client(default_swagger, mock)
    mock.verify
  end


  describe "swagger" do

    it "get" do
      verify(response, :get, '/api/3.0/user') do |sdk|
        sdk.me
      end
    end

    it "get with parms" do
      verify(response, :get, '/api/3.0/users/25') do |sdk|
        sdk.user(25)
      end
    end

    it "get with query" do
      verify(response, :get, '/api/3.0/user', '', {bar:"foo"}) do |sdk|
        sdk.me({bar:'foo'})
      end
    end

    it "get with params and query" do
      verify(response, :get, '/api/3.0/users/25', '', {bar:"foo"}) do |sdk|
        sdk.user(25, {bar:'foo'})
      end
    end

    it "post" do
      verify(response, :post, '/api/3.0/users', {first_name:'Joe'}) do |sdk|
        sdk.create_user({first_name:'Joe'})
      end
    end

    it "patch" do
      verify(response, :patch, '/api/3.0/users/25', {first_name:'Jim'}) do |sdk|
        sdk.update_user(25, {first_name:'Jim'})
      end
    end

    it "patch with query" do
      verify(response, :post, '/api/3.0/users', {first_name:'Jim'}, {foo:'bar', baz:'bla'}) do |sdk|
        sdk.create_user({first_name:'Jim'}, {foo:'bar', baz:'bla'})
      end
    end

    it "put" do
      verify(response, :put, '/api/3.0/users/25/roles', [10, 20]) do |sdk|
        sdk.set_user_roles(25, [10,20])
      end
    end

    it "delete" do
      verify(delete_response, :delete, '/api/3.0/users/25') do |sdk|
        sdk.delete_user(25)
      end
    end

  end
end
