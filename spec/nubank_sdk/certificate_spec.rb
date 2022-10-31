RSpec.describe NubankSdk::Certificate do
  subject(:certificate_instance) { described_class.new(cpf) }

  let(:cpf) { '12345678909' }
  let(:key) { OpenSSL::PKey::RSA.new 2048 }

  let(:certificate) do
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
      cert.add_extension(
        ef.create_extension(
          'basicConstraints',
          'CA:TRUE',
          true
        )
      )
      cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
      cert.sign(key, OpenSSL::Digest::SHA256.new)
    end
  end
  let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}#{cpf}.p12" }

  before { clear_certifications_folder }

  describe '#process_decoded' do
    it 'creates a new file.p12' do
      certificate_instance.process_decoded(key, certificate)

      expect(File).to exist(certificate_path)
    end
  end

  describe '#encoded' do
    before { certificate_instance.process_decoded(key, certificate) }

    it 'returns a OpenSSL::PKCS12' do
      expect(certificate_instance.encoded).to be_a(OpenSSL::PKCS12)
    end
  end

  after { clear_certifications_folder }

  def clear_certifications_folder
    File.delete(certificate_path) if File.exist?(certificate_path)
  end
end
