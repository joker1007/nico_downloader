require "spec_helper"

require "nico_downloader"
require "tapp"

describe NicoDownloader::Info do
  describe ".parse" do
    let(:info_xml) { File.join(SPEC_ROOT, "movie_info.xml") }
    let(:info) do
      NicoDownloader::Info.new(
        title: "【ニコカラ】 石鹸屋 - ヒルクライム On Vocal",
        vid: "sm6038462",
        description: "パソカラアップ第4弾。コメントでリクエストくれた人が居たんですが、前回のから上げるのに半月以上かかってしまった。ちなみに字幕の動きは、自作のスクリプトを書いて、いくつかエフェクトのプリセットを作ったりしています。第5弾もあわせてアップしました。(sm6039719)その他のパソカラリスト(mylist/9085213)",
        view_count: 11036,
        mylist_count: 290,
        tags: %w(音楽 石鹸屋 ニコカラ ニコニコカラオケDB ハイブリッドバディ ヒルクライム ニコカラ石鹸屋 JOYSOUND配信中 厚志 石鹸屋オリジナル),
        duration: 243,
        posted_at: Time.local(2009, 2, 4, 2, 0, 49)
      )
    end

    subject { described_class.parse(File.read(info_xml)) }

    its(:title) { should eq info.title }
    its(:vid) { should eq info.vid }
    its(:description) { should eq info.description }
    its(:view_count) { should eq info.view_count }
    its(:mylist_count) { should eq info.mylist_count }
    its(:duration) { should eq info.duration }
    its(:posted_at) { should eq info.posted_at }
    its(:tags) { should eq info.tags }

    it { should eq info }
  end

  describe "#parse" do
    let(:info) { NicoDownloader::Info.new(path: "/tmp/movie.mp4", thumbnail_path: "/tmp/movie.jpg") }
    let(:info_xml) { File.join(SPEC_ROOT, "movie_info.xml") }
    let(:title) {  "【ニコカラ】 石鹸屋 - ヒルクライム On Vocal" }
    let(:vid) { "sm6038462" }
    let(:description) { "パソカラアップ第4弾。コメントでリクエストくれた人が居たんですが、前回のから上げるのに半月以上かかってしまった。ちなみに字幕の動きは、自作のスクリプトを書いて、いくつかエフェクトのプリセットを作ったりしています。第5弾もあわせてアップしました。(sm6039719)その他のパソカラリスト(mylist/9085213)" }
    let(:view_count) { 11036 }
    let(:mylist_count) { 290 }
    let(:tags) { %w(音楽 石鹸屋 ニコカラ ニコニコカラオケDB ハイブリッドバディ ヒルクライム ニコカラ石鹸屋 JOYSOUND配信中 厚志 石鹸屋オリジナル) }
    let(:duration) { 243 }
    let(:posted_at) { Time.local(2009, 2, 4, 2, 0, 49) }

    subject { info.parse(File.read(info_xml)) }

    its(:title) { should eq title }
    its(:vid) { should eq vid }
    its(:description) { should eq description }
    its(:view_count) { should eq view_count }
    its(:mylist_count) { should eq mylist_count }
    its(:duration) { should eq duration }
    its(:posted_at) { should eq posted_at }
    its(:tags) { should eq tags }
    its(:path) { "/tmp/movie.mp4" }
    its(:thumbnail_path) { "/tmp/movie.jpg" }
  end
end
