require 'rest-client'

class CurrencyExchangeRate
  def self.for(currency)
    if currency == 'USD'
      return 1
    else
      resource = RestClient::Resource.new("https://free.currconv.com/api/v7/convert?q=USD_#{currency}&compact=ultra&apiKey=#{ENV['CURRENCY_CONVERTER_API_KEY']}")
      JSON.parse(resource.get.body)["USD_#{currency}"]
    end
  end
end
