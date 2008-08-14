#! /usr/bin/ruby

REFNAME = ARGV[0]
OLDREV = ARGV[1]
NEWREV = ARGV[2]

DATA_DIR = '/srv/git/hooks/server/'

def reject(message)
	$stdout.puts "---------------------------------------------------------"
	$stdout.puts "Commit #{NEWREV} rejected:"
	$stdout.puts "\t#{message}"
	$stdout.puts "---------------------------------------------------------"
	$stdout.flush()
	Kernel::exit(1)
end

locked = `git config hooks.update-lock-check.locked`.split(' ').collect { |element| element.strip() }
preserved = `git config hooks.update-lock-check.preserved`.split(' ').collect { |element| element.strip() }

if(REFNAME =~ /^refs\/heads\/(.+)$/)
	# Branch commit
	commit_branch = $1
	if(locked.include?(commit_branch))
		reject("Branch #{commit_branch} is locked.")
	end

	if(NEWREV =~ /^0{40}$/)
		# Branch deletion
		if(preserved.include?(commit_branch))
			reject("Branch #{commit_branch} cannot be deleted.")
		end
	end
end

Kernel::exit(0)

