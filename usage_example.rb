require 'nubank_sdk'

# instance a nubank account object
user = NubankSdk::User.new(cpf: '12345678909')
password = 'dracarys'
# authenticate the account

# request an email code
account_email = user.auth.request_email_code(password)

# get the email code from the user
puts "Enter the code sent to #{account_email}: "
email_code = gets.chomp
user.auth.exchange_certs(email_code, password)

user.auth.authenticate_with_certificate(password)

# get the account balance
user.account.balance
