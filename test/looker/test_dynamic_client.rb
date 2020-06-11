############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2018 Looker Data Sciences, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
############################################################################################

require_relative '../helper'

class LookerDynamicClientTest < MiniTest::Spec

  def access_token
    '87614b09dd141c22800f96f11737ade5226d7ba8'
  end

  def sdk_client(swagger, engine)
    faraday = Faraday.new do |conn|
      conn.use LookerSDK::Response::RaiseError
      conn.adapter :rack, engine
    end

    LookerSDK.reset!
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
    [200, {'Content-Type' => 'application/json'}, [{}.to_json]]
  end

  def delete_response
    [204, {}, []]
  end

  def confirm_env(env, method, path, body, query, content_type)
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

    req.content_type.must_equal(content_type) if content_type

    # puts env
    # puts req.inspect
    # puts req.params.inspect
    # puts req_body
    # puts req.content_type

    true
  end

  def verify(response, method, path, body='', query={}, content_type = nil)
    mock = MiniTest::Mock.new.expect(:call, response){|env| confirm_env(env, method, path, body, query, content_type)}
    yield sdk_client(default_swagger, mock)
    mock.verify
  end

  describe "swagger" do

    it "raises when swagger.json can't be loaded" do
      mock = MiniTest::Mock.new.expect(:call, nil) {raise "no swagger for you"}
      mock.expect(:call, nil) {raise "still no swagger for you"}
      err = assert_raises(RuntimeError) { sdk_client(nil, mock) }
      assert_equal "still no swagger for you", err.message
    end

    it "loads swagger without authentication" do
      resp = [200, {'Content-Type' => 'application/json'}, [default_swagger.to_json]]
      mock = MiniTest::Mock.new.expect(:call, resp, [Hash])
      sdk = sdk_client(nil, mock)
      assert_equal default_swagger, sdk.swagger
    end

    it "loads swagger with authentication" do
      resp = [200, {'Content-Type' => 'application/json'}, [default_swagger.to_json]]
      mock = MiniTest::Mock.new.expect(:call, nil) {raise "login first!"}
      mock.expect(:call, resp, [Hash])
      sdk = sdk_client(nil, mock)
      assert_equal default_swagger, sdk.swagger
    end

    it "invalid method name" do
      sdk = sdk_client(default_swagger, nil)
      assert_raises NoMethodError do
        sdk.this_method_name_doesnt_exist()
      end

      assert_raises NameError do
        sdk.invoke(:this_method_name_doesnt_exist)
      end
    end

    describe "operation maps" do
      it "invoke by string operationId" do
        verify(response, :get, '/api/3.0/user') do |sdk|
          sdk.invoke('me')
        end
      end

      it "invoke by symbol operationId" do
        verify(response, :get, '/api/3.0/user') do |sdk|
          sdk.invoke(:me)
        end
      end
    end

    it "get no params" do
      verify(response, :get, '/api/3.0/user') do |sdk|
        sdk.me
      end
    end

    it "get with params" do
      verify(response, :get, '/api/3.0/users/25') do |sdk|
        sdk.user(25)
      end
    end

    it "get with params that need encoding" do
      verify(response, :get, '/api/3.0/users/foo%2Fbar') do |sdk|
        sdk.user("foo/bar")
      end
    end

    it "get with params already encoded" do
        verify(response, :get, '/api/3.0/users/foo%2Fbar') do |sdk|
        sdk.user("foo%2Fbar")
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

    it "get with array query param - string input (csv)" do
      verify(response, :get, '/api/3.0/users/1/attribute_values','',{user_attribute_ids: '2,3,4'}) do |sdk|
        sdk.user_attribute_user_values(1, {user_attribute_ids: '2,3,4'})
        sdk.last_response.env.url.query.must_equal 'user_attribute_ids=2%2C3%2C4'
      end
    end

    it "get with array query param - array input (multi[])" do
      verify(response, :get, '/api/3.0/users/1/attribute_values','',{user_attribute_ids: ['2','3','4']}) do |sdk|
        sdk.user_attribute_user_values(1, {user_attribute_ids: [2,3,4]})
        sdk.last_response.env.url.query.must_equal 'user_attribute_ids%5B%5D=2&user_attribute_ids%5B%5D=3&user_attribute_ids%5B%5D=4'
      end
    end

    it "post" do
      verify(response, :post, '/api/3.0/users', {first_name:'Joe'}) do |sdk|
        sdk.create_user({first_name:'Joe'})
      end
    end

    it "post with default body" do
      verify(response, :post, '/api/3.0/users', {}) do |sdk|
        sdk.create_user()
      end
    end

    it "post with default body and default content_type" do
      verify(response, :post, '/api/3.0/users', {}, {}, "application/json") do |sdk|
        sdk.create_user()
      end
    end

    it "post with default body and specific content_type at option-level" do
      verify(response, :post, '/api/3.0/users', {}, {}, "application/vnd.BOGUS1+json") do |sdk|
        sdk.create_user({}, {:content_type => "application/vnd.BOGUS1+json"})
      end
    end

    it "post with default body and specific content_type in headers" do
      verify(response, :post, '/api/3.0/users', {}, {}, "application/vnd.BOGUS2+json") do |sdk|
        sdk.create_user({}, {:headers => {:content_type => "application/vnd.BOGUS2+json"}})
      end
    end

    it "post with file upload" do
      verify(response, :post, '/api/3.0/users', {first_name:'Joe', last_name:'User'}, {}, "application/vnd.BOGUS3+json") do |sdk|
        name = File.join(File.dirname(__FILE__), 'user.json')
        sdk.create_user(Faraday::UploadIO.new(name, "application/vnd.BOGUS3+json"))
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
