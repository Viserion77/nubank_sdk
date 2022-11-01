FactoryBot.define do
  factory :https_connection, class: NubankSdk::Client::HTTPS do
    transient do
      encoded_certificate { build(:encoded_certificate) }
      connection_adapter { nil }
    end

    headers { {} }

    skip_create
    initialize_with do
      NubankSdk::Client::HTTPS.new(
        encoded_certificate,
        connection_adapter
      )
    end
  end
end
