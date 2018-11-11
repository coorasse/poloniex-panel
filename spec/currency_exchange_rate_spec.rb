require 'spec_helper'
require_relative '../lib/currency_exchange_rate'

RSpec.describe CurrencyExchangeRate do
  describe '#for', :vcr do
    it 'returns 1 for USD' do
      expect(described_class.for('USD')).to eq 1
    end

    it 'returns 0.8 for EUR' do
      expect(described_class.for('EUR')).to eq 0.84774
    end

    it 'returns 0.8 for CHF' do
      expect(described_class.for('CHF')).to eq 0.99008
    end
  end
end
