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

class Photoset
    attr_accessor :id, :title, :description, :date_update, :date_update_str, :slug, :cache_dir, :cache_file, :photos, :photos_from_cache, :photos_from_flickr
    
    def initialize(site, photoset)
        self.photos = Array.new
        self.photos_from_cache = 0
        self.photos_from_flickr = 0
        if photoset.is_a? String
            self.cache_load(site, photoset)
        else
            self.flickr_load(site, photoset)
        end
        self.photos.sort! {|left, right| left.position <=> right.position}
    end
    
    # Load Photoset from Flckr (if needed) 
    def flickr_load(site, flickr_photoset)
        self.id = flickr_photoset.id
        self.title = flickr_photoset.title
        self.description = flickr_photoset.description
        self.date_update = flickr_photoset.date_update
        self.date_update_str = DateTime.strptime(flickr_photoset.date_update, '%s').to_s
        self.slug = self.title.downcase.gsub(/ /, '-').gsub(/[^a-z\-]/, '')
        self.cache_dir = File.join(site.config['flickr']['cache_dir'], self.slug)
        self.cache_file = File.join(site.config['flickr']['cache_dir'], "#{self.slug}.yml")
        
        # write to cache
        if self.cache_outdated(flickr_photoset)
            self.cache_store
        end

        # create cache directory
        if !Dir.exists?(self.cache_dir)
            Dir.mkdir(self.cache_dir)
        end
        
        # photos
        flickr_photos = flickr.photosets.getPhotos(:photoset_id => self.id, :extras => "date_taken, last_update").photo
        flickr_photos.each_with_index do |flickr_photo, pos|
            photo = Photo.new(site, self, flickr_photo, pos)
            self.photos << photo
            if photo.from_cache 
                self.photos_from_cache += 1
            else
               self.photos_from_flickr += 1
           end
        end
    end
    
    # Check if Photoset Cachge is Outdated
    def cache_outdated(flickr_photoset)
        # Check if Photoset is Already in Cache
        if !File.exists?(self.cache_file)
            return true
        end
        # Load Cached Values
        cached = YAML::load(File.read(cache_file))
        if !cached["date_update"] or (cached["date_update"] != flickr_photoset.date_update)
            return true
        end

        return false
    end    

    # Load Photoset from Cache
    def cache_load(site, file)
        cached = YAML::load(File.read(file))
        self.id = cached['id']
        self.title = cached['title']
        self.description = cached['description']
        self.date_update = cached['date_update']
        self.date_update_str = cached['date_update_str']
        self.slug = cached['slug']
        self.cache_dir = cached['cache_dir']
        self.cache_file = cached['cache_file']
        
        file_photos = Dir.glob(File.join(self.cache_dir, '*.yml'))
        file_photos.each_with_index do |file_photo, pos|
            self.photos << Photo.new(site, self, file_photo, pos)
        end
    end

    # Store Photoset in Cache
    def cache_store
        cached = Hash.new
        cached['id'] = self.id
        cached['title'] = self.title
        cached['description'] = self.description
        cached['date_update'] = self.date_update
        cached['date_update_str'] = self.date_update_str
        cached['slug'] = self.slug
        cached['cache_dir'] = self.cache_dir
        cached['cache_file'] = self.cache_file
        
        File.open(self.cache_file, 'w') {|f| f.print(YAML::dump(cached))}
    end

    # Get List of Most used tags    
    def get_top_tags(count)
        # Build List of tags [ "tag" => count ]
        all_tags = {}
        self.photos.each do |photo|
            photo.tags.each do |tag|
                if all_tags.has_key?(tag)
                    all_tags[tag] += 1
                else
                    all_tags[tag] = 1
                end
            end
        end
        # Sort & Filter tags
        sorted_tags = all_tags.sort_by {|_key, value| value}.reverse.first(count).to_h
        # Build Hashed Tags List
        hashed_tags = []
        sorted_tags.each do |tag_str, count|
            hashed_tags += [ "tag" => tag_str, "hash" => tag_str.hash, "count" => count ]
        end

        return hashed_tags
    end

    # Get List of All Photoset Tags    
    def get_tags()
        # Build List of tags [ "tag" => count ]
        all_tags = {}
        self.photos.each do |photo|
            photo.tags.each do |tag|
                if all_tags.has_key?(tag)
                    all_tags[tag] += 1
                else
                    all_tags[tag] = 1
                end
            end
        end
        # Build Hashed Tags List
        hashed_tags = []
        all_tags.each do |tag_str, count|
            hashed_tags += [ "tag" => tag_str, "hash" => tag_str.hash, "count" => count ]
        end

        return hashed_tags
    end      

    # Get List of All Photoset Photos   
    def get_photos_array(max = false)
        # Build List of Photos [ "tag" => count ]
        if max != false 
            photos = self.photos.first(max)
        else
            photos = self.photos
        end

        collection = []
        photos.each do |photo|
            collection += photo.to_liquid
        end

        return collection
    end 

    def gen_html
        content = ''
        self.photos.each do |photo|
            content += photo.gen_thumb_html
        end
        return content
    end

    def gen_html_fancy
        content = ''
        self.photos.each do |photo|
            content += photo.gen_thumb_html_fancy
        end
        return content
    end 
end

end