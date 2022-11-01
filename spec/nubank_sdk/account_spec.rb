RSpec.describe NubankSdk::Account do
  subject(:account) do
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
    build(:api_routes, paths: { ssl: { query: 'https://aa.aa/api/ghostflame_teste' } })
  end

  describe '#balance' do
    it 'returns the account balance' do
      stubs.post('https://aa.aa/api/ghostflame_teste') do
        [200,
         {},
         { data: { viewer: { savingsAccount: { currentSavingsBalance: { netAmount: 100 } } } } }.to_json]
      end

      expect(account.balance).to eq(100)
    end
  end
end
