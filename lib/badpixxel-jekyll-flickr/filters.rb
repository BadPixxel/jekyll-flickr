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

  module FlickrFilters

  	# Get All tags for a Flikr PhotoSet
    def flickr_ps_tags(photoset)
      site = @context.registers[:site]
      Jekyll::flickr_setup(site)
    	photoset = Jekyll::flickr_get_photoset(site, photoset)
      if !photoset
        return []
      end

    	return photoset.get_tags() 
    end

  	# Get Most Used tags for a Flikr PhotoSet
    def flickr_ps_top_tags(photoset, count = 10)
      site = @context.registers[:site]
      Jekyll::flickr_setup(site)
    	photoset = Jekyll::flickr_get_photoset(site, photoset)
      if !photoset
        return []
      end

    	return photoset.get_top_tags(count) 
    end

  	# Get Flickr PhotoSet Photos
    def flickr_ps_photos(photoset, max = false)
      site = @context.registers[:site]
    	Jekyll::flickr_setup(site)
    	photoset = Jekyll::flickr_get_photoset(site, photoset)
      if !photoset
        return []
      end

    	return photoset.get_photos_array(max) 
    end    

  	# Get Flickr PhotoSet
    def flickr_photoset(photoset)
      site = @context.registers[:site]
    	Jekyll::flickr_setup(site)
    	photoset = Jekyll::flickr_get_photoset(site, photoset)
      if !photoset
        return []
      end

    	return photoset 
    end    
    
  	# Get Flickr PhotoSet Photo
    def flickr_ps_photo(photoset, photo_id = nil)
      site = @context.registers[:site]
    	Jekyll::flickr_setup(site)
    	photoset = Jekyll::flickr_get_photoset(site, photoset)
      if !photoset
        return []
      end

      if photo_id
        return photoset.get_photo(photo_id)
      end
      
    	return photoset.get_primary_photo()
    end     


  end

end

Liquid::Template.register_filter(Jekyll::FlickrFilters)