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


while true do
  print "permission [,model]? "
  permission_name, model_name = gets.chomp.split(',')

  break if permission_name.empty?

  roles = sdk.all_roles.select do |role|
    (role.permission_set.all_access || role.permission_set.permissions.join(',').include?(permission_name)) &&
    (model_name.nil? || role.model_set.all_access || role.model_set.models.join(',').include?(model_name))
  end

  puts "Roles: #{roles.map(&:name).join(', ')}"

  role_ids = roles.map(&:id)
  users = sdk.all_users.select {|user| (user.role_ids & role_ids).any?}
  user_names = users.map{|u| "#{u.id}#{" ("+u.display_name+")" if u.display_name}"}.join(', ')

  puts "Users: #{user_names}"
end
