require './sdk_setup'

$stdin.each_line do |line|
  line.chomp!

  id, _ = line.split(',', 2).map(&:strip)

  begin
    user = sdk.user(id)
    if user.credentials_google
      sdk.delete_user_credentials_google(id)
      puts "Success: Deleted credentials_google for User with id '#{id}'"
    else
      puts "Error: User with id '#{id}' Does not have credentials_google"
    end
  rescue LookerSDK::NotFound
    puts "Error: User with id '#{id}' Not found"
  end
end
