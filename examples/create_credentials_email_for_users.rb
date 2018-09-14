###################################################
#
# Looker API client SDK for Ruby
#
# Copyright (c) 2014-2018 Looker Data Sciences, Inc
#
###################################################

require './sdk_setup'

$stdin.each_line do |line|
  line.chomp!

  id, email = line.split(',', 2).map(&:strip)

  begin
    user = sdk.user(id)
    if user.credentials_email
      puts "Error: User with id '#{id}' Already has credentials_email"
    else
      sdk.create_user_credentials_email(id, {:email => email})
      puts "Success: Created credentials_email for User with id '#{id}' and email '#{email}'"
    end
  rescue LookerSDK::NotFound
    puts "Error: User with id '#{id}' Not found"
  end
end
