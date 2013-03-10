require "time"

class NicoDownloader::Info
  attr_accessor :title, :vid, :description, :view_count, :mylist_count, :duration, :posted_at, :tags, :path, :thumbnail_path

  class << self
    def parse(xml)
      doc = Nokogiri::XML::Document.parse(xml)

      title = doc.at_xpath("//title").text
      vid = doc.at_xpath("//video_id").text
      description = doc.at_xpath("//description").text
      view_count = doc.at_xpath("//view_counter").text.to_i
      mylist_count = doc.at_xpath("//mylist_counter").text.to_i
      tags = doc.xpath("//tag").map(&:text)
      duration = parse_length(doc.xpath("//length").text)
      posted_at = Time.parse(doc.xpath("//first_retrieve").text)

      new(
        title: title,
        vid: vid,
        description: description,
        view_count: view_count,
        mylist_count: mylist_count,
        tags: tags,
        duration: duration,
        posted_at: posted_at
      )
    end

    def from_directory(directory_path, info_path: nil, movie_path: nil, thumbnail_path: nil)
      dir = Dir.open(directory_path)

      unless movie_path
        movie_filename = dir.entries.find {|name| name =~ /\.(mp4|flv|avi|mpg|mkv|wmv|divx|m4v)$/i}
        movie_path = movie_filename ? File.join(directory_path, movie_filename) : raise("Movie file is nothing")
      end

      unless info_path
        info_filename = dir.entries.find {|name| name =~ /_info\.xml$/i}
        info_path = info_filename ? File.join(directory_path, info_filename) : raise("Info file is nothing")
      end

      unless thumbnail_path
        filename = dir.entries.find {|name| name =~ /\.(jpg|png)$/i}
        thumbnail_path = filename ? File.join(directory_path, filename) : nil
      end

      info = parse(File.read(info_path))
      info.path = movie_path
      info.thumbnail_path = thumbnail_path
      info
    end

    private
    def parse_length(str)
      str =~ /(\d+):(\d+)/
      minutes = $1.to_i * 60
      second = $2.to_i
      minutes + second
    end
  end

  def initialize(title: "",
                 vid: "",
                 description: "",
                 view_count: "",
                 mylist_count: "",
                 duration: 0,
                 posted_at: Time.now,
                 tags: [],
                 path: "",
                 thumbnail_path: "")
    @title = title
    @vid = vid
    @description = description
    @view_count = view_count
    @mylist_count = mylist_count
    @tags = tags
    @path = path
    @thumbnail_path = thumbnail_path
    @duration = duration
    @posted_at = posted_at
  end

  def ==(other)
    title == other.title &&
    description == other.description &&
    vid == other.vid &&
    view_count == other.view_count &&
    mylist_count == other.mylist_count &&
    duration == other.duration &&
    posted_at == other.posted_at &&
    tags == other.tags
  end

  def parse(xml)
    other_info = self.class.parse(xml)

    self.title = other_info.title
    self.vid = other_info.vid
    self.description = other_info.description
    self.view_count = other_info.view_count
    self.mylist_count = other_info.mylist_count
    self.duration = other_info.duration
    self.posted_at = other_info.posted_at
    self.tags = other_info.tags
    self
  end
end
