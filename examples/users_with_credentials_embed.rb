###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

users = sdk.all_users(fields:'id, is_disabled, display_name, credentials_embed').map do |u|
  next if u.is_diabled || u.credentials_embed.empty?
  creds = u.credentials_embed.first
  [u.id, u.display_name, creds.external_user_id, creds.external_group_id, creds.logged_in_at]
end.compact

users.each{|u| p u}
