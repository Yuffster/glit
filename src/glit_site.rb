require 'glit'
require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

get '/thoughts' do
  @title = "Thoughts"
  @blobs = Thought.find
  erb :blobs
end

get '/thought/:tid' do
  @blob  = Thought.find(:id=>params[:tid])
  @title = "Thought: #{@blob.title}"
  @blob.html = @blob.content.split("\n").join('<br/>')
  erb :blob
end

get '/:story/thoughts' do
  @title  = "Thoughts for #{params[:story]}"
  @blobs = Thought.find(:story=>params[:story])
  erb :blobs
end

get '/:story/thought/:tid' do
  @blob  = Thought.find(:story=>params[:story], :id=>params[:tid])
  @title = "Thoughts for #{params[:story]}: #{@blob.title}"
  erb :blob
end

get '/:story' do
  @story = params[:story]
  erb :story
end

get '/:story/scene/:sid' do
  @blob = {:type => 'scene', :name => params[:sid]}
  erb :blob
end

get '/:story/scenes' do
  @story = params[:story]
  @blobs = {:type => 'scene'}
  erb :blobs
end

get '/:story/outline' do
  @outline = Outline.find(:story=>params[:story])
  erb :outline
end

get '/:story/outline/get' do
  @outline = Outline.find(:story=>params[:story])
  erb :outline_raw, :layout => false
end

post '/:story/outline/save' do 
  @outline = Outline.find(:story=>params[:story])
  @outline.content = params[:content] || ':D'
  @outline.save
end

post '/:story/outline/commit' do 
  @outline = Outline.find(:story=>params[:story])
  @outline.commit(params[:message])
end
