# frozen_string_literal: true

require 'json'

RSpec.describe NubankSdk::Client do
  describe '.get_body' do
    it 'returns the body parsed as json' do
      response = instance_double('response', body: '{"foo": "bar"}')

      body = described_class.get_body(response)

      expect(body).to eq({ foo: 'bar' })
    end
  end

  context 'when use HTTP' do
    subject(:client) { described_class::HTTP.new(base_url, [:test, stubs]) }

    let(:base_url) { 'http://example.com' }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }

    describe '#post' do
      it 'posts a request to the given path' do
        stubs.post('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = client.post('/foo', { foo: 'bar' })

        expect(response.status).to eq(200)
      end
    end

    describe '#get' do
      it 'gets a request to the given path' do
        stubs.get('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = client.get('/foo')

        expect(response.status).to eq(200)
      end
    end
  end

  context 'when use HTTPS' do
    subject(:client) { described_class::HTTPS.new(encoded_certificate, [:test, stubs]) }

    let(:encoded_certificate) { build(:encoded_certificate) }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }

    describe '#post' do
      it 'posts a request to the given path' do
        stubs.post('/foo') { [200, {}, { foo: 'bar' }.to_json] }

        response = client.post('/foo', { foo: 'bar' })

        expect(response.status).to eq(200)
      end

      it 'posts a request with the given headers' do
        stubs.post('/foo') { [200, {}, { foo: 'bar' }.to_json] }
        client.headers = { 'X-Custom-Header' => 'custom' }

        client.post('/foo', { foo: 'bar' })

        expect(client.headers).to eq({ 'X-Custom-Header' => 'custom' })
      end
    end
  end
end
