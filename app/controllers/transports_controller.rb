require 'net/http'
require 'json'

class TransportsController < ApplicationController
  @@KN_token = nil
  @@KN_token_fetched_at = nil

  before_action :find_transport, except: [:index, :create, :new, :import_transports]

  def show
  end

  def index
    @transports = Transport.all.order(Arel.sql('delivery_time IS NOT NULL'), 'delivery_time DESC')
  end

  def new
    @transport = Transport.new
  end

  def create
    @transport = Transport.new(transport_params)

    if @transport.save
      redirect_to edit_transport_path(@transport)
    else
      render action: 'new'
    end
  end

  def edit
    unless params[:from].nil?
      @transport.source_event_id = params[:from]
    end
    unless params[:to].nil?
      @transport.destination_event_id = params[:to]
    end
  end

  def update
    if @transport.update_attributes(transport_params)
      @transport.save
      redirect_to transports_path
    else
      render action: 'edit'
    end
  end

  def import_transports
    redirect_to transports_path
  end

  private

  def find_transport
    @transport = Transport.find(params[:id])
  end

  def transport_params
    params.require(:transport).permit(:source_event_id, :source_address, :pickup_time, :destination_event_id, :destination_address, :delivery_time)
  end

  def fetch_KN_token
    # when token is nil –or– token is older than one hour (todo experiment with duration)
    if @@KN_token.nil? or (DateTime.now - @@KN_token_fetched_at) > (1/24.0)
      uri = URI("https://sso.kuehne-nagel.com/RDIApplication/login")
      res = Net::HTTP.post_form(uri, 
        'user' => ENV['KN_USER'],
        'password' => ENV['KN_PASSWORD'],
        'target' => 'https%3A%2F%2Fonlineservices.kuehne-nagel.com%2Fac%2F_sso',
        'appname' => 'ECOM',
        'mode' => 'post'
      )
      if res.kind_of? Net::HTTPSuccess
        @@KN_token, = /name="appToken" value="(.+?)"/.match(res.body).captures
        @@KN_token_fetched_at = DateTime.now 
      end
    end
    return @@KN_token
  end
end
