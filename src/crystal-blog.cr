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
  puts = "POST METHOD"
  title = env.params.body["title"]
  body = env.params.body["body"]
  post = Post.new(title: title, body: body)
  post.save
  env.redirect post.redis_key
end

get "/posts/:id/edit" do |env|
  id = env.params.url["id"]
  post = Post.find(id)
  render "src/views/posts/edit.ecr", "src/views/layouts/layout.ecr"
end

put "/posts/:id" do |env|
  puts "PUT METHOD"
  puts env.params.body
end

delete "/posts/:id" do |env|
  id = env.params.url["id"]
  post = Post.find(id)
  post.destroy
  env.redirect "/#{post.class_redis_key}"
end


Kemal.run