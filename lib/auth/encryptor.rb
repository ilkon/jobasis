# frozen_string_literal: true

require 'bcrypt'

module Auth
  module Encryptor
    class << self
      def digest(password)
        password = "#{password}#{Attributor.pepper}" if Attributor.pepper.present?

        ::BCrypt::Password.create(password, cost: Attributor.stretches).to_s
      end

      def compare(hashed_password, password)
        return false if hashed_password.blank?

        bcrypt = ::BCrypt::Password.new(hashed_password)

        password = "#{password}#{Attributor.pepper}" if Attributor.pepper.present?

        password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
        secure_compare(password, hashed_password)
      end

      private

      # Constant-time comparison algorithm to prevent timing attacks
      def secure_compare(abc, xyz)
        return false if abc.blank? || xyz.blank? || abc.bytesize != xyz.bytesize

        l = abc.unpack "C#{abc.bytesize}"

        res = 0
        xyz.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
    end
  end
end
