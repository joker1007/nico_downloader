require "spec_helper"

require "nico_downloader"
require "tapp"

describe NicoDownloader do
  describe "#login" do
    subject { NicoDownloader.new.login }
    context "valid mail and email" do
      it { should be_true }
    end
  end

  describe "#get_flv_url" do
    let(:nico_downloader) { NicoDownloader.new }

    subject { nico_downloader.get_flv_url("sm6038462") }

    context "logined" do
      before do
        nico_downloader.login
      end

      it "should return movie url" do
        should =~ /^http/
      end
    end
  end

  describe "#download_info" do
    let(:filepath) { "/tmp/nicomovie/sm6038462_info.xml" }
    let(:nico_downloader) { NicoDownloader.new }

    subject { nico_downloader.download_info("sm6038462", "/tmp/nicomovie") }

    context "logined" do
      before do
        FileUtils.rm(filepath) if File.exists?(filepath)
        nico_downloader.login
      end

      after do
        FileUtils.rm(filepath) if File.exists?(filepath)
      end

      it "should return information xml" do
        subject
        File.exists?(filepath).should be_true
        xml = File.read(filepath)
        xml.should =~ /video_id/
        xml.should =~ /view_counter/
        xml.should =~ /length/
      end
    end
  end

  describe "thumbnail_path" do
    let(:nico_downloader) { NicoDownloader.new }
    let(:filepath) { "/tmp/nicomovie/sm6038462.mp4" }

    subject { nico_downloader.thumbnail_path(filepath) }

    it { should eq "/tmp/nicomovie/sm6038462.jpg"  }
  end

  describe "#download" do
    let(:nico_vid) { "sm6038462" }
    let(:download_dir) { "/tmp/nicomovie" }
    let(:nico_downloader) { NicoDownloader.new }
    let(:result_info) do
      NicoDownloader::Info.new(
        title: "【ニコカラ】 石鹸屋 - ヒルクライム On Vocal",
        nico_vid: "sm6038462",
        description: "パソカラアップ第4弾。コメントでリクエストくれた人が居たんですが、前回のから上げるのに半月以上かかってしまった。ちなみに字幕の動きは、自作のスクリプトを書いて、いくつかエフェクトのプリセットを作ったりしています。第5弾もあわせてアップしました。(sm6039719)その他のパソカラリスト(mylist/9085213)",
        view_count: 11036,
        mylist_count: 290,
        tags: %w(音楽 石鹸屋 ニコカラ ニコニコカラオケDB ハイブリッドバディ ヒルクライム ニコカラ石鹸屋 JOYSOUND配信中 厚志 石鹸屋オリジナル)
      )
    end

    subject { nico_downloader.download(nico_vid, download_dir) }

    before do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    after do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    it "should download movie file" do
      subject
      download_path = "#{download_dir}/#{nico_vid}/#{nico_vid}.mp4"
      File.exists?(download_path).should be_true
      File.exists?(nico_downloader.thumbnail_path(download_path)).should be_true
      File.size(download_path).should > 100000
    end

    it "call on_download_complete" do
      receiver = double(:receiver)
      receiver.should_receive(:test_method).with(result_info)
      callback = ->(info) { receiver.test_method(info)}
      nico_downloader.on_download_complete = callback
      subject
    end
  end

  describe "#rss_download" do
    let(:rss_url) { "http://www.nicovideo.jp/tag/%E3%83%8B%E3%82%B3%E3%83%8B%E3%82%B3%E3%82%AB%E3%83%A9%E3%82%AA%E3%82%B1DB?page=1&sort=f&rss=2.0" }
    let(:download_dir) { "/tmp/nicomovie" }
    let(:nico_downloader) { NicoDownloader.new }

    subject { nico_downloader.rss_download(rss_url, download_dir) }

    before do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    after do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    it "should download movie file" do
      nico_downloader.should_receive(:download).at_least(1)
      subject
    end

  end
end
