#
# Copyright (c) 2014 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'bundler'
require 'yaml'

EDITIFICATION_HISTORY_FILE_PATH = ::File.join(::ENV['HOME'], '.editification_history.yml')

def do_list
  gem_name_to_locations_map = query_editified_gems
  if gem_name_to_locations_map.empty?
    puts 'No gems are currently symlinked.'
  else
    gem_name_to_locations_map.each do |gem_name, locations|
      puts "#{gem_name} is symlinked from #{locations[:bundler].inspect} to #{locations[:user].inspect}"
    end
  end
  true
end

def do_push
  gem_name_to_locations_map = query_editified_gems
  if gem_name_to_locations_map.empty?
    puts 'No gems are currently symlinked.'
  else
    editification_history = read_editification_history
    (editification_history[editification_history_key] ||= []) << gem_name_to_locations_map
    write_editification_history(editification_history)
    reset_editified_gems(gem_name_to_locations_map.keys)
    bundle_check_or_install
    puts "\nGems pushed successfully. It is now safe to bundle update, etc."
  end
  true
end

def do_pop
  current_gem_name_to_locations_map = query_editified_gems
  editification_history = read_editification_history
  key = editification_history_key
  unless popped_gem_name_to_locations_map = (editification_history[key] || []).pop
    fail 'No history to pop for working directory.'
  end
  editification_history.delete(key) if editification_history[key].empty?
  write_editification_history(editification_history)

  setup_gem_name_to_locations_map = {}
  popped_gem_name_to_locations_map.keys.each do |gem_name|
    unless current_gem_name_to_locations_map[gem_name] == popped_gem_name_to_locations_map[gem_name]
      setup_gem_name_to_locations_map[gem_name] = popped_gem_name_to_locations_map[gem_name]
    end
  end
  reset_gem_names = current_gem_name_to_locations_map.keys.reject do |gem_name|
    current_gem_name_to_locations_map[gem_name] == popped_gem_name_to_locations_map[gem_name]
  end
  unless reset_gem_names.empty?
    reset_editified_gems(reset_gem_names)
  end
  unless setup_gem_name_to_locations_map.empty?
    setup_editified_gems(setup_gem_name_to_locations_map)
  end
  bundle_check_or_install
  puts "\nGems popped successfully. Be sure to push again before calling bundle update."
  true
end

def do_reset
  reset_editified_gems(query_editified_gems.keys)
  editification_history = read_editification_history
  if editification_history.delete(editification_history_key)
    write_editification_history(editification_history)
  end
  bundle_check_or_install
  true
end

def query_editified_gems
  bundle_check_or_install

  # most efficient way to query gems is to use Bundler internals. this code is
  # borrowed from Bundler::CLI#show
  editified_gems = {}
  Bundler.load.specs.sort_by { |s| s.name }.each do |s|
    bundled_gem_location = s.full_gem_path
    if ::File.symlink?(bundled_gem_location)
      user_location = ::File.readlink(bundled_gem_location)
      editified_gems[s.name] = {
        bundler: bundled_gem_location,
        user:    user_location
      }
    end
  end
  editified_gems
end

def setup_editified_gems(gem_name_to_locations_map)
  gem_name_to_locations_map.each do |gem_name, locations|
    # ignore any previous bundler location for gem and get latest.
    fail 'Unexpected missing user location' unless user_location = locations[:user]
    bundled_gem_location = `bundle show #{gem_name}`.chomp
    if ::File.symlink?(bundled_gem_location)
      ::File.unlink(bundled_gem_location)
    else
      # note the following could be written as File.symlink, etc., but we
      # want to perform the same shell commands as the outer shell script to
      # ensure consistent behavior.
      puts "Removing original #{gem_name} from #{bundled_gem_location}"
      `rm -Rf #{bundled_gem_location}`
      unless $?.success?
        fail "Failed to remove cached gem directory: #{bundled_gem_location}"
      end
    end

    puts "Pointing Bundler to the local-disk version of #{gem_name} at #{user_location}"
    `ln -sf #{user_location} #{bundled_gem_location}`
    unless $?.success?
      fail "Failed to symlink gem directory: #{bundled_gem_location}"
    end
  end
  true
end

def reset_editified_gems(gem_names)
  if gem_names.empty?
    puts 'No gems require a reset.'
  else
    gem_names.each do |gem_name|
      bundled_gem_location = `bundle show #{gem_name}`.chomp
      if ::File.symlink?(bundled_gem_location)
        ::File.unlink(bundled_gem_location)
        puts "Removed symlink for #{gem_name}."
      else
        puts "Skipped #{gem_name} due to not being symlinked."
      end
    end
  end
  true
end

def bundle_check_or_install
  `bundle check >/dev/null 2>&1`
  unless $?.success?
    puts "\nNOTE: Performing bundle install..."
    puts `bundle install`
    fail 'Failed bundle install' unless $?.success?
  end
  true
end

def editification_history_key
  ::File.expand_path(::Dir.pwd)
end
          
def read_editification_history
  if ::File.file?(EDITIFICATION_HISTORY_FILE_PATH)
    contents = ::File.read(EDITIFICATION_HISTORY_FILE_PATH)
    ::YAML.load(contents)
  else
    {}
  end
end

def write_editification_history(editification_history)
  if editification_history.empty?
    if ::File.file?(EDITIFICATION_HISTORY_FILE_PATH)
      ::File.unlink(EDITIFICATION_HISTORY_FILE_PATH)
    end
  else
    ::File.open(EDITIFICATION_HISTORY_FILE_PATH, 'w') do |f|
      f.puts ::YAML.dump(editification_history)
    end
  end
end

# execute
begin
case ARGV[0]
when '--list'
  do_list
when '--push'
  do_push
when '--pop'
  do_pop
when '--reset'
  do_reset
else
  fail "Unknown argument(s): #{ARGV.inspect}"
end
rescue Exception => e
  puts e.message
  exit 1
end
