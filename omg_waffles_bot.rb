#!/usr/bin/env ruby
require 'twitter'

# OMG Waffles Bot (http://twitter.com/omg_waffles)
# A Ruby script written by Gavin Kendall (@gavinmkendall)
#
# ===========================================================================
# Version 1.6 (October 5, 2015)
# Timing and search range adjustments.
#
# Version 1.5 (October 5, 2015)
# Decreased search criteria range.
#
# Version 1.4 (October 4, 2015)
# Added exception handling.
#
# Version 1.3 (October 4, 2015)
# Included sleep timeout when posting updates. Also ignoring any tweets that
# are obviously replies to other people and retweets.
#
# Version 1.2 (October 4, 2015)
# Increased sleep time. Improved console output to display tweet message
# being responded to.
#
# Version 1.1 (October 4, 2015)
# Now it continually searches for the most recent tweet with the phrase
# "i want waffles", sleeps for 30 seconds, and then tries again.
#
# Version 1.0 (October 4, 2015)
# Finds anyone on Twitter tweeting the exact phrase "i want waffles"
# and responds to that particular user with "*gives you waffles".
# Ensures that we don't hassle anyone who has already been responded to.
# ===========================================================================

# This Ruby script was written using the vim editor on a Linux Mint system.
# It needs the Twitter API to be installed (as well as Ruby and g++).
# To get the Twitter API libraries onto your Linux system you'll
# need to run the following command from a Terminal:
# sudo gem install twitter --include-dependencies


# Read in the keys that will be used with the Twitter API.
# The "keys" file needs to contain the consumer key, consumer secret,
# access token, and access token secret keys with their associated values.
#
# These key values are from the "omg_waffles_bot" Twitter app at https://apps.twitter.com/
# and are used during the interaction with the Twitter API. Since I'm the only person in
# the world who is supposed to know the values of these keys for my Twitter app the safest
# way to acquire the key values while distributing my Ruby script is by storing those keys
# and their associated values in a file named "keys". This file should be kept in the same
# directory as this Ruby script.
#
# The lines in the "keys" file should look something like this ...
# CONSUMER_KEY = 123456789
# CONSUMER_SECRET = 123456789
# ACCESS_TOKEN = 123456789
# ACCESS_TOKEN_SECRET = 123456789

if File.file?("keys")
	keys = Hash.new()
	File.open("keys", "r") do |infile| # Open the "keys" file
		while (line = infile.gets)
			key = line.split("=") # Split each line found in the file by "="

			# Store the key/value pairs in the hash
			# For example, CONSUMER_KEY is from key[0] and is used as the hash key
			# whereas 123456789 is from key[1] and is used as the hash value.
			keys[key[0].strip] = key[1].strip
		end
	end

	# Setup the Twitter client and give the client the necessary keys from the "keys" file.
	client = Twitter::REST::Client.new do |config|
		config.consumer_key = keys["CONSUMER_KEY"]
		config.consumer_secret = keys["CONSUMER_SECRET"]
		config.access_token = keys["ACCESS_TOKEN"]
		config.access_token_secret = keys["ACCESS_TOKEN_SECRET"]
	end

	# Checks if the userlist file exists. If it doesn't exist it'll just create it.
	if File.file?("userlist") then else File.open("userlist", "w") end

	users = Array.new()
	File.open("userlist", "r") do |infile|
		while (line = infile.gets)
			users.push(line)
		end
	end

	# Use the Twitter API to continually search for tweets that contain the exact phrase "i want waffles".
	while 1 == 1
		begin
			puts "Searching for people who want waffles ..."

			client.search("\"i want waffles\"").take(1).each do |tweet|
				if !users.include?("%s\n" % tweet.user.screen_name) # Make sure we haven't responded to this user yet

					if !tweet.text.start_with?("@") and !tweet.text.start_with?("RT") # Make sure we don't respond to tweets that are replies or retweets

						# Respond to the user with "*gives you waffles"
						client.update("@%s %s" % [tweet.user.screen_name, "*gives you waffles"])

						puts "I found someone! I've given waffles to @%s (%s) because they said \"%s\"" % [tweet.user.screen_name, tweet.user.name, tweet.text]
			
						# Write the user's tweet's created date, username (screen name), display name, and tweet message to the log file
						open("log.txt", "a") do |outfile|
							outfile.puts "%s @%s (%s) %s" % [tweet.created_at, tweet.user.screen_name, tweet.user.name, tweet.text]
						end
			
						# Write the user's screen name to the userlist file so we don't bother them whenever this script is executed
						open("userlist", "a") do |outfile|
							outfile.puts tweet.user.screen_name
						end

						# Add the user to the user array so we know to ignore them on the next iteration
						# while we're looping through the tweets of those who have clearly wanted waffles
						users.push("%s\n" % tweet.user.screen_name)
					end
				else
					puts "I've already given waffles to %s (%s)" % [tweet.user.screen_name, tweet.user.name]
				end
			end

			puts "Sleeping for an hour before searching again ..."
			sleep 3600 # Sleep for 60 minutes before we search again. Let's be nice to Twitter
		rescue
			puts "An error occurred. Sleeping for a couple of minutes before searching again ..."
			sleep 120
		end
	end
else
	puts "I couldn't find the keys file to import your Twitter API keys and tokens"
end
