# frozen_string_literal: true

RSpec.describe NubankSdk::Credit do
  subject(:credit) do
    described_class.new(
      connection: connection,
      api_routes: api_routes
    )
  end

  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    build(:https_connection, connection_adapter: [:test, stubs])
  end
  let(:api_routes) do
    build(:api_routes, paths: { ssl: {
            account: 'https://aa.aa/api/ghostflame_teste',
            feed: 'https://aa.aa/api/ghostflame_teste',
            customer: 'https://aa.aa/api/ghostflame_teste/customer_id'
          } })
  end

  describe '#balances' do
    it 'returns the credit balances' do
      stubs.get('https://aa.aa/api/ghostflame_teste') do
        [200, {}, { account: { balances: { credit: 100 } } }.to_json]
      end

      expect(credit.balances).to eq({ credit: 100 })
    end
  end

  describe '#feed' do
    it 'returns the credit feed' do
      stubs.get('https://aa.aa/api/ghostflame_teste') do
        [200, {}, { events: [{ amount: 100 }] }.to_json]
      end

      expect(credit.feed).to eq([{ amount: 100 }])
    end
  end

  describe '#cards' do
    it 'returns the cards summary' do
      stubs.get('https://prod-s7-mr-white.nubank.com.br/api/customers/customer_id/card-summaries') do
        [200, {}, { sections: [{ cards: [{ amount: 100 }] }] }.to_json]
      end

      expect(credit.cards).to eq([{ amount: 100 }])
    end
  end

  describe '#transaction_details' do
    it 'returns the transaction details' do
      stubs.get('https://prod-s7-showbillz.nubank.com.br/api/items/64bc3e6a-b286-4640-a1ad-922bd37a7e66/details') do
        [200, {}, { amount: 100 }.to_json]
      end

      expect(credit.transaction_details('64bc3e6a-b286-4640-a1ad-922bd37a7e66')).to eq({ amount: 100 })
    end
  end
end
