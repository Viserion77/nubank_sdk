# frozen_string_literal: true

RSpec.describe NubankSdk::Account do
  describe '.all' do
    let(:cpf) { '12345678909' }
    let(:password) { 'dracays' }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:key) { OpenSSL::PKey::RSA.new 2048 }
    let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}/#{cpf}.pem" }

    subject { described_class.new(cpf: cpf, key: key, adapter: [:test, stubs]) }

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
      certification = NubankSdk::Certificate.new(cpf, key)
      certification.process_decoded(dummy_certification)
    end

    context 'when the user is authenticated' do
      describe '#account_balance' do
        it 'returns the account balance' do
          stubs.post('/api/auth/login') { [200, {}, { token: 'token' }.to_json] }
          stubs.get('/api/app/discovery') { [200, {}, { 'token' => 'localhost:3000/api/app/token' }.to_json] }
          stubs.post('/api/app/token') { [200, {}, { access_token: 'token', _links: {
            ghostflame: { href: 'https://aa.aa/api/ghostflame_teste' } } }.to_json] }
          stubs.post('/https://aa.aa/api/ghostflame_teste') { [200, {}, { }].to_json }

          subject.auth.authenticate_with_certificate(password)

          expect(subject.account_balance).to eq(100)
        end
      end
    end

    def clear_certifications_folder
      File.delete(certificate_path) if File.exist?(certificate_path)
    end
  end
end