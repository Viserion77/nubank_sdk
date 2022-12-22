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
    build(:api_routes, paths: { ssl: { account: 'https://aa.aa/api/ghostflame_teste' } })
  end

  describe '#balances' do
    it 'returns the credit balances' do
      stubs.get('https://aa.aa/api/ghostflame_teste') do
        [200, {}, { account: { balances: { credit: 100 } } }.to_json]
      end

      expect(credit.balances).to eq({ credit: 100 })
    end
  end
end
