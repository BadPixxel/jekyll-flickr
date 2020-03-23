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

module Jekyll

FLICKR_CACHE_DIR = '_data/flickr'
FLICKR_SIZE_FULL = 'Large'
FLICKR_SIZE_THUMB = 'Small 320'

class FlickrConfig

	def self.resolve(site)
	    # Setup Defaults Plugin Parameters
	    if !site.config['flickr']['cache_dir']
	        site.config['flickr']['cache_dir'] = FLICKR_CACHE_DIR
	    end
	    if !site.config['flickr']['size_full']
	        site.config['flickr']['size_full'] = FLICKR_SIZE_FULL
	    end
	    if !site.config['flickr']['size_thumb']
	        site.config['flickr']['size_thumb'] = FLICKR_SIZE_THUMB
	    end
	    if !site.config['flickr']['generate_posts']
	        site.config['flickr']['generate_posts'] = false
	    end
	    if !site.config['flickr']['generate_photosets']
	        site.config['flickr']['generate_photosets'] = []
	    end
	    if !site.config['flickr'].key?('use_cache')
	        site.config['flickr']['use_cache'] = false
	    end
	    if !site.config['flickr'].key?('flush_cache')
	        site.config['flickr']['flush_cache'] = false
	    end
    end

end

end