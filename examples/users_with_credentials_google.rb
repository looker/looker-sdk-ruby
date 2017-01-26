# sdk.all_users(:fields => 'id,credentials_google').select{|u| u.credentials_google}.map{|u| u.id}

require './sdk_setup'

users = sdk.all_users(:fields => 'id, credentials_google').
  select {|u| u.credentials_google}

users.each {|u| puts "#{u.id},#{u.credentials_google.email}"}
