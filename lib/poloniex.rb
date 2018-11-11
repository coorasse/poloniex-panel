require 'rest-client'
require 'openssl'
require 'json'
require 'addressable/uri'

class Poloniex
  attr_reader :private_data

  def initialize(api_key = ENV['POLONIEX_API_KEY'], secret = ENV['POLONIEX_API_SECRET'])
    @api_key = api_key
    @secret = secret
    @private_data = @api_key && @secret
  end

  def returnTicker
    JSON.parse get('returnTicker').body
  end

  def returnBalances
    if private_data?
      JSON.parse post('returnBalances').body
    else
      raise NotImplementedError('You need an api_key and a secret_key to check your balance')
    end
  end

  def private_data?
    @private_data
  end

  protected

  def resource
    @resouce ||= RestClient::Resource.new('https://www.poloniex.com')
  end

  def get(command, params = {})
    params[:command] = command
    resource['public'].get params: params
  end

  def post(command, params = {})
    params[:command] = command
    params[:nonce] = (Time.now.to_f * 10000000).to_i
    resource['tradingApi'].post params, { Key: @api_key, Sign: create_sign(params) }
  end

  def create_sign(data)
    encoded_data = Addressable::URI.form_encode(data)
    OpenSSL::HMAC.hexdigest('sha512', @secret, encoded_data)
  end
end
