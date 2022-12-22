# frozen_string_literal: true

RSpec.describe NubankSdk::User do
  subject(:user) { described_class.new(cpf: '12345678909') }

  describe '#auth' do
    it 'returns an instance of NubankSdk::Auth' do
      expect(user.auth).to be_an_instance_of(NubankSdk::Auth)
    end
  end

  context 'when the user is certificated' do
    let(:dummy_certificate) { build(:encoded_certificate) }

    before do
      certificate_mock = instance_double('certificate', encoded: dummy_certificate)
      allow(NubankSdk::Certificate).to receive(:new).and_return(certificate_mock)
    end

    describe '#account' do
      it 'returns an instance of NubankSdk::Account' do
        expect(user.account).to be_an_instance_of(NubankSdk::Account)
      end
    end

    describe '#credit' do
      it 'returns an instance of NubankSdk::Credit' do
        expect(user.credit).to be_an_instance_of(NubankSdk::Credit)
      end
    end
  end

  describe '#api_routes' do
    it 'returns an instance of NubankSdk::ApiRoutes' do
      expect(user.api_routes).to be_an_instance_of(NubankSdk::ApiRoutes)
    end
  end
end
