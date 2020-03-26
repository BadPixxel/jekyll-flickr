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

class Photo
    attr_accessor :id, :title, :slug, :date, :description, :tags, :date_update, :date_update_str, :url_full, :url_thumb, :cache_file, :position, :from_cache
    
    def initialize(site, photoset, photo, pos)
        self.from_cache = false
        if photo.is_a? String
            self.cache_load(photo)
        else
            self.flickr_load(site, photoset, photo, pos)
        end
    end
    
    def flickr_load(site, photoset, flickr_photo, pos)

        # Check if Photo is Alreday in cache & not outdated
        if !self.cache_outdated(photoset, flickr_photo)
            photo = File.join(photoset.cache_dir, "#{flickr_photo.id}.yml")
            self.cache_load(photo)
            return
        end

        # init
        self.id = flickr_photo.id
        self.title = flickr_photo.title
        self.slug = self.title.downcase.gsub(/ /, '-').gsub(/[^a-z\-]/, '') + '-' + self.id
        self.date = ''
        self.description = ''
        self.tags = Array.new
        self.url_full = ''
        self.url_thumb = ''
        self.cache_file = File.join(photoset.cache_dir, "#{self.id}.yml")
        self.position = pos
        self.date_update = flickr_photo.lastupdate
        self.date_update_str = DateTime.strptime(flickr_photo.lastupdate, '%s').to_s        
        
        # sizes request
        flickr_sizes = flickr.photos.getSizes(:photo_id => self.id)
        if flickr_sizes
            size_full = flickr_sizes.find {|s| s.label == site.config['flickr']['size_full']}
            if size_full
                self.url_full = size_full.source
            end
            
            size_thumb = flickr_sizes.find {|s| s.label == site.config['flickr']['size_thumb']}
            if size_thumb
                self.url_thumb = size_thumb.source
            end
        end
        
        # other info request
        flickr_info = flickr.photos.getInfo(:photo_id => self.id)
        if flickr_info
            self.date = DateTime.strptime(flickr_info.dates.posted, '%s').to_s
            self.description = flickr_info.description
            flickr_info.tags.each do |tag|
                self.tags << tag.raw
            end
        end
        
        cache_store
    end
    
    def cache_exists(photoset, flickr_photo)
        # Check if Photo is Already in Cache
        return File.exists?(File.join(photoset.cache_dir, "#{flickr_photo.id}.yml"))
    end

    def cache_outdated(photoset, flickr_photo)
        cache_file = File.join(photoset.cache_dir, "#{flickr_photo.id}.yml")
        # Check if Photo is Already in Cache
        if !File.exists?(cache_file)
            return true
        end
        # Load Cached Values
        cached = YAML::load(File.read(cache_file))
        if !cached["date_update"] or (cached["date_update"] != flickr_photo.lastupdate)
            return true
        end

        return false
    end    

    def cache_load(file)
        cached = YAML::load(File.read(file))
        self.id = cached['id']
        self.title = cached['title']
        self.slug = cached['slug']
        self.date = cached['date']
        self.description = cached['description']
        self.tags = cached['tags']
        self.url_full = cached['url_full']
        self.url_thumb = cached['url_thumb']
        self.cache_file = cached['cache_file']
        self.position = cached['position']
        self.date_update = cached['date_update']
        self.date_update_str = cached['date_update_str']
        self.from_cache = true
    end
    
    def cache_store
        cached = Hash.new
        cached['id'] = self.id
        cached['title'] = self.title
        cached['slug'] = self.slug
        cached['date'] = self.date
        cached['description'] = self.description
        cached['tags'] = self.tags
        cached['url_full'] = self.url_full
        cached['url_thumb'] = self.url_thumb
        cached['cache_file'] = self.cache_file
        cached['position'] = self.position
        cached['date_update'] = self.date_update
        cached['date_update_str'] = self.date_update_str
        
        File.open(self.cache_file, 'w') {|f| f.print(YAML::dump(cached))}
    end

    def to_liquid

        tags_hash = []
        self.tags.each  do |tag|
            tags_hash += [tag.hash]
        end

        return [
            'id' => self.id,
            'title' => self.title,
            'date' => self.date,
            'description' => self.description,
            'tags' => self.tags,
            'tags_hash' => tags_hash,
            'url_full' =>  self.url_full,
            'url_thumb' =>  self.url_thumb,
            'position' =>  self.position,
            'date_update' =>  self.date_update,
        ]
    end    

    def gen_thumb_html
        content = ''
        if self.url_full and self.url_thumb
            content = "<a href=\"#{self.url_full}\" data-lightbox=\"photoset\"><img src=\"#{self.url_thumb}\" alt=\"#{self.title}\" title=\"#{self.title}\" class=\"photo thumbnail\" width=\"75\" height=\"75\" /></a>\n"
        end
        return content
    end

    def gen_thumb_html_fancy
        content = ''
        if self.url_full and self.url_thumb
            content = "<a href=\"#{self.url_full}\" data-fancybox=\"photoset\"><img src=\"#{self.url_thumb}\" alt=\"#{self.title}\" title=\"#{self.title}\" class=\"img-fluid thumbnail\" /></a>\n"
        end
        return content
    end

    def gen_full_html
        content = ''
        if self.url_full and self.url_thumb
            content = "<p><a href=\"#{self.url_full}\" data-lightbox=\"photoset\"><img src=\"#{self.url_full}\" alt=\"#{self.title}\" title=\"#{self.title}\" class=\"photo full\" /></a></p>\n<p>#{self.description}</p>\n"
            if self.tags
                content += "<p>Tagged <i>" + self.tags.join(", ") + ".</i></p>\n"
            end
        end
        return content
    end
end

end