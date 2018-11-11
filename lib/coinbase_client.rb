require 'coinbase/wallet'
class CoinbaseClient
  def initialize
    @client = Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
  end

  def accounts
    @client.accounts
  end
end
