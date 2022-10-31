RSpec.describe NubankSdk::Auth do
  let(:cpf) { '1235678909'}
  let(:key) { OpenSSL::PKey::RSA.new 2048 }
  let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}#{cpf}.p12" }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:dummy_certification) do
    OpenSSL::X509::Certificate.new.tap do |cert|
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
      cert.sign(key, OpenSSL::Digest::SHA256.new)
    end
  end
  let(:api_routes) do
    api = NubankSdk::ApiRoutes.new
    api.add_entrypoint(path: :app, entrypoint: :token, url: 'https://aa.aa/api/token_teste')
    api.add_entrypoint(path: :app, entrypoint: :gen_certificate, url: 'https://aa.aa/api/login_teste')
    api
  end

  before do
    allow(subject).to receive(:generate_key).and_return(key)
  end

  subject { described_class.new(cpf: cpf, device_id: '909876543210', connection_adapter: [:test, stubs], api_routes: api_routes) }

  describe '#authenticate_with_certificate' do
    before do
      clear_certifications_folder
      certification = NubankSdk::Certificate.new(cpf)
      certification.process_decoded(key, dummy_certification)
    end

    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/token_teste') { [200, {}, { access_token: '1234567890', _links: {
        events: { href: 'https://aa.aa/api/events_teste' },
        customer: { href: 'https://aa.aa/api/customer_teste' },
        account: { href: 'https://aa.aa/api/account_teste' },
        bills_summary: { href: 'https://aa.aa/api/bills_summary_teste' },
        feed: { href: 'https://aa.aa/api/feed_teste' },
        bills: { href: 'https://aa.aa/api/bills_teste' },
        revoke_token: { href: 'https://aa.aa/api/revoke_token_teste' },
        ghostflame: { href: 'https://aa.aa/api/ghostflame_teste' },
      } }.to_json] }

      subject.authenticate_with_certificate('dracarys')
      expect(subject.access_token).to eq('1234567890')
    end
  end

  describe '#request_email_code' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') { [200, {'WWW-Authenticate': 'sent_to=vi****@se**.com'}, {}.to_json] }

      email = subject.request_email_code('dracarys')
      expect(email).to eq('vi****@se**.com')
    end
  end

  describe '#exchange_certs' do
    it 'returns a valid token' do
      stubs.post('https://aa.aa/api/login_teste') { [200, {}, {certificate: dummy_certification}.to_json] }

      subject.exchange_certs('77', 'dracarys')
      expect(File.exist?(certificate_path)).to be_truthy
    end
  end

  after { clear_certifications_folder }

  def clear_certifications_folder
    File.delete(certificate_path) if File.exist?(certificate_path)
  end
end
