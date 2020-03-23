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
require 'shellwords'

module Jekyll
    
# Setup Flickr Plugin
def self.flickr_setup(site)
    # Complete Configuration with defaults Parameters
    FlickrConfig.resolve(site)
    # Load Flickr Contents from API
    FlickrLoader.setup(site)
    FlickrLoader.load(site)
end

# Get Flickr Photoset from Cache
def self.flickr_get_photoset(site, photoset_name)
    # Build Photoset Slug
    slug = photoset_name.downcase.gsub(/ /, '-').gsub(/[^a-z\-]/, '')
    # Build Photoset Path
    photoset_file = File.join(site.config['flickr']['cache_dir'], "#{slug}.yml")
    # Check if Photoset is Already in Cache
    if !File.exists?(photoset_file)
        return false
    end

    return Photoset.new(site, photoset_file)
end

class PhotoPost < Post
    def initialize(site, base, dir, photo)
        name = photo.date[0..9] + '-photo-' + photo.slug + '.md'

        data = Hash.new
        data['title'] = photo.title
        data['shorttitle'] = photo.title
        data['description'] = photo.description
        data['date'] = photo.date
        data['slug'] = photo.slug
        data['permalink'] = File.join('/archives', photo.slug, 'index.html')
        data['flickr'] = Hash.new
        data['flickr']['id'] = photo.id
        data['flickr']['url_full'] = photo.url_full
        data['flickr']['url_thumb'] = photo.url_thumb
        
        if site.config['flickr']['generate_frontmatter']
            site.config['flickr']['generate_frontmatter'].each do |key, value|
                data[key] = value
            end
        end
        
        File.open(File.join('_posts', name), 'w') {|f|
            f.print(YAML::dump(data))
            f.print("---\n\n")
            f.print(photo.gen_full_html)
        }

        super(site, base, dir, name)
    end
end

class FlickrPageGenerator < Generator
    safe true
    
    def generate(site)
        Jekyll::flickr_setup(site)
        cache_dir = site.config['flickr']['cache_dir']
        
        file_photosets = Dir.glob(File.join(cache_dir, '*.yml'))
        file_photosets.each_with_index do |file_photoset, pos|
            photoset = Photoset.new(site, file_photoset)
            if site.config['flickr']['generate_photosets'].include? photoset.title
                # generate photo pages if requested
                if site.config['flickr']['generate_posts']
                    file_photos = Dir.glob(File.join(photoset.cache_dir, '*.yml'))
                    file_photos.each do |file_photo, pos|
                        photo = Photo.new(site, photoset, file_photo, pos)
                        page_photo = PhotoPost.new(site, site.source, '', photo)

                        # posts need to be in a _posts directory, but this means Jekyll has already
                        # read in photo posts from any previous run... so for each photo, update
                        # its associated post if it already exists, otherwise create a new post
                        site.posts.each_with_index do |post, pos|
                            if post.data['slug'] == photo.slug
                                site.posts.delete_at(pos)
                            end
                        end
                        site.posts << page_photo
                    end
                end
            end
        end
        
        # re-sort posts by date
        site.posts.sort! {|left, right| left.date <=> right.date}
    end
end

class FlickrPhotosetTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
        super
        params = Shellwords.shellwords markup
        title = params[0]
        @slug = title.downcase.gsub(/ /, '-').gsub(/[^a-z\-]/, '')
    end
    
    def render(context)
        site = context.registers[:site]
        Jekyll::flickr_setup(site)
        file_photoset = File.join(site.config['flickr']['cache_dir'], "#{@slug}.yml")
        photoset = Photoset.new(site, file_photoset)
        return photoset.gen_html
    end
end

class FlickrFancysetTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
        super
        params = Shellwords.shellwords markup
        title = params[0]
        @slug = title.downcase.gsub(/ /, '-').gsub(/[^a-z\-]/, '')
    end
    
    def render(context)
        site = context.registers[:site]
        Jekyll::flickr_setup(site)
        file_photoset = File.join(site.config['flickr']['cache_dir'], "#{@slug}.yml")
        photoset = Photoset.new(site, file_photoset)
        return photoset.gen_html_fancy
    end
end

end

Liquid::Template.register_tag('flickr_photoset', Jekyll::FlickrPhotosetTag)

Liquid::Template.register_tag('flickr_fancyset', Jekyll::FlickrFancysetTag)