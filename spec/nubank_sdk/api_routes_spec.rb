RSpec.describe NubankSdk::ApiRoutes do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:uri) { described_class::DISCOVERY_URI }

  describe '#entrypoint' do
    context "when url discovery map is empty" do
      subject { described_class.new(connection_adapter: [:test, stubs]) }

      it "returns the full url" do
        stubs.get("#{uri}/api/app/discovery") { [200, {}, { 'gen_certificate' => 'localhost:3000/api/app/gen_certificate' }.to_json] }

        url = subject.entrypoint(path: :app, entrypoint: :gen_certificate)

        expect(url).to eq("localhost:3000/api/app/gen_certificate")
      end
    end

    context "when url discovery map is not empty" do
      let(:url_map) { { token: 'localhost:3000/api/app/token' } }

      subject { described_class.new(url_discovery_map: { app: url_map }) }

      it "returns the full url" do
        url = subject.entrypoint(path: :app, entrypoint: :token)

        expect(url).to eq("localhost:3000/api/app/token")
      end
    end
  end

  describe '#add_entrypoint' do
    subject { described_class.new }

    it 'adds a new entrypoint to url discovery map' do
      subject.add_entrypoint(path: :ssl, entrypoint: :query, url: 'localhost:3000/api/app/query')

      expect(subject.entrypoint(path: :ssl, entrypoint: :query)).to eq('localhost:3000/api/app/query')
    end
  end
end
