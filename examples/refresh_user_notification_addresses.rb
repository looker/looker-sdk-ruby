###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

sdk.all_users(:fields => 'id,email').each do |user|
  new_user = sdk.update_user(user.id, {})
  if user.email == new_user.email
    puts "No Change for #{user.id}"
  else
    puts "Refreshed #{user.id}. Old email '#{user.email}'. Refreshed email: '#{new_user.email}'."
  end
end
