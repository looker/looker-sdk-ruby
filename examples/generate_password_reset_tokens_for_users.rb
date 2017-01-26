require './sdk_setup'

$stdin.each_line do |line|
  line.chomp!

  id = line.split(',', 2).map(&:strip).first

  begin
    user = sdk.user(id)
    if user.credentials_email
      token = sdk.create_user_credentials_email_password_reset(id)
      puts "#{token.email},#{token.password_reset_url}"
    else
      puts "Error: User with id '#{id}' Does not have credentials_email"
    end
  rescue LookerSDK::NotFound
    puts "Error: User with id '#{id}' Not found"
  end
end
