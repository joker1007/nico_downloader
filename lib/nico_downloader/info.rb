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
end
