require "nico_downloader/version"
require "nico_downloader/info"

require "mechanize"
require "lumberjack"
require "pit"
require "rss"
require "fileutils"
require "tapp"

class NicoDownloader
  attr_accessor :agent, :error_count, :rss_error_count, :on_download_complete
  attr_reader :mail, :pass, :logger

  VIDEO_TYPE_TABLE = {"v" => "flv", "m" => "mp4", "s" => "swf"}
  SLEEP_TIME_PER_DOWNLOAD = 3
  THUMBNAIL_SIZE = "160x120".freeze

  def initialize(logger = :stdout)
    agent_init
    account = Pit.get("niconico", :require => {
      "mail" => "you email in niconico",
      "pass" => "your password in niconico"
    })
    @mail = account["mail"]
    @pass = account["pass"]
    @error_count = 0
    @rss_error_count = 0

    if logger == :stdout
      @logger = ::Lumberjack::Logger.new
    else
      @logger = ::Lumberjack::Logger.new(logger)
    end
  end

  def authenticated?
    agent.get("http://www.nicovideo.jp/").header["x-niconico-authflag"] != "0"
  end

  def login
    if mail && pass
      true if authenticated?
      agent.ssl_version = "TLSv1"
      agent.post 'https://secure.nicovideo.jp/secure/login?site=niconico','mail' => mail,'password' => pass
      authenticated?
    else
      raise "Login Error"
    end
  end

  def get_rss(rss_url)
    begin
      login
      logger.info "Get RSS: #{rss_url}"
      page = @agent.get rss_url
      RSS::Parser.parse(page.body, true)
    rescue => e
      logger.fatal "Get RSS failed: #{rss_url} #{$!}"
      raise e
    end
  end

  def get_flv_url(vid)
    begin
      page = agent.get "http://www.nicovideo.jp/api/getflv/#{vid}"
      params = Hash[page.body.split("&").map {|value| value.split("=")}]
      url = URI.unescape(params["url"])
      logger.info "Download URL => #{url}"
      url
    rescue => e
      logger.fatal "API access error: #{vid} #{$!}"
      raise e
    end
  end

  def detect_video_type(movie_url)
    movie_url =~ /^http.*(?:nicovideo|smilevideo)\.jp\/smile\?(\w)=.*/
    video_type = VIDEO_TYPE_TABLE[$1] ? VIDEO_TYPE_TABLE[$1] : "flv"
    logger.info "Download file type => #{video_type}"
    video_type
  end

  def access_movie_page(vid)
    begin
      agent.get("http://www.nicovideo.jp/watch/#{vid}")
    rescue => e
      logger.fatal "[FATAL] movie page load error: #{vid} #{$!}"
      self.error_count += 1
      raise e
    end
  end

  def download(vid, dir = "/tmp/nicomovie")
    login
    logger.info "Download sequence start: #{vid}"
    url = get_flv_url(vid)

    video_type = detect_video_type(url)

    logger.info "Not download swf file" && return if video_type == "swf"

    access_movie_page(vid)

    dest_dir = FileUtils.mkdir_p(File.join(dir, vid))
    dest_path = File.join(dest_dir, "#{vid}.#{video_type}")

    do_download(vid, url, dest_path)

    sleep 1

    info_path = download_info(vid, dest_dir)

    logger.info "Download sequence completed: #{vid}"
    self.error_count = 0

    nico_downloader_info = NicoDownloader::Info.parse(File.read(info_path))
    nico_downloader_info.path = dest_path
    nico_downloader_info.thumbnail_path = thumbnail_path(dest_path)
    on_download_complete.call(nico_downloader_info) if on_download_complete && on_download_complete.is_a?(Proc)
  end

  def do_download(vid, url, path)
    begin
      logger.info "download start: #{vid}"

      agent.pluggable_parser.default = Mechanize::Download
      agent.get(url).save(path)

      create_thumbnail(path)

      logger.info "download completed: #{vid}"
      path
    rescue Exception => e
      logger.fatal "download failed: #{vid} #{$!}"
      logger.fatal "#{$@}"
      self.error_count += 1
      raise e
    end
  end

  def download_info(vid, dir)
    info_path = File.join(dir, "#{vid}_info.xml")
    FileUtils.mkdir_p(File.dirname(info_path))

    begin
      logger.info "Movie info download start: #{vid}"

      agent.download "http://www.nicovideo.jp/api/getthumbinfo/#{vid}", info_path

      logger.info "Movie info download completed: #{vid}"
      info_path
    rescue Exception => e
      logger.fatal "info download failed: #{vid} #{$!}"
      logger.fatal "#{$@}"
      self.error_count += 1
      raise e
    end
  end

  def rss_download(rss_url, dir = "/tmp/nicomovie")
    begin
      rss = get_rss(rss_url)
      @rss_error_count = 0
    rescue
      if rss_error_count > 0 and rss_error_count <= 3
        puts "Sleep 10 seconds"
        sleep 10
        puts "Retry #{rss_url}"
        retry
      else
        return false
      end
    end

    rss.items.each do |item|
      item.link =~ /^http.*\/watch\/(.*)/
      vid = $1
      unless File.exists?(File.join(dir, vid))
        begin
          next if vid[0, 2] == "nm"
          download(vid, dir)
        rescue
          if error_count > 0 and error_count <= 3
            puts "Sleep 10 seconds"
            sleep 10
            puts "Retry #{vid}"
            retry
          end
        end
        @error_count = 0
        puts "Sleep #{SLEEP_TIME_PER_DOWNLOAD} seconds"
        sleep SLEEP_TIME_PER_DOWNLOAD
      end
    end
  end

  def thumbnail_path(path)
    path.gsub(/#{Regexp.escape(File.extname(path))}$/, ".jpg")
  end

  def exist_thumbnail?(path)
    File.exist?(path.gsub(/#{Regexp.escape(File.extname(path))}$/, ".jpg"))
  end

  def create_thumbnail(filepath)
    unless exist_thumbnail?(filepath)
      ffmpegthumbnailer = `which ffmpegthumbnailer`.chomp
      unless ffmpegthumbnailer == ""
        system("#{ffmpegthumbnailer} -t 10% -s #{THUMBNAIL_SIZE} -i #{filepath} -o #{thumbnail_path(filepath)}")
      end
    end
  end

  private
  def agent_init
    @agent = Mechanize.new
    @agent.user_agent_alias = "Windows Mozilla"
    @agent.max_history = 0
    @agent.ssl_version = "TLSv1"
  end
end
