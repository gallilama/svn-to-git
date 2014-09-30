#!/usr/bin/env ruby

#
# WARNING: Use at your own risk.  This will git rm things from your
# clone.  It was created as a 'nuclear' option to clean up some very
# specific messes with some very specific tools. 
#
# I git rm'd several directories that needed to vanish from recorded history,
# and then I scrubbed the entire history using BFG repo cleaner.
#   e.g.
#   $ cd my_clone
#   $ git_rm_head.rb --dirs big_nasty_dir
#   $ git status && git commit -m "no more nasty" && git push origin master
#   $ bfg --delete-folders '{big_nasty_dir}' <PATH_TO>my_mirror.git
#   $ cd <PATH_TO>my_mirror.git && git reflog expire --expire=now --all
#   $  git gc --prune=now --aggressive
#
# Usage:
#   $ cd <path_to>your_repo.git
#   $ ruby <path_to>git_rm_head.rb --dirs --files
#
# Remember to escape dir, or files names that contain spaces with '\ '.

require 'optparse'
 
options = {}
options[:dirs] = []
options[:files] = []
options[:print_bfg] = false
options[:dry_run] = false

opt_parser = OptionParser.new do |opts|
  opts.banner = "Remove dirs or files.\nUsage: git_rm_head.rb [options]"

  opts.on('-h', '--help', 'Show this message') {
    puts opts
    exit
  }

  opts.on('--dirs a,b,c', Array, 'Directories to remove') {
    |dirs| options[:dirs] = dirs
  }

  opts.on('--files a,b,c', Array, 'Files (relative path) to remove') {
    |files| options[:files] = files
  }

  opts.on('-p', '--print-bfg', 'Print BFG commands') {
    |print_bfg| options[:print_bfg] = print_bfg
  }

  opts.on('-d', '--dry-run', 'Only show git rm assets and BFG commands') {
    |dry_run| options[:dry_run] = dry_run
  }
end.parse!

# get to work!
puts "Dry run, no git commands will be run" if options[:dry_run]
options[:dirs].each do |dir|
  git_rm(dir, options[:dry_run], true)
end

options[:files].each do |file|
  git_rm(file, options[:dry_run])
end

puts "Don't forget to check status and commit / push these modifications." unless options[:dry_run]

print_bfg(options[:dirs], options[:files]) if options[:print_bfg]

BEGIN {
  def git_rm (asset, dry_run, recursive=false)
    puts "removing asset [#{asset}]"
    opts = recursive ? '-r' : ''
    `git rm #{opts} #{asset}` unless dry_run
  end

  # Note: Command output assumes you've aliased bfg='java -jar <PATH>/bfg.jar'
  def print_bfg (dirs, files)
    dir_str = dirs.join(", ") 
    puts "bfg --delete-folders '{#{dir_str}}' <PATH_TO_MIRROR>"
  end

  def debug_options (options)
    options.each_pair do |key, value|
      puts "key is #{key}"
      puts "value is #{value}"
    end
  end
}

