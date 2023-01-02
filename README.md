# NubankSdk

[![Version](https://img.shields.io/gem/v/nubank_sdk?color=%23701516&logo=ruby&logoColor=%23701516&style=for-the-badge)](https://rubygems.org/gems/nubank_sdk)
[![Downloads](https://img.shields.io/gem/dt/nubank_sdk?color=%23701516&logo=ruby&logoColor=%23701516&style=for-the-badge)](https://rubygems.org/gems/nubank_sdk)
[![Quality Inspector](https://github.com/Viserion77/nubank_sdk/actions/workflows/quality-inspector.yml/badge.svg?branch=develop&&event=push)](https://github.com/Viserion77/nubank_sdk/actions/workflows/quality-inspector.yml?branch=develop)

A gem to make it ease to monitorize your Nubank account.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nubank_sdk'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install nubank_sdk
```

## Usage

```ruby
require 'nubank_sdk'

# instance a nubank account object
user = NubankSdk::User.new cpf: '12345678909'
password = 'dracarys'
```

> First time? authenticate the account!
>
> ```ruby
> # request an email code
> account_email = user.auth.request_email_code(password)
> 
> # get the email code from the user
> puts "Enter the code sent to #{account_email}: "
> email_code = gets.chomp
> user.auth.exchange_certs(email_code, password)
> ```
>

Has a certificate? generate a access token :D
```ruby
user.auth.authenticate_with_certificate(password)
```

get the account balance

```ruby
account_balance = user.account.balance # => 77.0
```

## Development

> <details>
>
> <summary>Prerequisites</summary>
>
> - Ruby 2.7.2
> - Bundler
> - git
>
> Clone the repository:
> ```shell
> git clone https://github.com/viserion77/nubank_sdk.git
> ```
>
> Install the dependencies:
> ```shell
> bundle install
> ```
>
> </details>

- Create a new branch for your feature or bugfix
- Commit your changes, and push your branch to GitHub
- Open a Pull Request to the `develop` branch
- Write a description for your PR, and how to test it!
- Wait for the CI to run the tests and check the code quality
- If everything is ok, your PR will be merged

## Deployment

> <details>
>
> <summary>Prerequisites</summary>
>
> - Ruby 2.7.2
> - Bundler
> - git
>
> Clone the repository:
> ```shell
> git clone https://github.com/viserion77/nubank_sdk.git
> ```
>
> Install the dependencies:
> ```shell
> bundle install
> ```
>
> </details>

- Create a new branch from `develop` for bumping the version
- run `bundle exec rake start_new_release` to bump the version and a new tag
- Open a Pull Request to the `main` branch
- If everything is ok, your PR will be merged
- After the merge, the CI will publish the new version to rubygems.org
- If all goes well, you need release the new tag to GitHub. ([tags](https://github.com/Viserion77/nubank_sdk/tags))

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/viserion77/nubank_sdk.

This project was based on the python implementation in this project: [andreroggeri/pynubank](https://github.com/andreroggeri/pynubank)
