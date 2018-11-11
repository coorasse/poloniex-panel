require 'spec_helper'
require_relative '../lib/poloniex'
require 'dotenv/load'

RSpec.describe Poloniex do
  describe '#returnTicker', :vcr do
    it 'returns currencies values' do
      currencies = described_class.new.returnTicker
      puts currencies.to_json
      expect(currencies['BTC_BCN']['id']).to eq 7
      expect(currencies['USDT_BTC']['id']).to eq 121
      expect(currencies['USDT_BTC']['last']).to be_present
    end
  end

  describe '#returnBalances', :vcr do
    it 'returns your balances values' do
      balances = described_class.new.returnBalances
      puts balances.to_json
      expect(balances['BTC']).not_to be_nil
    end
  end
end
