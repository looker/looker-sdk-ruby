### Streaming Downloads

#### Beta Feature - Experimental!

This SDK makes it easy to fetch a response from a Looker API and hydrate it into a Ruby object.This convenience is great for working with configuration and administrative data. However, when the response is gigabytes of row data, pulling it all into memory doesn't work so well - you can't begin processing the data until after it has all downloaded, for example, and chewing up tons of memory will put a serious strain on the entire system - even crash it.

One solution to all this is to use streaming downloads to process the data in chunks as it is downloaded. Streaming requires a little more code to set up but the benefits can be significant.

To use streaming downloads with the Looker SDK, simply add a block to an SDK call. The block will be called with chunks of data as they are downloaded instead of the method returning a complete result.

For example:

```ruby
def run_look_to_file(look_id, filename, format, opts = {})
  File.open(filename, 'w') do |file|
    sdk.run_look(look_id, format, opts) do |data, progress|
      file.write(data)
      puts "Wrote #{data.length} bytes of #{progress.length} total"
    end
  end
end

run_look_to_file(38, 'out.csv', 'csv', limit: 10000)
```

In the code above, `sdk.run_look` opens a statement block. The code in the block will be called with chunks of data. The output looks like this:
```
Wrote 16384 bytes of 16384 total
Wrote 16384 bytes of 32768 total
Wrote 7327 bytes of 40095 total
Wrote 16384 bytes of 56479 total
etc...
```

You can also abort a streaming download by calling `progress.stop` within the block, like this:
```ruby
    sdk.run_look(look_id, format, opts) do |data, progress|
      if some_condition
        progress.stop
      else
        process_data(data)
      end
    end

```

##### Streaming Caveats
* You won't know in advance how many bytes are in the response. Blocks arrive until there aren't any more.
* If the connection to the Looker server is broken while streaming, it will have the same appearance as normal end-of-file stream termination.
* The HTTP status in the response arrives before the response body begins downloading. If an error occurs during the download, it cannot be communicated via HTTP status. It is quite possible to have an HTTP status 200 OK and later discover an error in the data stream. If the connection between the Looker server and the SQL database is severed while you are streaming results, for example, Looker will append an error message to the data you receive and terminate the streaming session.

These caveats can be mitigated by knowing the structure of the data being streamed. Row data in JSON format will be an array of objects, for example. If the data received is missing the closing `]` then you know the stream download ended prematurely.

#### A Tale of Two Stacks

The Looker Ruby SDK is built on top of Sawyer, and Sawyer sits on top of Faraday. Faraday does not support HTTP Streaming, so to do our streaming stuff we have to bypass Faraday and talk directly to the Net:HTTP stack. Our streaming implementation gathers connection settings from the Faraday stack so there's no additional config required for http streaming.

#### Proxy Connections
In order to stream with a proxy connection, you can define your proxy url in your client configs like so:
```
LookerSDK::Client.new(
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET'],
  proxy: ENV['HTTP_PROXY']
)
```

