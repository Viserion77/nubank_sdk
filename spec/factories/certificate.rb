# frozen_string_literal: true

FactoryBot.define do
  factory :certificate, class: 'OpenSSL::X509::Certificate' do
    transient do
      key { OpenSSL::PKey::RSA.new 2048 }
    end

    skip_create
    initialize_with { OpenSSL::X509::Certificate.new }

    after(:build) do |certificate, transients|
      certificate.tap do |cert|
        cert.version = 2
        cert.serial = 0
        cert.subject = OpenSSL::X509::Name.parse '/CN=example.com'
        cert.issuer = cert.subject
        cert.public_key = transients.key.public_key
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
        cert.sign(transients.key, OpenSSL::Digest.new('SHA256'))
      end
    end
  end

  factory :encoded_certificate, class: 'OpenSSL::PKCS12' do
    transient do
      key { OpenSSL::PKey::RSA.new 2048 }
      certificate { build(:certificate, key: key) }
    end

    skip_create
    initialize_with do
      p12 = OpenSSL::PKCS12.create('password', 'key', key, certificate)
      OpenSSL::PKCS12.new(p12.to_der, 'password')
    end
  end
end
