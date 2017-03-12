require "./spec_helper"

Redis.new.flushall

describe Post do
  title = "A wonderful snowy day"
  body  =  "It all started when dear ragamuffin..."

  describe ".new" do
    it "responds to title" do
      post = Post.new(title: title)
      post.title.should eq(title)
    end
  end

  describe "#redis_key" do
    it "defaults without argument" do
      Post.new.redis_key.should eq("posts/0")
    end

    it "takes argument" do
      Post.new.redis_key(1).should eq("posts/1")
    end
  end

  describe "#id" do
    it "defaults to 0" do
      Post.new.id.should eq(0)
    end

    it "has a value when saved" do
      post = Post.new(title: title, body: body)
      post.id.should eq(0)
      post.save
      post.id.should eq(1)
    end
  end

  describe ".find" do
    it "returns a post" do
      post = Post.find(1)
      post.title.should eq(title)
    end
  end

  describe "#to_json" do
    it "gives a JSON string" do
      post = Post.new(title: title, body: body)
      post.title.should eq(title)
      JSON.parse(post.to_json)["title"].should eq(title)
    end
  end

  describe ".all" do
    it "returns all posts" do
      posts = Post.all
      posts[0].title.should eq(title)
    end
  end

  describe ".count" do
    it "returns count of all posts" do
      Post.count.should eq(1)
    end
  end

  describe "#destroy" do
    it "removes from db" do
      post = Post.find(1)
      Post.redis.exists(post.redis_key).should eq(1)
      Post.count.should eq(1)
      post.destroy
      Post.redis.exists(Post.new.redis_key(1)).should eq(0)
      Post.count.should eq(0)
    end
  end

end