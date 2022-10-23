# frozen_string_literal: true

require 'json'

RSpec.describe NubankSdk::Client do
  describe '.get_body' do
    it "returns the body parsed as json" do
      response = double(body: '{"foo": "bar"}')

      body = described_class.get_body(response)

      expect(body).to eq({ foo: 'bar' })
    end
  end

  context 'HTTP' do
    let(:base_url) { 'http://example.com' }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    
    subject { described_class::HTTP.new(base_url, [:test, stubs]) }

    describe '#post' do
      it "posts a request to the given path" do
        stubs.post('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = subject.post('/foo', { foo: 'bar' })

        expect(response.status).to eq(200)
      end
    end

    describe '#get' do
      it "gets a request to the given path" do
        stubs.get('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = subject.get('/foo')

        expect(response.status).to eq(200)
      end
    end
  end

  context 'HTTPS' do
    let(:key) { OpenSSL::PKey::RSA.new 2048 }
    let(:cpf) { '12345678909' }
    let(:certificate) do
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
        cert.sign(key, OpenSSL::Digest::SHA256.new)
      end
      certification = NubankSdk::Certificate.new(cpf, key)
      certification.process_decoded(dummy_certification)
      certification.encoded
    end
    let(:certificate_path) { "#{NubankSdk::Certificate::FILES_PATH}#{cpf}.p12" }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }

    subject { described_class::HTTPS.new(certificate, [:test, stubs]) }

    describe '#post' do
      it "posts a request to the given path" do
        stubs.post('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = subject.post('/foo', { foo: 'bar' })

        expect(response.status).to eq(200)
      end
    end

    after { clear_certifications_folder }
  
    def clear_certifications_folder
      File.delete(certificate_path) if File.exist?(certificate_path)
    end
  end
end
