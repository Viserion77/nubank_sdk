# frozen_string_literal: true

RSpec.describe NubankSdk::Certificate do
  let(:cpf) { '12345678909' }
  let(:key) { OpenSSL::PKey::RSA.new 2048 }
  subject { described_class.new(cpf) }

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
      cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
      cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
      cert.sign(key, OpenSSL::Digest::SHA256.new)
    end
  end
  let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}#{cpf}.p12" }

  before { clear_certifications_folder}

  describe '#process_decoded' do

    it 'creates a new file.p12' do
      subject.process_decoded(key, certificate)

      expect(File).to exist(certificate_path)
    end
  end

  describe '#encoded' do
    before { subject.process_decoded(key, certificate) }

    it 'returns a OpenSSL::PKCS12' do
      expect(subject.encoded).to be_a(OpenSSL::PKCS12)
    end
  end

  after { clear_certifications_folder }

  def clear_certifications_folder
    File.delete(certificate_path) if File.exist?(certificate_path)
  end
end
