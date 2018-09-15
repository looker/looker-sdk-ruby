############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015 Looker Data Sciences, Inc.
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

describe LookerSDK::Client::Dynamic do

  def access_token
    '87614b09dd141c22800f96f11737ade5226d7ba8'
  end

  def sdk_client(swagger)
    LookerSDK::Client.new do |config|
      config.swagger = swagger
      config.access_token = access_token
    end
  end

  def default_swagger
    @swagger ||= JSON.parse(File.read(File.join(File.dirname(__FILE__), 'swagger.json')), :symbolize_names => true)
  end

  def sdk
    @sdk ||= sdk_client(default_swagger)
  end

  def with_stub(klass, method, result)
    klass.stubs(method).returns(result)
    begin
      yield
    ensure
      klass.unstub(method)
    end
  end

  def response
    OpenStruct.new(:data => "foo", :status => 200)
  end

  def delete_response
    OpenStruct.new(:data => "", :status => 204)
  end

  describe "swagger" do
    it "get" do
      mock = MiniTest::Mock.new.expect(:call, response, [:get, '/api/3.0/user', nil, {}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.me
        mock.verify
      end
    end

    it "get with parms" do
      mock = MiniTest::Mock.new.expect(:call, response, [:get, '/api/3.0/users/25', nil, {}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.user(25)
        mock.verify
      end
    end

    it "get with query" do
      mock = MiniTest::Mock.new.expect(:call, response, [:get, '/api/3.0/user', nil, {query:{bar:"foo"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.me({bar:'foo'})
        mock.verify
      end
    end

    it "get with params and query" do
      mock = MiniTest::Mock.new.expect(:call, response, [:get, '/api/3.0/users/25', nil, {query:{bar:"foo"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.user(25, {bar:'foo'})
        mock.verify
      end
    end

    it "post" do
      mock = MiniTest::Mock.new.expect(:call, response, [:post, '/api/3.0/users', {first_name:'Joe'}, {:headers=>{:content_type=>"application/json"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.create_user({first_name:'Joe'})
        mock.verify
      end
    end

    it "post with default body" do
      mock = MiniTest::Mock.new.expect(:call, response, [:post, '/api/3.0/users', {}, {:headers=>{:content_type=>"application/json"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.create_user()
        mock.verify
      end
    end

    it "patch" do
      mock = MiniTest::Mock.new.expect(:call, response, [:patch, '/api/3.0/users/25', {first_name:'Jim'}, {:headers=>{:content_type=>"application/json"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.update_user(25, {first_name:'Jim'})
        mock.verify
      end
    end

    it "put" do
      mock = MiniTest::Mock.new.expect(:call, response, [:put, '/api/3.0/users/25/roles', [10, 20], {:headers=>{:content_type=>"application/json"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.set_user_roles(25, [10,20])
        mock.verify
      end
    end

    it "put with nil body" do
      mock = MiniTest::Mock.new.expect(:call, response, [:put, '/api/3.0/users/25/roles', nil, {}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.set_user_roles(25, nil)
        mock.verify
      end
    end

    it "put with empty body" do
      mock = MiniTest::Mock.new.expect(:call, response, [:put, '/api/3.0/users/25/roles', {}, {:headers=>{:content_type=>"application/json"}}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.set_user_roles(25, {})
        mock.verify
      end
    end

    it "delete" do
      mock = MiniTest::Mock.new.expect(:call, delete_response, [:delete, '/api/3.0/users/25', nil, {}])
      with_stub(Sawyer::Agent, :new, mock) do
        sdk.delete_user(25)
        mock.verify
      end
    end

  end
end
