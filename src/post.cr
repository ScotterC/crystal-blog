require "redis"
require "json"

class Post
  @id    : Int64
  @title : (String | Nil)
  @body  : (String | Nil)

  JSON.mapping(
    id: Int64,
    title: (String | Nil),
    body:  (String | Nil)
  )

  def self.all
    post_keys = Post.redis.smembers(Post.new.class_redis_key)
    posts = post_keys.map do |key|
      id = key.as(String).split("/").last
      find(id)
    end
  end

  def self.count
    Post.redis.scard(Post.new.class_redis_key)
  end

  def self.find(id)
    post_data = Post.redis.get(Post.new.redis_key(id))
    data = JSON.parse(post_data.as(String))
    Post.new(
      id: data["id"].as_i64,
      title: data["title"].as_s,
      body: data["body"].as_s
    )
  end

  def initialize(@id = 0_i64, @title = "", @body = "")
    @id    = id
    @title = title
    @body  = body
  end

  def title
    @title
  end

  def body
    @body
  end

  def save
    @id = if new_record?
      Post.redis.scard(class_redis_key) + 1
    else
      id
    end

    Post.redis.set(redis_key, self.to_json)
    Post.redis.sadd(class_redis_key, redis_key)

    true
  end

  def destroy
    Post.redis.del(redis_key)
    Post.redis.srem(class_redis_key, redis_key)
    true
  end

  def redis_key(arg_id = nil)
    arg = arg_id || id
    "#{class_redis_key}/#{arg}"
  end

  def to_s
    "#{title} - #{body}"
  end

  def id
    @id
  end

  def id=(id)
    @id = id
  end

  def new_record?
    return true if id == 0
  end

  def self.redis
    begin
      @@redis ||= Redis.new(url: ENV["REDIS_URL"])
    rescue KeyError
      @@redis ||= Redis.new
    end
  end

  def class_redis_key
    "posts"
  end
end