##
## Embed Flickr photos in a Jekyll blog.
##
## Copyright (C) 2015 Lawrence Murray, www.indii.org.
## Copyright (C) 2020 BadPixxel, www.badpixxel.com.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the Free
## Software Foundation; either version 2 of the License, or (at your option)
## any later version.
##

require 'flickraw'

module Jekyll

class FlickrLoader

    attr_accessor :is_loaded

    @@is_loaded = false

	def self.load(site)

		if @@is_loaded 
	    	puts "Flickr: Photosets Already Loaded"
			return
		end

	    # Setup Defaults Plugin Parameters
	    if not self.is_ready(site)
	    	puts "Flickr: Using Cached Photosets"
	    	return
	    end
    	puts "Flickr: Update of Photosets cache"

    	# Fetch list of Photosets
        nsid = flickr.people.findByUsername(:username => site.config['flickr']['screen_name']).id
        flickr_photosets = flickr.photosets.getList(:user_id => nsid)

    	# Update All Photosets Cache
        flickr_photosets.each do |flickr_photoset|
            photoset = Photoset.new(site, flickr_photoset)
    		puts "Flickr: Update Photosets #{flickr_photoset.title} (#{photoset.photos_from_cache} In Cache, #{photoset.photos_from_flickr} Loaded from Flickr)"
        end

        @@is_loaded = true
    	puts "Flickr: Photosets cache updated"

    end

	def self.is_ready(site)
	    # Check if Plugin Parameters Allow Cache Loading
	    if site.config['flickr']['use_cache']
	    	return false
	    end
	    if !site.config['flickr']['cache_dir']
	    	return false
	    end

    	return true
    end    
    
	def self.setup(site)

        cache_dir = site.config['flickr']['cache_dir']
        # Clear any existing cache if requested
        if site.config['flickr']['flush_cache']
	        if Dir.exists?(cache_dir)
	            FileUtils.rm_rf(cache_dir)
	        end
        end
        # Ensure Cache Dir Exists
        if !Dir.exists?(cache_dir)
            Dir.mkdir(cache_dir)
        end
        # Populate cache from Flickr
        FlickRaw.api_key = site.config['flickr']['api_key']
        FlickRaw.shared_secret = site.config['flickr']['api_secret']
    end  

end

end