require 'rails_helper'

RSpec.describe "API_V1::Trains", :type => :request do

  before do
    @train1 = Train.create!( :number => "0822")
    @train2 = Train.create!( :number => "0603")
  end

  example "GET /api/v1/trains" do
    get "/api/v1/trains"

    expect(response).to have_http_status(200)

    expected_result = {
      "meta": {
        "current_page": 1,
        "total_pages": 1,
        "per_page": 30,
        "total_entries": 2,
        "next_url": nil,
        "previous_url": nil
      },
      "data": [
        { "number": @train1.number,
          "logo_url": nil,
          "logo_file_size": nil,
          "logo_content_type": nil,
          "available_seats": ["1A","1B","1C","2A","2B","2C","3A","3B","3C","4A","4B","4C","5A","5B","5C","6A","6B","6C"],
          "created_at": @train1.created_at },
        { "number": @train2.number,
          "logo_url": nil,
          "logo_file_size": nil,
          "logo_content_type": nil,
          "available_seats": ["1A","1B","1C","2A","2B","2C","3A","3B","3C","4A","4B","4C","5A","5B","5C","6A","6B","6C"],
          "created_at": @train2.created_at }
      ]
    }
    expect(response.body).to eq( expected_result.to_json )
  end

  example "GET /api/v1/trains/{train_number}" do
    get "/api/v1/trains/0822"

    expect(response).to have_http_status(200)

    expected_result = { "number": @train1.number,
          "logo_url": nil,
          "logo_file_size": nil,
          "logo_content_type": nil,
          "available_seats": ["1A","1B","1C","2A","2B","2C","3A","3B","3C","4A","4B","4C","5A","5B","5C","6A","6B","6C"],
          "created_at": @train1.created_at }

    expect(response.body).to eq( expected_result.to_json )
  end

end
