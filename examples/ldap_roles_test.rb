###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

############################################################################################
# simulate a list read from file

user_list = <<-ENDMARK

mward
mwhite
missing

ENDMARK

############################################################################################
# helpers

def ldap_config
  @ldap_config ||= sdk.ldap_config.to_attrs
end

def groups_map_for_config
  @groups_map_for_config ||= ldap_config[:groups].map do |group|
    {:name => group[:name], :role_ids => group[:roles].map{|role| role[:id]}}
  end
end

def test_ldap_user(user)
  params = ldap_config.merge({:groups_with_role_ids => groups_map_for_config, :test_ldap_user => user})
  sdk.test_ldap_config_user_info(params)
end

############################################################################################
# process the list and puts results

user_list.each_line do |user|
  user.strip!
  next if user.empty?

  puts "'#{user}' ..."

  result = test_ldap_user(user).to_attrs
  if result[:status] == 'success'
    puts "Success"
    puts result[:user]
  else
    puts "FAILURE"
    puts result
  end
  puts
end
