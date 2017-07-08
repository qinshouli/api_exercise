require 'rails_helper'

RSpec.describe "API_V1::Users", :type => :request do

  before do
    @user = User.create!( :email => "test@example.com", :password => "12345678")
  end

  example "GET /me" do
    get "/api/v1/me", params: { :auth_token => @user.authentication_token }

    expect(response).to have_http_status(200)

    @user.reload

    expect(response.body).to eq(
       {
        :email => @user.email,
        :avatar => @user.avatar,
        :updated_at => @user.updated_at,
        :created_at => @user.created_at
      }.to_json )
  end

  it "PATCH /me" do
    # 上传档案，请放一个图档在 spec/fixtures 目录下

    file = fixture_file_upload("#{Rails.root}/spec/fixtures/rails.png", "image/png")

    patch "/api/v1/me", params: { :auth_token => @user.authentication_token, :email => "test2@example.com", :avatar => file }

    expect(response).to have_http_status(200)

    expect(response.body).to eq( { :message => "OK" }.to_json )

    @user.reload

    expect(@user.email).to eq("test2@example.com")
    expect(@user.avatar).not_to eq(nil)
  end

end
