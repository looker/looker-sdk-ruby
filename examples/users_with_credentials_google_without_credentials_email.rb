###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

users = sdk.all_users(:fields => 'id, is_disabled, credentials_email, credentials_google').
  select {|u| !u.is_diabled && u.credentials_google && u.credentials_google.email && !u.credentials_email}

users.each {|u| puts "#{u.id},#{u.credentials_google.email}"}
