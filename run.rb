require_relative 'lib/poloniex'
require_relative 'lib/panel'

currencies = %w(XEM ETH LTC XRP SC STR)
your_currency = 'EUR'
interrupted = false
refresh_rate = 3  # do not put under 1 second

trap('INT') do
  puts 'Closing...'
  interrupted = true
end

puts 'Press Ctrl-C to exit'

panel = Panel.new(currencies, your_currency)

until interrupted
  panel.refresh
  sleep(refresh_rate)
end

puts 'See you soon!'
