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
