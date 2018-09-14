###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

users = sdk.all_users(:fields => 'id, credentials_google').
  select {|u| u.credentials_google}

users.each {|u| puts "#{u.id},#{u.credentials_google.email}"}
