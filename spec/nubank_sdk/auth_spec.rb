# frozen_string_literal: true

RSpec.describe NubankSdk::Auth do
  subject(:auth) do
    described_class.new(cpf: '1235678909', device_id: '909876543210', connection_adapter: [:test, stubs],
                        api_routes: api_routes)
  end

  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:key) { OpenSSL::PKey::RSA.new 2048 }
  let(:dummy_certification) { build :certificate, key: key }
  let(:api_routes) do
    build(:api_routes, paths: {
            app: {
              token: 'https://aa.aa/api/token_teste',
              gen_certificate: 'https://aa.aa/api/login_teste'
            }
          })
  end
  let(:https_connection) { build(:https_connection, connection_adapter: [:test, stubs]) }

  before do
    stub_certificate = Struct.new(:encoded, :process_decoded).new(dummy_certification, nil)
    allow(stub_certificate).to receive(:process_decoded).and_return(nil)
    allow(NubankSdk::Certificate).to receive(:new).and_return(stub_certificate)
    allow(OpenSSL::PKey::RSA).to receive(:new).and_return(key)
    allow(NubankSdk::Client::HTTPS).to receive(:new).and_return(https_connection)
  end

  describe '#authenticate_with_certificate' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/token_teste') do
        [200, {}, { access_token: '1234567890', _links: { revoke_token: {}, ghostflame: {} } }.to_json]
      end

      auth.authenticate_with_certificate('dracarys')
      expect(auth.access_token).to eq('1234567890')
    end
  end

  describe '#request_email_code' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') do
        [200, { 'WWW-Authenticate': 'sent_to=vi*@e*.*on' }, {}.to_json]
      end

      email = auth.request_email_code('dracarys')[:sent_to]
      expect(email).to eq('vi*@e*.*on')
    end
  end

  describe '#exchange_certs' do
    before do
      allow(auth.certificate)
    end

    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') do
        [200, {}, { certificate: dummy_certification }.to_json]
      end

      auth.exchange_certs('77', 'dracarys')
      expect(auth.certificate).to have_received(:process_decoded).once
    end
  end

  describe '#generate_device_id' do
    it 'returns a valid device id' do
      expect(auth.send(:generate_device_id).length).to eq(12)
    end
  end

  describe '#def_encrypted_code=' do
    it 'define a value to encripted code' do
      expect(auth.send(:def_encrypted_code=, 123)).to eq(123)
    end
  end
end
