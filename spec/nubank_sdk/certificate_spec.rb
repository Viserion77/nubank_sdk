# frozen_string_literal: true

RSpec.describe NubankSdk::Certificate do
  subject(:certificate_instance) { described_class.new(cpf) }

  let(:cpf) { '12345678909' }
  let(:key) { OpenSSL::PKey::RSA.new 2048 }

  let(:certificate) { build(:certificate, key: key) }
  let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}#{cpf}.p12" }

  before { clear_certifications_folder }

  after { clear_certifications_folder }

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

  def clear_certifications_folder
    File.delete(certificate_path) if File.exist?(certificate_path)
  end
end
