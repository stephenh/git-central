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

if(REFNAME =~ /^refs\/heads\/(.+)$/)
	# Branch commit
	commit_branch = $1
	locked_branches = IO::readlines(DATA_DIR + 'locked_branches').collect!(){|element| element.strip()}
	if(locked_branches.include?(commit_branch))
		reject("Branch '#{commit_branch}' is locked.")
	end

	if(NEWREV =~ /^0{40}$/)
		# Branch deletion
		preserved_branches = IO::readlines(DATA_DIR + 'preserved_branches').collect!(){|element| element.strip()}
		if(preserved_branches.include?(commit_branch))
			reject("Branch '#{commit_branch}' cannot be deleted.")
		end
	end
end

Kernel::exit(0)

