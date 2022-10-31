# frozen_string_literal: true

RSpec.describe NubankSdk::Account do
  describe '.all' do
    let(:cpf) { '12345678909' }
    let(:password) { 'dracays' }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:key) { OpenSSL::PKey::RSA.new 2048 }
    let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}/#{cpf}.pem" }
    let(:api_routes) do
      api = NubankSdk::ApiRoutes.new
      api.add_entrypoint(path: :ssl, entrypoint: :query, url: 'https://aa.aa/api/ghostflame_teste')
      api
    end

    subject { described_class.new(
      connection: NubankSdk::Client::HTTPS.new(
        NubankSdk::Certificate.new(cpf).encoded,
        [:test, stubs]
      ),
      api_routes: api_routes
    ) }

    before do
      clear_certifications_folder
      dummy_certification = OpenSSL::X509::Certificate.new.tap do |cert|
        cert.version = 2
        cert.serial = 0
        cert.subject = OpenSSL::X509::Name.parse '/CN=example.com'
        cert.issuer = cert.subject
        cert.public_key = key.public_key
        cert.not_before = Time.now
        cert.not_after = Time.now + 3600
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = cert
        cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
        cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
        cert.sign key, OpenSSL::Digest::SHA256.new
      end
      certification = NubankSdk::Certificate.new(cpf)
      certification.process_decoded(key, dummy_certification)
    end

    context 'when the user is authenticated' do
      describe '#balance' do
        it 'returns the account balance' do
          stubs.post('https://aa.aa/api/ghostflame_teste') { [200, {}, {data: {viewer: {savingsAccount: {currentSavingsBalance: {netAmount: 100}}}}}.to_json] }

          expect(subject.balance).to eq(100)
        end
      end
    end

    def clear_certifications_folder
      File.delete(certificate_path) if File.exist?(certificate_path)
    end
  end
end