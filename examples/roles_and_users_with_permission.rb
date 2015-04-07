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
