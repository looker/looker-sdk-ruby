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
