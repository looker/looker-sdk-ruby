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

require 'looker-sdk'
require 'json'

# Note that this example requires API 3.1 for new dashboard element manipulation functions

sdk = LookerSDK::Client.new(
  :client_id => ENV['KEY'],
  :client_secret => ENV['SECRET'],

  # API 3.1 URL would look like: https://myhost.com:19999/api/3.1
  :api_endpoint => ENV['URL']
)
#Set the dashboard here.
dashboard_id = ENV['DASHBOARD_ID']
# Get the dashboard we want to convert and get elements

dashboard = sdk.dashboard(dashboard_id).to_h

elements = dashboard[:dashboard_elements]
if dashboard then puts "Dashboard has been received" end

for element in elements

  # Extract important IDs

  element_id = element[:id]
  look_id = element[:look_id]
  query_id = element[:query_id]

  # If look_id is non-null and query_id is null, tile is a Look-based tile
  if look_id && query_id.nil?

    # Get the Look so we can get its query_id
    look = sdk.look(look_id).to_h
    query_id = look[:query_id]

    # Update the tile to have a null look_id and update query_id
    sdk.update_dashboard_element(element_id,
      {
        "look_id": nil,
        "query_id": query_id,
      }
    )
    puts "Tile #{element_id.to_s} has been updated in Dashboard #{dashboard_id.to_s}"

  end
end
