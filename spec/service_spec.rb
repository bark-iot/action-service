require File.expand_path '../spec_helper.rb', __FILE__

describe 'Devices Service' do
  before(:each) do
    DB.execute('TRUNCATE TABLE actions;')
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"email":"test@test.com","token":"a722658b-0fea-415c-937f-1c1d3c8342fd","created_at":"2017-11-14 16:06:52 +0000","updated_at":"2017-11-14 16:06:52 +0000"}', headers: {})
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 422, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"user_id":1,"title":"Test","address":"Pr Pobedi 53b","key":"4d27328d-cbf6-493e-a5ec-7f6848ece614","created_at":"2017-11-24 20:32:29 +0000","updated_at":"2017-11-24 20:32:29 +0000"}', headers: {})
    stub_request(:get, 'http://lb/houses/3').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 404, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1/devices/1').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id": 1,"house_id": 1,"title": "MyDevice","com_type": 0,"token": "2d931510-d99f-494a-8c67-87feb05e1594","online":false,"approved_at": "2017-11-11 11:04:44 UTC","created_at": "2017-11-11 11:04:44 UTC","updated_at": "2017-1-11 11:04:44 UTC"}', headers: {})
  end

  #TODO: add delete device test

  it 'should show action' do
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/devices/1/actions/#{action.id}"

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyAction')
    expect(body['key']).to eql('my_action')
  end

  it 'should not show action for another device' do
    t = Action::Create.(title: 'MyAction', key: 'my_action', device_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/devices/1/actions/#{t.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should list all actions for device' do
    action_title = action.title
    header 'Authorization', "Bearer #{token}"
    get 'houses/1/devices/1/actions'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body[0]['title'] == action_title).to be_truthy
  end

  it 'should not list actions for another device' do
    Action::Create.(title: 'MyAction', key: 'my_action', device_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    get '/houses/1/devices/1/actions'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body.size == 0).to be_truthy
  end

  it 'should not list all actions for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    get '/houses/1/devices/1/actions'

    expect(last_response.status).to equal(401)
  end

  it 'should create action for device' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/devices/1/actions', {title: 'MyAction', key: 'my_action', input: '[{"key":"temp","type":"int"}]'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyAction')
    expect(body['key']).to eql('my_action')
    input = JSON.parse(body['input'])
    expect(input[0]['key']).to eql('temp')
    expect(input[0]['type']).to eql('int')
  end

  it 'should not create action without title' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/devices/1/actions', {input: '[{"key":"temp","type":"int"}]'}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
    expect(body[1] == ['key', ['must be filled']]).to be_truthy
  end

  it 'should not create action with not unique key' do
    a = action
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/devices/1/actions', {title: 'Something', key: a.key, input: '[{"key":"temp","type":"int"}]'}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['key', ['already taken']]).to be_truthy
  end

  it 'should not create actions for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    post '/houses/1/devices/1/actions', {title: 'MyAction', key: 'my_action', input: '[{"key":"temp","type":"int"}]'}

    expect(last_response.status).to equal(401)
  end

  it 'should update action for device' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/1/actions/#{action.id}", {title: 'My Action'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('My Action')
  end

  it 'should not update action key for device' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/1/actions/#{action.id}", {title: 'My Action', key: 'new_key'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('My Action')
    expect(body['key']).to eql('my_action')
  end

  it 'should not update action of another device' do
    another_action = Action::Create.(title: 'MyAction', device_id: 2, key: 'my_key')['model']
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/1/actions/#{another_action.id}", {title: 'My Action'}

    expect(last_response.status).to equal(404)
  end

  it 'should not update action for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    put "/houses/1/devices/1/actions/#{action.id}", {title: 'MyAction'}

    expect(last_response.status).to equal(401)
  end

  it 'should delete action for device' do
    action_id = action.id
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/devices/1/actions/#{action_id}"

    expect(last_response).to be_ok
    expect(Action.where(id: action_id).first == nil).to be_truthy
  end

  it 'should not delete action of another device' do
    t = Action::Create.(title: 'MyAction', key: 'my_action', device_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/devices/1/actions/#{t.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should not delete device for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    delete "/houses/1/devices/1/actions/#{action.id}"

    expect(last_response.status).to equal(401)
  end

  def token
    'a722658b-0fea-415c-937f-1c1d3c8342fd'
  end

  def action
    Action::Create.(title: 'MyAction', key: 'my_action', device_id: 1, input: '[{"key":"temp","type":"int"}]')['model']
  end
end