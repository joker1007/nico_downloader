class NicoDownloader::Info
  attr_accessor :title, :nico_name, :description, :view_count, :mylist_count, :tags, :path, :thumbnail_path

  class << self
    def parse(xml)
      doc = Nokogiri::XML::Document.parse(xml)
      title = doc.at_xpath("//title").text
      nico_name = doc.at_xpath("//video_id").text
      description = doc.at_xpath("//description").text
      view_count = doc.at_xpath("//view_counter").text.to_i
      mylist_count = doc.at_xpath("//mylist_counter").text.to_i
      tags = doc.xpath("//tag").map(&:text)
      new({
        title: title,
        nico_name: nico_name,
        description: description,
        view_count: view_count,
        mylist_count: mylist_count,
        tags: tags,
      })
    end
  end

  def initialize(title: "",
                 nico_name: "",
                 description: "",
                 view_count: "",
                 mylist_count: "",
                 tags: [],
                 path: "",
                 thumbnail_path: "")
    @title = title
    @nico_name = nico_name
    @view_count = view_count
    @mylist_count = mylist_count
    @tags = tags
    @path = path
    @thumbnail_path = thumbnail_path
  end

  def  ==(other)
    title == other.title
    description == other.description
    nico_name == other.nico_name
    view_count == other.view_count
    mylist_count == other.mylist_count
    tags == other.tags
  end
end
