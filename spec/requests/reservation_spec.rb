require 'rails_helper'

RSpec.describe "API_V1::Reservations", :type => :request do

  before do
    @train1 = Train.create!( :number => "0822")
    @train2 = Train.create!( :number => "0603")

    @user = User.create!( :email => "test@example.com", :password => "12345678" )
    @reservation = Reservation.create!( :train_id => @train1.id, :seat_number => "1A",
                                        :customer_name => "foo", :customer_phone => "12345678" )
  end

  example "GET /api/v1/reservations/{booking_code}" do
    get "/api/v1/reservations/#{@reservation.booking_code}"

    expect(response).to have_http_status(200)
    expect(response.body).to eq( { :booking_code => @reservation.booking_code,
                                   :train_number => @reservation.train.number,
                                   :train => {
                                     :number => @train1.number,
                                     :logo_url => nil,
                                     :logo_file_size => nil,
                                     :logo_content_type => nil,
                                     :available_seats => ["1B","1C","2A","2B","2C","3A","3B","3C","4A","4B","4C","5A","5B","5C","6A","6B","6C"],
                                     :created_at => @train1.created_at
                                   },
                                   :seat_number => @reservation.seat_number,
                                   :customer_name => @reservation.customer_name,
                                   :customer_phone => @reservation.customer_phone
                                  }.to_json )
  end

  example "DELETE /api/v1/reservations/{booking_code}" do
    delete "/api/v1/reservations/#{@reservation.booking_code}"

    expect(response).to have_http_status(200)

    expect(response.body).to eq( { :message => "已取消定位" }.to_json )
    expect( Reservation.count ).to eq(0)
  end

  example "PATCH /api/v1/reservations/{booking_code}" do
    patch "/api/v1/reservations/#{@reservation.booking_code}", :params => { :customer_name => "bar", :customer_phone => "987654321" }

    expect(response).to have_http_status(200)

    expect(response.body).to eq( { :message => "更新成功" }.to_json )

    @reservation.reload

    expect( @reservation.customer_name ).to eq("bar")
    expect( @reservation.customer_phone ).to eq("987654321")
  end

  describe "POST /api/v1/reservations" do
      example "success without auth_token" do
        post "/api/v1/reservations", :params => { :train_number => @train1.number, :seat_number => "1B",
                                                  :customer_name => "zoo", :customer_phone => "55555555"}

        expect(response).to have_http_status(200)

        created_reservation = Reservation.last

        expect(response.body).to eq( { :booking_code => created_reservation.booking_code,
                                       :reservation_url => api_v1_reservation_url(+created_reservation.booking_code) }.to_json )

        expect(created_reservation.customer_name).to eq("zoo")
        expect(created_reservation.customer_phone).to eq("55555555")
        expect(created_reservation.user_id).to eq(nil)
      end

      example "success with auth_token" do
        post "/api/v1/reservations", :params => { :auth_token => @user.authentication_token,
                                                  :train_number => @train1.number, :seat_number => "1B",
                                                  :customer_name => "zoo", :customer_phone => "55555555"}

        expect(response).to have_http_status(200)

        created_reservation = Reservation.last

        expect(response.body).to eq( { :booking_code => created_reservation.booking_code,
                                       :reservation_url => api_v1_reservation_url(+created_reservation.booking_code) }.to_json )

        expect(created_reservation.customer_name).to eq("zoo")
        expect(created_reservation.customer_phone).to eq("55555555")
        expect(created_reservation.user_id).to eq(@user.id)
      end

     example "failed" do
        post "/api/v1/reservations", :params => { :train_number => @train1.number, :seat_number => "1A", +:customer_name => "zoo", :customer_phone => "55555555"}

        expect(response).to have_http_status(400)

        expect(response.body).to eq( { :message => "订票失败", :errors => { :seat_number => ["has already been +taken"] } }.to_json )
      end
  end

  describe "GET /api/v1/reservations" do
    example "failed" do
      get "/api/v1/reservations", :params => {  }
      expect(response).to have_http_status(401)
    end

    example "success" do

      @reservation1 = Reservation.create!( :user_id => @user.id, :train_id => @train1.id, :seat_number => +"1B",
                                           :customer_name => "foo", :customer_phone => "12345678" )
      @reservation2 = Reservation.create!( :user_id => @user.id, :train_id => @train1.id, :seat_number => +"1C",
                                           :customer_name => "foo", :customer_phone => "12345678" )

      get "/api/v1/reservations", :params => { :auth_token => @user.authentication_token }

      expect(response).to have_http_status(200)
      expect(response.body).to eq( { :data => [
                                      { :booking_code => @reservation1.booking_code,
                                        :train_number => @reservation1.train.number,
                                         :train => {
                                           :number => @train1.number,
                                           :logo_url => nil,
                                           :logo_file_size => nil,
                                           :logo_content_type => nil,
                                           :available_seats => ["2A","2B","2C","3A","3B","3C","4A","4B","4C"+,"5A","5B","5C","6A","6B","6C"],
                                           :created_at => @train1.created_at
                                         },
                                         :seat_number => @reservation1.seat_number,
                                         :customer_name => @reservation1.customer_name,
                                         :customer_phone => @reservation1.customer_phone
                                      },
                                   { :booking_code => @reservation2.booking_code,
                                        :train_number => @reservation2.train.number,
                                         :train => {
                                           :number => @train1.number,
                                           :logo_url => nil,
                                           :logo_file_size => nil,
                                           :logo_content_type => nil,
                                           :available_seats => ["2A","2B","2C","3A","3B","3C","4A","4B","4C"+,"5A","5B","5C","6A","6B","6C"],
                                           :created_at => @train1.created_at
                                         },
                                         :seat_number => @reservation2.seat_number,
                                         :customer_name => @reservation2.customer_name,
                                         :customer_phone => @reservation2.customer_phone
                                      }
                                  ] }.to_json )


    end
  end

end
