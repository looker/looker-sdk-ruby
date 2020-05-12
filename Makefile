#############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2014 Zee Spencer
# Copyright (c) 2020 Google LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#############################################################################################

# Allows running (and re-running) of tests against several ruby versions,
# assuming you use rbenv instead of rvm.

# Uses pattern rules (task-$:) and automatic variables ($*).
# Pattern rules: http://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_10.html#SEC98
# Automatic variables: http://ftp.gnu.org/old-gnu/Manuals/make-3.79.1/html_chapter/make_10.html#SEC101

# Rbenv-friendly version identifiers for supported Rubys
20_version = 2.0.0-p648
21_version = 2.1.10
23_version = 2.3.1
jruby_9150_version = jruby-9.1.5.0

# The ruby version for use in a given rule.
# Requires a matched pattern rule and a supported ruby version.
#
# Given a pattern rule defined as "install-ruby-%"
# When the rule is ran as "install-ruby-193"
# Then the inner addsuffix call evaluates to "193_version"
# And given_ruby_version becomes "1.9.3-p551"
given_ruby_version = $($(addsuffix _version, $*))

# Instruct rbenv on which Ruby version to use when running a command.
# Requires a pattern rule and a supported ruby version.
#
# Given a pattern rule defined as "test-%"
# When the rule is ran as "test-187"
# Then with_given_ruby becomes "RBENV_VERSION=1.8.7-p375"
with_given_ruby = RBENV_VERSION=$(given_ruby_version)

# Runs tests for all supported ruby versions.
test: test-20 test-21 test-23 test-jruby_9150

# Runs tests against a specific ruby version
test-%:
	rm -f Gemfile.lock
	$(with_given_ruby) bundle lock
	$(with_given_ruby) bundle exec rake test

# Installs all ruby versions and their gems
install: install-20 install-21 install-23 install-jruby_9150

# Install a particular ruby version
install-ruby-%:
	rbenv install -s $(given_ruby_version)

# Install gems into a specific ruby version
install-gems-%:
	rm -f Gemfile.lock
	$(with_given_ruby) gem update --system
	$(with_given_ruby) gem install bundler
	$(with_given_ruby) bundle install

# special case 20 and 21 need older bundler
install-gems-20:
	rm -f Gemfile.lock
	RBENV_VERSION=$(20_version) gem install bundler -v '~>1'
	RBENV_VERSION=$(20_version) bundle install

install-gems-21:
	rm -f Gemfile.lock
	RBENV_VERSION=$(21_version) gem install bundler -v '~>1'
	RBENV_VERSION=$(21_version) bundle install

# Installs a specific ruby version and it's gems
# At the bottom so it doesn't match install-gems and install-ruby tasks.
install-%:
	make install-ruby-$* install-gems-$*
