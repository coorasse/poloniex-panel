require_relative 'poloniex'
require_relative 'coinbase_client'
require_relative 'currency_exchange_rate'
require 'tty'
require 'bigdecimal'
require 'bigdecimal/util'
require 'dotenv/load'

class Panel
  def initialize(currencies = [], your_currency)
    @currencies = currencies
    @your_currency = your_currency
    @your_currency_exchange_rate = CurrencyExchangeRate.for(@your_currency)
    @poloniex = Poloniex.new
    @coinbase = CoinbaseClient.new
    @message = "API initialized without API keys. Only public data will be available" unless @poloniex.private_data?
  end

  def refresh
    build_tables
    puts `clear`
    puts @message if @message
    puts @exchanges_table
    puts @wallet_table if @poloniex.private_data?
    puts @coinbase_table
  end

  def build_tables
    @tickers = @poloniex.returnTicker
    @exchanges_table = build_exchanges_table
    @wallet_table = build_wallet_table if @poloniex.private_data?
    @coinbase_table = coinbase_wallet_table
  end

  def build_exchanges_table
    columns = ['Currency', 'BTC', @your_currency]
    rows = []
    rows << ['BTC', 1, normalize(to_your_currency(base_value))]

    @currencies.each do |currency|
      btc_value = get_btc_value(currency)
      rows << [currency, normalize(btc_value), normalize(to_your_currency(base_value * btc_value))]
    end

    to_table(columns, rows)
  end

  def build_wallet_table
    columns = ['Currency', 'Amount', 'BTC', @your_currency]
    wallet_rows = extract_wallets_rows

    rows = wallet_rows.map do |row|
      [row[0], normalize(row[1]), normalize(row[2]), normalize(row[3])]
    end.compact
    rows << calculate_totals_row(wallet_rows)
    to_table(columns, rows)
  end

  def coinbase_wallet_table
    columns = ['Currency', 'Amount', 'BTC', @your_currency]
    wallets = @coinbase.accounts
    wallet_rows = wallets.each.map do |wallet|
      currency = wallet['currency']
      amount = wallet['balance']['amount'].to_d
      local_currency = wallet['native_balance']['amount'].to_d
      if currency == 'EUR' || amount == 0.0
      elsif currency == 'BTC'
        [currency, amount, amount, local_currency || to_your_currency(base_value * amount)]
      else
        btc_value = get_btc_value(currency)
        amount_in_btc = btc_value * amount
        [currency, amount, amount_in_btc, local_currency || to_your_currency(base_value * amount_in_btc)]
      end
    end.compact
    rows = wallet_rows.map do |row|
      [row[0], normalize(row[1]), normalize(row[2]), normalize(row[3])]
    end.compact
    rows << calculate_totals_row(wallet_rows)
    to_table(columns, rows)
  end

  def extract_wallets_rows
    base_value = tickers['USDT_BTC']['last'].to_d
    wallets = @poloniex.returnBalances
    wallets.each.map do |currency, value|
      value_d = value.to_d
      if value_d != 0.to_d
        if currency == 'BTC'
          [currency, value_d, value_d, to_your_currency(base_value * value_d)]
        else
          btc_value = get_btc_value(currency)
          amount_in_btc = btc_value * value_d
          [currency, value, amount_in_btc, to_your_currency(base_value * amount_in_btc)]
        end
      end
    end.compact
  end

  protected

  def to_table(columns, rows)
    table = TTY::Table.new columns, rows
    table.render(:ascii, padding: [1, 1, 1, 1]) do |rendered|
      rendered.border.separator = :each_row
    end
  end

  def to_your_currency(amount)
    amount * @your_currency_exchange_rate
  end

  def normalize(value)
    "%014.8f" % value.to_d
  end

  def calculate_totals_row(wallet_rows)
    ['Total', '', normalize(wallet_rows.inject(0) { |s, r| s + r[2] }), normalize(wallet_rows.inject(0) { |s, r| s + r[3] })]
  end

  def get_btc_value(currency)
    tickers["BTC_#{currency}"]['last'].to_d
  end

  def tickers
    @tickers ||= @poloniex.returnTicker
  end

  def base_value
    @base_value ||= tickers['USDT_BTC']['last'].to_d
  end
end
