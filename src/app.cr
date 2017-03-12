require "kemal"
require "./post"

get "/" do
  "Hello World!"
end

get "/posts" do
  posts = Post.all
  render "src/views/posts/index.ecr", "src/views/layouts/layout.ecr"
end

get "/posts/:id" do |env|
  id = env.params.url["id"]
  post = Post.find(id)
  render "src/views/posts/show.ecr", "src/views/layouts/layout.ecr"
end

get "/posts/new" do
  render "src/views/posts/new.ecr", "src/views/layouts/layout.ecr"
end

post "/posts" do |env|
  title = env.params.body["title"]
  body = env.params.body["body"]

  # title = env.params.json["title"].as(String)
  # body = env.params.json["body"].as(String)
  post = Post.new(title: title, body: body)
  post.save
  env.redirect post.redis_key
end

# put "/posts/:id" do |env|
  # logic to update a post
# end

# delete "/posts/:id" do
#   # Remove a post
# end


Kemal.run