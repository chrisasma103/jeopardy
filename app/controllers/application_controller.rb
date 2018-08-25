require './config/environment'
require './app/models/model' 
require 'japi'
require 'similar_text'

=begin 
How to run program: shotgun -p $PORT -o $IP

How to push a software to github:
rm -rf .git
git init
git add .
git commit -m "string"
git remote add origin url
git push

How to revise
git add .
git commit -m "string"
git remote add origin master
git push
=end

class ApplicationController < Sinatra::Base
  helpers Sinatra::Cookies
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end
 
  get '/' do
    if cookies[:username]==nil
      return erb :index
    else
      redirect to('/choice')
    end
  end
  
  get '/choice' do
    cookies[:username] ||= params["name"]
    if cookies[:ft]==nil #cookie text looks weird the first time it appears, so this reloads it.
      cookies[:ft]=true
      redirect to('/choice')
    end
    return erb :choice
  end
  
  post '/question' do
    cookies[:personalscore] ||= 0
    @clue=JAPI::Trebek.random.first
    cookies[:answer]=@clue.answer
    cookies[:answer].gsub("</i>","")
    cookies[:answer].gsub("<i>","")
    cookies[:value]=@clue.value
    cookies[:value] ||=1000
    return erb :question
  end
  
  post '/answer' do
    @guess=params["guess"]
    @test=((cookies[:answer].to_s).similar(@guess)).to_s
    if ((cookies[:answer].to_s).similar(@guess))>=85
      @closeness=true
      cookies[:personalscore]=cookies[:personalscore].to_i+cookies[:value].to_i
    else
      cookies[:personalscore]=cookies[:personalscore].to_i-cookies[:value].to_i
      @closeness=false
    end
    return erb :answer
  end
end
