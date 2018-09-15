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

Joe Williams, joe@mycoolcompany.com, Admin
Jane Schumacher, jane@mycoolcompany.com, User SuperDeveloper
Jim Watson, jim@mycoolcompany.com, User
Jim Wu, jimw@mycoolcompany.com, User

ENDMARK

############################################################################################

def create_users(lines)
  # create a hash to use below. role.name => role.id
  roles_by_name = Hash[ sdk.all_roles.map{|role| [role.name, role.id] } ]

  # for each line, try to create that user with name, email credentials, and roles
  lines.each_line do |line|
    line.strip!
    next if line.empty?

    # quicky parsing: note lack of error handling!

    name, email, roles = line.split(',')
    fname, lname = name.split(' ')
    [fname, lname, email, roles].each(&:strip!)

    role_ids = []
    roles.split(' ').each do |role_name|
      if id = roles_by_name[role_name]
        role_ids << id
      else
        raise "#{role_name} does not exist. ABORTING!"
      end
    end

    # for display
    user_info = "#{fname} #{lname} <#{email}> as #{roles}"

    begin
      # call the SDK to create user with names, add email/password login credentials, set user roles
      user = sdk.create_user({:first_name => fname, :last_name => lname})
      sdk.create_user_credentials_email(user.id, {:email => email})
      sdk.set_user_roles(user.id, role_ids)
      puts "Created user: #{user_info}"
    rescue LookerSDK::Error => e
      # if any errors occur above then 'undo' by deleting the given user (if we got that far)
      sdk.delete_user(user.id) if user
      puts "FAILED to create user: #{user_info} (#{e.message}) "
    end
  end
end

##################################################################

def delete_users(lines)
  # create a hash to use below. user.credentials_email.email => user.id
  users_by_email = Hash[ sdk.all_users.map{|user| [user.credentials_email.email, user.id] if user.credentials_email}.compact ]

  lines.each_line do |line|
    line.strip!
    next if line.empty?

    # quicky parsing: note lack of error handling!
    name, email, roles = line.split(',')
    fname, lname = name.split(' ')
    [fname, lname, email, roles].each(&:strip!)

    # for display
    user_info = "#{fname} #{lname} <#{email}>"

    begin
      if id = users_by_email[email]
        sdk.delete_user(id)
        puts "Deleted user: #{user_info}>"
      else
        puts "Did not find user: #{user_info}>"
      end
    rescue LookerSDK::Error => e
      puts "FAILED to delete user: #{user_info} (#{e.message}) "
    end
  end
end

##################################################################

# call the methods
create_users(user_list)
puts
delete_users(user_list)
