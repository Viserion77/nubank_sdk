FactoryBot.define do
  factory :api_routes, class: NubankSdk::ApiRoutes do
    transient do
      paths { {} }
    end

    skip_create
    initialize_with { new }

    after(:build) do |api_routes, transients|
      transients.paths.each do |path, links|
        links.each do |entrypoint, url|
          api_routes.add_entrypoint(
            path: path,
            entrypoint: entrypoint,
            url: url
          )
        end
      end
    end
  end
end
