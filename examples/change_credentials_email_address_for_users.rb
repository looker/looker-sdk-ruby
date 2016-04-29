require './sdk_setup'

users = Hash[
    sdk.all_users(:fields => 'id, credentials_email').
      map{|u| [u.credentials_email.email, u.id] if u.credentials_email }.compact
    ]

$stdin.each_line do |line|
  line.chomp!

  _, old_email, new_email = line.split(',', 3).map(&:strip)

  if id = users[old_email]
    begin
      sdk.update_user_credentials_email(id, {:email => new_email})
      puts "Successfully changed '#{old_email}' => '#{new_email}'"
    rescue => e
      puts "FAILED to changed '#{old_email}' => '#{new_email}' because of: #{e.class}:#{e.message}"
    end
  else
    puts "FAILED: Could not find user with email '#{old_email}'"
  end
end
