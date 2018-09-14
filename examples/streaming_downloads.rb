###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

# This snippet shows how to download sdk responses using http streaming.
# Streaming processes the download in chunks which you can write
# to file or perform other processing on without having to wait for the entire
# response to download first. Streaming can be very memory efficient
# for handling large result sets compared to just downloading the whole thing into
# a Ruby object in memory.

def run_look_to_file(look_id, filename, format, opts = {})
  File.open(filename, 'w') do |file|
    sdk.run_look(look_id, format, opts) do |data, progress|
      file.write(data)
      puts "Wrote #{data.length} bytes of #{progress.length} total"
    end
  end
end

# Replace the look id (38) with the id of your actual look
run_look_to_file(38, 'out.csv', 'csv', limit: 10000)
