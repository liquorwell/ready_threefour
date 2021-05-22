require "sinatra"
require "sinatra/reloader"
require "active_record"
require "logger"
require "rack/csrf"

use Rack::Session::Cookie, secret: "5EpEutwLJvKAmcdBZv+tr#Yp"
use Rack::Csrf, raise: true

helpers do
  def csrf_tag
    Rack::Csrf.csrf_tag(env)
  end
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
   adapter:  "postgresql",
   host:     "ec2-3-233-7-12.compute-1.amazonaws.com",
   username: "ybxdumpqxxggvz",
   password: "74603d9a0e7ffd6c107c252f02c8519fa468beeae5bcda5a15a7b73e2178b71b",
   database: "de1uarnvoq545g"
 )

class Content < ActiveRecord::Base
  has_many :campaigns, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :title, :name, :price, :description, :pass, presence: true
end

class Campaign < ActiveRecord::Base
  belongs_to :content
  validates :name, :price, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :content
  validates :name, :comment, presence: true
end


def data_set(content)
  @id = content.id
  @title = content.title
  @description = content.description
  @name = content.name
  @goal_price = content.price
  @now_price = content.campaigns.all.sum(:price)
  @progress = ((@now_price.to_f/ @goal_price.to_f).to_f * 100).to_i
  @campa_num = content.campaigns.all.count
  @comment_num = content.comments.all.count
  @date = content.created.strftime("%Y-%m-%d")
end

def contents_order(key)
  if key == "new"
    @contents = Content.includes(:campaigns, :comments).order(created: "desc").all
  elsif key == "old"
    @contents = Content.includes(:campaigns, :comments).order(created: "asc").all
  end
end


get '/' do
  @contents = Content.includes(:campaigns, :comments).where(archived: 0).order(created: "desc")
  erb :index
end

post '/' do
  contents_order("#{params[:order]}")
  erb :index
end

get '/archive/?:id?' do
  if params[:id]
    Content.update(params[:id], archived: 1)
    redirect to('/')
  else
    @contents = Content.includes(:campaigns, :comments).where(archived: 1).order(created: "desc")
    erb :archive
  end
end

get '/unarchive/:id' do
  Content.update(params[:id], archived: 0)
  redirect to('/archive')
end

get '/create' do
  @text = "編集・削除のときに必要となります。"
  erb :create
end

post '/create' do
  begin
    Content.create!(title: params[:title], name: params[:name], price: params[:price], description: params[:description], pass: params[:pass])
    redirect to('/')
  rescue => error
    @text = "エラー：すべてのフォームを入力してください！"
    erb :create
  end
end

get '/update/:id/?:option?' do
  @content = Content.includes(:campaigns, :comments).find(params[:id])
  if params[:option] == "miss"
    @text = "パスワードが違います！"
  elsif params[:option] == "invalid"
    @text = "エラー：すべてのフォームを入力してください！"
  else
    @text = "募集のときに設定したパスワードを入力してください。"
  end
  erb :update
end

post '/update/:id' do
  if params[:pass] == Content.find(params[:id]).pass
    begin
      Content.update(params[:id], title: params[:title], name: params[:name], price: params[:price], description: params[:description]).save!
      redirect to ('/')
    rescue => error
      redirect to ("/update/#{params[:id]}/invalid")
    end
  else
    redirect to ("/update/#{params[:id]}/miss")
  end
end

get '/destroy/:id/?:option?' do
  @content = Content.includes(:campaigns, :comments).find(params[:id])
  if params[:option] == "miss"
    @text = "パスワードが違います！"
  else
    @text = "募集のときに設定したパスワードを入力してください。"
  end
  erb :destroy
end

post '/destroy/:id' do
  if params[:pass] == Content.find(params[:id]).pass
    Content.find(params[:id]).destroy
    redirect to ('/')
  else
    redirect to ("/destroy/#{params[:id]}/miss")
  end
end

get '/campaign/:id' do
  @content = Content.includes(:campaigns, :comments).find(params[:id])
  erb :campaign
end

post '/campaign/:id' do
  Campaign.create(name: params[:name], price: params[:price], content_id: params[:id])
  redirect to("/campaign/#{params[:id]}")
end

get '/comment/:id' do
  @content = Content.includes(:campaigns, :comments).find(params[:id])
  erb :comment
end

post '/comment/:id' do
  Comment.create(name: params[:name], comment: params[:comment], content_id: params[:id])
  redirect to("/comment/#{params[:id]}")
end
