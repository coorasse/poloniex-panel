require 'spec_helper'
require_relative '../lib/coinbase_client'
require 'dotenv/load'

RSpec.describe CoinbaseClient do
  describe '#accounts', :vcr do
    it 'returns your wallets' do
      balances = described_class.new.accounts
      puts balances.to_json
      expect(balances).to be_a(Array)
    end
  end
end
