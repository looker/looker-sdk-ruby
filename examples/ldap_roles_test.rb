############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015 Looker Data Sciences, Inc.
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
