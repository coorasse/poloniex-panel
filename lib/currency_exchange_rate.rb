require 'rest-client'

class CurrencyExchangeRate
  def self.for(currency)
    if currency == 'USD'
      return 1
    else
      resource = RestClient::Resource.new("http://free.currencyconverterapi.com/api/v5/convert?q=USD_#{currency}&compact=y")
      JSON.parse(resource.get.body)["USD_#{currency}"]['val']
    end
  end
end
