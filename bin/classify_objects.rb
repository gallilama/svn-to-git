#!/usr/bin/env ruby

#
# Find n-largest objects in a Git repo, and determine if files are
# (or aren't) in HEAD.  Thanks to Confluence's migration post,
# and git-scm.org for the guts.
#
# Usage:
#   $ cd <path_to>your_repo.git
#   $ ruby <path_to>classify_objects.rb
#     Classifying 10 largest objects in repo
#     ..........
#     1/10 Objects NOT IN HEAD:
#     path/object.uno
#     9/10 Obejcts IN HEAD:
#     path/object.dos
#     ...

require 'optparse'
 
GIT_DIR = '.git/objects/pack/'
GIT_GLOB = '*.idx'
GIT_FILES = GIT_DIR + GIT_GLOB

not_in_head = []
in_head = []

options = {}
options[:number] = 10
options[:gitgc] = false
options[:detailed] = false

opt_parser = OptionParser.new do |opts|
  opts.banner = "Find n-largest objects in a Git repo, and determine if files are (or aren't) in HEAD.  \nUsage: classify_large_objects.rb [options]"

  opts.on('-h', '--help', 'Show this message') {
    puts opts
    exit
  }

  opts.on('-n', '--num-objects NUMBER', 'Number of objects to classify (default is 10)') {
    |number| options[:number] = number
  }

  opts.on('-g', '--git-gc', 'Run git gc first') {
    |gitgc| options[:gitgc] = gitgc
  }

  opts.on('-d', '--detailed', 'Detailed output (.e.g. path, size, sha1)') {
    |detailed| options[:detailed] = detailed
  }
end.parse!

# get to work!
abort("Can't find directory, #{GIT_DIR}, cd to root of your repo.") unless Dir.exists?(GIT_DIR)

puts "Running git gc" && `git gc` if options[:gitgc]

abort("No #{GIT_FILES} files found, run `git gc`") if (Dir.glob(GIT_FILES).size < 1)

num_objects = options[:number]
details = ''

puts "Classifying #{num_objects} largest objects in repo"

`git verify-pack -v #{GIT_FILES} | sort -k 3 -n --reverse | head -#{num_objects}`.split("\n").each do |line|
  print "."

  sha1, type, size, *rest = line.split
  size_pretty = sprintf "%.2f", size.to_f/1024.0**2

  details = ", size: #{size_pretty} Mb, type: #{type}, sha1: #{sha1}" if options[:detailed]

  # Original version had trouble with paths or files with spaces:
  #   e.g. path = `git rev-list --objects --all | \grep #{sha1}`.split.last
  # Making an assumption that sha1 will be first element from `git rev-list`
  revlist = `git rev-list --objects --all | \grep #{sha1}`
  path = revlist.slice(41..-1).chomp;

  if File.file?(path)
    in_head << path + details
  else
    not_in_head << path + details
  end
end

# TODO: Has got to be a better way to output reports
puts "\n\n#{not_in_head.length}/#{num_objects} Objects NOT IN HEAD:\n"
not_in_head.each do |path|
  puts path
end

puts "\n\n#{in_head.length}/#{num_objects} Objects IN HEAD:\n"
in_head.each do |path|
  puts path
end

