RSpec.describe NubankSdk::ApiRoutes do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:uri) { described_class::DISCOVERY_URI }
  let(:path) { '/api' }
  let(:full_url) { "#{uri}#{path}" }

  describe '#entrypoint' do
    context 'when url discovery map is empty' do
      subject(:api_routes) { described_class.new(connection_adapter: [:test, stubs]) }

      it 'returns the full url' do
        stubs.get("#{uri}/api/app/discovery") do
          [200, {}, { 'gen_certificate' => full_url }.to_json]
        end

        url = api_routes.entrypoint(path: :app, entrypoint: :gen_certificate)

        expect(url).to eq(full_url)
      end
    end

    context 'when url discovery map is not empty' do
      subject(:api_routes) { described_class.new(url_discovery_map: { app: url_map }) }

      let(:url_map) { { token: "#{full_url}/token" } }

      it 'returns the full url' do
        url = api_routes.entrypoint(path: :app, entrypoint: :token)

        expect(url).to eq(url_map[:token])
      end
    end
  end

  describe '#add_entrypoint' do
    subject(:api_routes) { described_class.new }

    it 'adds a new entrypoint to url discovery map' do
      api_routes.add_entrypoint(path: :ssl, entrypoint: :query, url: full_url)

      expect(api_routes.entrypoint(path: :ssl, entrypoint: :query)).to eq(full_url)
    end
  end
end
