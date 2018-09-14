require 'looker-sdk'
require 'json'

# Note that this example requires API 3.1

sdk = LookerSDK::Client.new(
  :client_id => ENV['KEY'],
  :client_secret => ENV['SECRET'],

  # API URL would look like: https://myhost.com:port/api/3.1
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
