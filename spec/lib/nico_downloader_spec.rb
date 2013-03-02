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
    let(:nico_name) { "sm6038462" }
    let(:download_dir) { "/tmp/nicomovie" }
    let(:nico_downloader) { NicoDownloader.new }

    subject { nico_downloader.download(nico_name, download_dir) }

    before do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    after do
      FileUtils.rm_r(download_dir) if File.exists?(download_dir)
    end

    it "should download movie file" do
      subject
      download_path = "#{download_dir}/#{nico_name}/#{nico_name}.mp4"
      File.exists?(download_path).should be_true
      File.exists?(nico_downloader.thumbnail_path(download_path)).should be_true
      File.size(download_path).should > 100000
    end

    it "call download_complete_callback" do
      receiver = double(:receiver)
      dest_path = "#{download_dir}/#{nico_name}/#{nico_name}.mp4"
      receiver.should_receive(:test_method).with(dest_path)
      callback = ->(path) { receiver.test_method(path)}
      nico_downloader.download_complete_callback = callback
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
