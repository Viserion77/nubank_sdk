require 'openssl'

module NubankSdk
  class Certificate
    FILES_PATH = './certificates/'.freeze

    #
    # Controller of certifications
    #
    # @param [String] cpf
    def initialize(cpf)
      @cpf = cpf
    end

    #
    # Create a certificate file
    #
    # @param [OpenSSL::PKey::RSA] key
    # @param [String] certificate
    #
    # @return [File]
    def process_decoded(key, certificate)
      encoded = encode certificate

      p12 = create_pkcs12_from(key, encoded)
      save p12
    end

    #
    # Load the certificate file
    #
    # @return [OpenSSL::PKCS12]
    def encoded
      @encoded ||= OpenSSL::PKCS12.new(file.read, 'password')
    end

    private

    # @!visibility private
    # Open the encrypted certificate file
    #
    # @return [OpenSSL::PKCS12]
    def file
      File.open("#{FILES_PATH}#{@cpf}.p12", 'rb')
    end

    # @!visibility private
    # Create a file with the encrypted certificate
    #
    # @param [OpenSSL::PKCS12] p12
    #
    # @return [File]
    def save(p12)
      File.open("#{FILES_PATH}#{@cpf}.p12", 'wb') do |file|
        file.write p12.to_der
      end
    end

    # @!visibility private
    # crypt key and certificate to pkcs12
    #
    # @param [OpenSSL::PKey::RSA] key
    # @param [OpenSSL::X509::Certificate] certificate
    #
    # @return [OpenSSL::PKCS12]
    def create_pkcs12_from(key, certificate)
      OpenSSL::PKCS12.create('password', 'key', key, certificate)
    end

    # @!visibility private
    # Enconde certificate string to certificate object
    #
    # @param [String] certificate
    #
    # @return [OpenSSL::X509::Certificate]
    def encode(certificate)
      OpenSSL::X509::Certificate.new certificate
    end
  end
end
