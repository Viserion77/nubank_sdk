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
end
