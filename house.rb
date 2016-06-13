require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'
require 'pry'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  PROPERTY_LIST = ['price', 'address', 'size', 'neighborhood', 'walkscore', 'notes', 'phonenumber']
  session[:input] ||= {}
  session[:id] ||= 1
end

helpers do
  def filter_session_input
    session[:input].select { |_, value| value.values.all? { |char| !char.strip.empty? } }
  end

  def load_and_check_input(id)
    PROPERTY_LIST.each do |p|
    session[:input][id][p] = params[p.to_sym]
      end

    PROPERTY_LIST.each do |p|
      if params[p.to_sym].strip.empty?
        session[:message] = 'Please fill in all the information'
        redirect "/#{id}"
      end
    end
  end
end

get '/' do
  erb :question
end

post '/' do
  session[:input][session[:id]] = {}
  load_and_check_input(session[:id])
  session[:id] += 1
  session[:message] = 'The house has been added'
  redirect '/result'
end

get '/result' do
    erb :result
end

post '/:id/remove' do
  id = params[:id].to_i
  session[:input].delete(id)

  session[:message] = 'The house has been removed'
  redirect '/result'
end

get '/:id' do
  @id = params[:id].to_i
  @keys = session[:input].keys
  if session[:input][@id]
    erb :edit
  else
    session[:message] = 'This house is not found'
    redirect '/result'
  end
end

post '/:id' do
  @id = params[:id].to_i
  @keys = session[:input].keys
  load_and_check_input(@id)
  session[:message] = 'The house has been saved'
  redirect '/result'
end
