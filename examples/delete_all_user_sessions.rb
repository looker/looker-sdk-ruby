###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

total_count = 0
sdk.all_users(:fields => 'id, display_name').each do |user|
  count = 0
  sdk.all_user_sessions(user.id, :fields => 'id').each do |session|
    sdk.delete_user_session(user.id, session.id)
    count += 1
  end
    puts "Deleted #{count} sessions for #{user.id} #{user.display_name}"
    total_count += count
end
puts "Deleted #{total_count} sessions"


