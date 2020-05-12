#############################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2014 Zee Spencer
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
187_version = 1.8.7-p375
193_version = 1.9.3-p551
20_version = 2.0.0-p598
21_version = 2.1.5

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

# Watch the fileystem and re-execute a command
rerun = fswatch -o . | xargs -n1 -I{}

# Runs tests for all supported ruby versions.
test: test-187 test-193 test-20 test-21

# Runs tests against a specific ruby version
test-%:
	$(with_given_ruby) bundle exec ruby test/all.rb

# Watches for changes in the filesystem and re-runs tests for a given ruby.
retest-%:
	$(rerun) make test-$*

# Installs all ruby versions and their gems
install: install-187 install-193 install-20 install-21


# Install a particular ruby version
install-ruby-%:
	rbenv install -s $(given_ruby_version)

# Install gems into a specific ruby version
install-gems-%:
	$(with_given_ruby) gem install bundler
	$(with_given_ruby) bundle install


# Installs a specific ruby version and it's gems
# At the bottom so it doesn't match install-gems and install-ruby tasks.
install-%:
	make install-ruby-$* install-gems-$*
