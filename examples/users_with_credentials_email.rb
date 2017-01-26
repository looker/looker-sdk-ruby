require './sdk_setup'

users = sdk.all_users(:fields => 'id, is_disabled, credentials_email').
  select {|u| !u.is_diabled && u.credentials_email && u.credentials_email.email}

users.each {|u| puts "#{u.id},#{u.credentials_email.email}"}
