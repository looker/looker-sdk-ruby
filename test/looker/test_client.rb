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

describe LookerSDK::Client do

  before(:each) do
   setup_sdk
  end

  base_url = ENV['LOOKERSDK_BASE_URL'] || 'https://localhost:20000'
  verify_ssl = case ENV['LOOKERSDK_VERIFY_SSL']
               when /false/i
                 false
               when /f/i
                 false
               when '0'
                 false
               else
                 true
               end
  api_version = ENV['LOOKERSDK_API_VERSION'] || '4.0'
  client_id = ENV['LOOKERSDK_CLIENT_ID']
  client_secret = ENV['LOOKERSDK_CLIENT_SECRET']

  opts = {}
  if (client_id && client_secret) then
    opts.merge!({
      :client_id => client_id,
      :client_secret => client_secret,
      :api_endpoint => "#{base_url}/api/#{api_version}",
    })
    opts[:connection_options] = {:ssl => {:verify => false}} unless verify_ssl
  else
    opts.merge!({
      :netrc => true,
      :netrc_file => File.join(fixture_path, '.netrc'),
      :connection_options => {:ssl => {:verify => false}},
    })

  end

  describe "lazy load swagger" do
    it "lazy loads swagger" do
      LookerSDK.reset!
      client = LookerSDK::Client.new(opts.merge({:lazy_swagger => true}))
      assert_nil client.swagger
      client.me()
      assert client.swagger
    end

    it "loads swagger initially" do
      LookerSDK.reset!
      client = LookerSDK::Client.new(opts.merge({:lazy_swagger => false}))
      assert client.swagger
    end
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
      client = LookerSDK::Client.new(:lazy_swagger => true)
      LookerSDK::Configurable.keys.each do |key|
        next if key == :lazy_swagger
        client.instance_variable_get(:"@#{key}").must_equal("Some #{key}")
      end
    end

    describe "with class level configuration" do

      before do
        @opts = {
            :connection_options => {:ssl => {:verify => false}},
            :per_page => 40,
            :client_id    => "looker_client_id",
            :client_secret => "client_secret2",
            :lazy_swagger => true,
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

      describe "with .netrc"  do
        it "can read .netrc files" do
          skip unless File.exist?(File.join(fixture_path, '.netrc'))
          LookerSDK.reset!
          client = LookerSDK::Client.new(
            :lazy_swagger => true,
            :netrc => true,
            :netrc_file => File.join(fixture_path, '.netrc'),
          )
          client.client_id.wont_be_nil
          client.client_secret.wont_be_nil
        end
      end
    end

    describe "config tests" do

      before do
        LookerSDK.reset!
        LookerSDK.configure do |c|
          c.lazy_swagger = true
        end
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

  describe "request options" do

    it "parse_query_and_convenience_headers must handle good input" do

      [
        # no need for empty query or headers
        [{}, {}],
        [{query: {}}, {}],
        [{headers: {}}, {}],
        [{query: {}, headers: {}}, {}],

        # promote raw stuff into query
        [{query:{foo:'bar'}}, {query:{foo:'bar'}}],
        [{foo:'bar'}, {query:{foo:'bar'}}],
        [{foo:'bar', one:1}, {query:{foo:'bar', one:1}}],

        # promote CONVENIENCE_HEADERS into headers
        [{accept: 'foo'}, {headers:{accept: 'foo'}}],
        [{content_type: 'foo'}, {headers:{content_type: 'foo'}}],
        [{accept: 'foo', content_type: 'bar'}, {headers:{accept: 'foo', content_type: 'bar'}}],

        # merge CONVENIENCE_HEADERS into headers if headers not empty
        [{accept: 'foo', headers:{content_type: 'bar'}}, {headers:{accept: 'foo', content_type: 'bar'}}],

        # promote CONVENIENCE_HEADERS into headers while also handling query parts
        [{accept: 'foo', content_type: 'bar', query:{foo:'bar'}}, {query:{foo:'bar'}, headers:{accept: 'foo', content_type: 'bar'}}],
        [{accept: 'foo', content_type: 'bar', foo:'bar'}, {query:{foo:'bar'}, headers:{accept: 'foo', content_type: 'bar'}}],

      ].each do |pair|
        input_original, expected = pair
        input = input_original.dup

        output = LookerSDK::Client.new.send(:parse_query_and_convenience_headers, input)

        input.must_equal input_original
        output.must_equal expected
      end

      # don't make the code above handle the special case of nil input.
      LookerSDK::Client.new.send(:parse_query_and_convenience_headers, nil).must_equal({})
    end

    it "parse_query_and_convenience_headers must detect bad input" do
      [
        1,
        '',
        [],
        {query:1},
        {query:[]},
      ].each do |input|
        proc { LookerSDK::Client.new.send(:parse_query_and_convenience_headers, input) }.must_raise RuntimeError
      end
    end

    [
        [:get, '/api/3.0/users/foo%2Fbar', false],
        [:get, '/api/3.0/users/foo%252Fbar', true],
        [:post, '/api/3.0/users/foo%2Fbar', false],
        [:post, '/api/3.0/users/foo%252Fbar', true],
        [:put, '/api/3.0/users/foo%2Fbar', false],
        [:put, '/api/3.0/users/foo%252Fbar', true],
        [:patch, '/api/3.0/users/foo%2Fbar', false],
        [:patch, '/api/3.0/users/foo%252Fbar', true],
        [:delete, '/api/3.0/users/foo%2Fbar', false],
        [:delete, '/api/3.0/users/foo%252Fbar', true],
        [:head, '/api/3.0/users/foo%2Fbar', false],
        [:head, '/api/3.0/users/foo%252Fbar', true],
    ].each do |method, path, encoded|
      it "handles request path encoding" do
        expected_path = '/api/3.0/users/foo%252Fbar'

        resp = OpenStruct.new(:data => "hi", :status => 204)
        mock = MiniTest::Mock.new.expect(:call, resp, [method, expected_path, nil, {}])
        Sawyer::Agent.stubs(:new).returns(mock, mock)

        sdk = LookerSDK::Client.new
        if [:get, :delete, :head].include? method
          args = [method, path, nil, encoded]
        else
          args = [method, path, nil, nil, encoded]
        end
        sdk.without_authentication do
          value = sdk.public_send *args
          assert_equal "hi", value
        end
        mock.verify
      end
    end
  end

  describe 'Sawyer date/time parsing patch' do
    describe 'key matches time_field pattern' do
      it 'does not modify non-iso date/time string or integer fields' do
        values = {
            :test_at => '30 days',
            :test_on => 'July 20, 1969',
            :test_date => '1968-04-03 12:23:34',  # this is not iso8601 format!
            :date => '2 months ago',
            :test_int_at => 42,
            :test_int_on => 42,
            :test_int_date => 42.1,
            :test_float_at => 42.1,
            :test_float_on => 42.1,
            :test_float_date => 42.1,
        }

        serializer = LookerSDK::Client.new.send(:serializer)
        values.each {|k,v| serializer.decode_hash_value(k,v).must_equal v, k}
      end

      it 'converts iso date/time strings to Ruby date/time' do
        iso_values = {
            :test_at => '2017-02-07T13:21:50-08:00',
            :test_on => '2017-02-07T00:00:00z',
            :test_date => '1969-07-20T00:00:00-08:00',
            :date => '1968-04-03T12:23:34z',
        }
        serializer = LookerSDK::Client.new.send(:serializer)
        iso_values.each {|k,v| serializer.decode_hash_value(k,v).must_be_kind_of Time, k}
      end
    end

    describe 'key does NOT match time_field pattern' do
      it 'ignores time-like values' do
        values = {
            :testat => '30 days',
            :teston => '2017-02-07T13:21:50-08:00',
            :testdate => '1968-04-03T12:23:34z',
            :range => '2 months ago for 1 month'
        }

        serializer = LookerSDK::Client.new.send(:serializer)
        values.each {|k,v| serializer.decode_hash_value(k,v).must_equal v, k}
      end
    end
  end

  # TODO: Convert the old tests that were here to deal with swagger/dynamic way of doing things. Perhaps
  # with a dedicated server that serves swagger customized to the test suite. Also, bring the auth tests
  # to life here on the SDK client end.

end
