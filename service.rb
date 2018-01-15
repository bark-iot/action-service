require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require './config/logging.rb'
require './config/authorize.rb'
require './config/database.rb'
require './config/concepts.rb'
require './config/redis.rb'


set :bind, '0.0.0.0'
set :port, 80
set :public_folder, 'public'

get '/actions/docs' do
  redirect '/actions/docs/index.html'
end

get '/actions/system' do
  result = SystemAction::List.()
  if result.success?
    body Action::Representer.for_collection.new(result['models']).to_json
  else
    status 422
    body result['contract.default'].errors.messages.uniq.to_json
  end
end

get '/houses/:house_id/actions/:id/validate' do
  result = Action::ValidateHouseId.(params.merge(authorization_header: request.env['HTTP_AUTHORIZATION'].to_s))
  if result.success?
    body Action::Representer.new(result['model']).to_json
  else
    if result['contract.default'] && result['contract.default'].errors.messages.size > 0
      status 422
      body result['contract.default'].errors.messages.uniq.to_json
    else
      status 404
    end
  end
end

namespace '/houses/:house_id/devices/:device_id' do
  get '/actions' do
    result = Action::List.(device_id: params[:device_id])
    if result.success?
      body Action::Representer.for_collection.new(result['models']).to_json
    else
      status 422
      body result['contract.default'].errors.messages.uniq.to_json
    end
  end

  post '/actions' do
    result = Action::Create.(params)
    if result.success?
      body Action::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  get '/actions/:id' do
    result = Action::Get.(params)
    if result.success?
      body Action::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  put '/actions/:id' do
    result = Action::Update.(params)
    if result.success?
      body Action::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  delete '/actions/:id' do
    result = Action::Delete.(params)
    if result.success?
      status 200
    else
      if result['contract.default'].errors.messages.size > 0
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end
end