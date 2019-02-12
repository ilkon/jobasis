# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::Authenticator, type: :model do
  describe '.tokens' do
    let(:user) { OpenStruct.new(id: 1313, name: 'John Doe') }

    context 'when refresh_exp is falsey' do
      it 'creates valid access token' do
        now = Time.now.utc.to_i
        access_token, = described_class.tokens(user)
        payload = described_class.send(:decode, access_token)

        expect(payload['sub']).to eql(user.id)
        expect(payload['iat']).to eql(now)
        expect(payload['exp']).to eql(now + Auth.access_token_ttl.to_i)
        expect(payload['name']).to eql(user.name)
      end

      it 'creates refresh token without expiration' do
        _, refresh_token, = described_class.tokens(user)
        refresh_payload = described_class.send(:decode, refresh_token)

        expect(refresh_payload['exp']).to be_nil
      end

      it 'creates matching tokens' do
        access_token, refresh_token, = described_class.tokens(user)
        payload = described_class.send(:decode, access_token)
        refresh_payload = described_class.send(:decode, refresh_token)
        payload_digest = described_class.send(:payload_digest, payload)

        expect(refresh_payload['acc']).to eql(payload_digest)
      end

      it 'creates matching access token and cookie' do
        access_token, _, cookie = described_class.tokens(user)
        payload = described_class.send(:decode, access_token)
        cookie_payload = described_class.send(:decode, cookie)
        payload_digest = described_class.send(:payload_digest, payload)

        expect(cookie_payload['dig']).to eql(payload_digest)
        expect(cookie_payload['iat']).to eql(payload['iat'])
      end

      it 'creates different tokens and cookie' do
        access_token, refresh_token, cookie = described_class.tokens(user)

        expect(access_token).not_to eql(refresh_token)
        expect(access_token).not_to eql(cookie)
        expect(refresh_token).not_to eql(cookie)
      end

      it 'creates valid access token for admin' do
        user2 = OpenStruct.new(id: 1313, name: 'John Doe', user_role: OpenStruct.new(admin: true))
        access_token, = described_class.tokens(user2)
        payload = described_class.send(:decode, access_token)

        expect(payload['admin']).to be_truthy
      end
    end

    context 'when refresh_exp is truthy' do
      it 'creates valid access token' do
        now = Time.now.utc.to_i
        access_token, = described_class.tokens(user, true)
        payload = described_class.send(:decode, access_token)

        expect(payload['sub']).to eql(user.id)
        expect(payload['iat']).to eql(now)
        expect(payload['exp']).to eql(now + Auth.access_token_ttl.to_i)
        expect(payload['name']).to eql(user.name)
      end

      it 'creates valid refresh token with expiration' do
        now = Time.now.utc.to_i
        _, refresh_token, = described_class.tokens(user, true)
        refresh_payload = described_class.send(:decode, refresh_token)

        expect(refresh_payload['exp']).to eql(now + Auth.refresh_token_ttl.to_i)
      end
    end

    context 'when refresh_exp is a number' do
      it 'creates valid access token' do
        now = Time.now.utc.to_i
        exp = 12_121_212
        access_token, = described_class.tokens(user, exp)
        payload = described_class.send(:decode, access_token)

        expect(payload['sub']).to eql(user.id)
        expect(payload['iat']).to eql(now)
        expect(payload['exp']).to eql(now + Auth.access_token_ttl.to_i)
        expect(payload['name']).to eql(user.name)
      end

      it 'copies expiration to new refresh token' do
        [12, Time.now.utc - 1.day, Time.now.utc, Time.now.utc + 1.week].each do |exp|
          _, refresh_token, = described_class.tokens(user, exp.to_i)
          refresh_payload = described_class.send(:decode, refresh_token, verify_expiration: false)

          expect(refresh_payload['exp']).to eql(exp.to_i)
        end
      end
    end
  end

  describe '.authenticate' do
    let(:user) { create(:user) }
    let(:payload) { { sub: user.id, iat: Time.now.utc.to_i, exp: Time.now.utc.to_i + Auth.access_token_ttl.to_i, name: user.name } }

    it 'authenticates with default params' do
      access_token = described_class.send(:encode, payload)
      refresh_payload = { acc: described_class.send(:payload_digest, payload) }
      refresh_token = described_class.send(:encode, refresh_payload)
      cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
      cookie = described_class.send(:encode, cookie_payload)

      auth, = described_class.authenticate(access_token, refresh_token, cookie)
      expect(auth).to eql(user)
    end

    context 'when refresh_token is not provided' do
      context 'when access_token has no subject' do
        it 'does not authenticate' do
          payload[:sub] = nil
          access_token = described_class.send(:encode, payload)
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, nil, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when access_token has no issued_at' do
        it 'does not authenticate' do
          payload[:iat] = nil
          access_token = described_class.send(:encode, payload)
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, nil, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when access_token has no expiration' do
        it 'does not authenticate' do
          payload[:exp] = nil
          access_token = described_class.send(:encode, payload)
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, nil, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when algorithm does not match' do
        it 'does not authenticate' do
          access_token = ::JWT.encode(payload, described_class.send(:hmac_secret), 'none')
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, nil, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when signature does not match' do
        it 'does not authenticate' do
          access_token = ::JWT.encode(payload, 'a new simple secret', 'HS256')
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, nil, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when access_token is expired' do
        it 'does not authenticate when expiration is significant' do
          access_token, _, cookie = described_class.tokens(user, nil)

          Timecop.travel(Auth.access_token_ttl + 1.minute) do
            auth = described_class.authenticate(access_token, nil, cookie)
            expect(auth).to be_nil
          end
        end

        it 'authenticates when expiration is not significant' do
          access_token, _, cookie = described_class.tokens(user, nil)

          Timecop.travel(Auth.access_token_ttl + 15.seconds) do
            auth = described_class.authenticate(access_token, nil, cookie)
            expect(auth).to eql(user)
          end
        end
      end

      context 'when access_token is not expired' do
        it 'does not authenticate when password is changed after token issued' do
          pwd = 'super-password'
          user = create(:user)
          user.create_user_password(password: pwd)

          access_token, _, cookie = described_class.tokens(user, nil)

          Timecop.travel(1.minute) do
            new_pwd = 'new-super-password'
            user.user_password.update(password: new_pwd)

            auth = described_class.authenticate(access_token, nil, cookie)
            expect(auth).to be_nil
          end
        end
      end
    end

    context 'when refresh_token has no expiration' do
      context 'when access_token is expired' do
        it 'does not authenticate when expiration is significant' do
          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.travel(Auth.access_token_ttl + 1.minute) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to be_nil
          end
        end

        it 'authenticates when expiration is not significant' do
          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.travel(Auth.access_token_ttl + 15.seconds) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to eql(user)
          end
        end
      end

      context 'when access_token is not expired' do
        it 'authenticates successfully' do
          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to eql(user)
          end
        end

        it 'returns new valid access_token' do
          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            _, new_access_token, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(new_access_token).not_to eql(access_token)

            new_payload = described_class.send(:decode, new_access_token, verify_expiration: false)
            expect(new_payload['sub']).to eql(user.id)
            expect(new_payload['iat']).to eql(Time.now.utc.to_i)
            expect(new_payload['exp']).to eql((Time.now.utc + Auth.access_token_ttl).to_i)
            expect(new_payload['name']).to eql(user.name)
          end
        end

        it 'returns new valid refresh_token without expiration' do
          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            _, _, new_refresh_token, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(new_refresh_token).not_to eql(refresh_token)

            new_payload = described_class.send(:decode, new_refresh_token, verify_expiration: false)
            expect(new_payload['exp']).to be_nil
          end
        end

        it 'does not authenticate when password is changed after tokens issued' do
          pwd = 'super-password'
          user = create(:user)
          user.create_user_password(password: pwd)

          access_token, refresh_token, cookie = described_class.tokens(user, nil)

          Timecop.travel(1.minute) do
            new_pwd = 'new-super-password'
            user.user_password.update(password: new_pwd)

            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to be_nil
          end
        end
      end
    end

    context 'when refresh_token is expired' do
      context 'when access_token is expired' do
        it 'does not authenticate when expiration is significant' do
          access_token, refresh_token, cookie = described_class.tokens(user, (Time.now.utc - Auth.refresh_token_ttl).to_i)

          Timecop.travel(Auth.access_token_ttl + 1.minute) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to be_nil
          end
        end

        it 'authenticates when expiration is not significant' do
          access_token, refresh_token, cookie = described_class.tokens(user, (Time.now.utc - Auth.refresh_token_ttl).to_i)

          Timecop.travel(Auth.access_token_ttl + 15.seconds) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to eql(user)
          end
        end
      end

      context 'when access_token is not expired' do
        it 'authenticates successfully' do
          access_token, refresh_token, cookie = described_class.tokens(user, (Time.now.utc - Auth.refresh_token_ttl).to_i)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to eql(user)
          end
        end

        it 'returns new valid access_token' do
          access_token, refresh_token, cookie = described_class.tokens(user, (Time.now.utc - Auth.refresh_token_ttl).to_i)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            _, new_access_token, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(new_access_token).not_to eql(access_token)

            new_payload = described_class.send(:decode, new_access_token, verify_expiration: false)
            expect(new_payload['sub']).to eql(user.id)
            expect(new_payload['iat']).to eql(Time.now.utc.to_i)
            expect(new_payload['exp']).to eql((Time.now.utc + Auth.access_token_ttl).to_i)
            expect(new_payload['name']).to eql(user.name)
          end
        end

        it 'returns new valid refresh_token without expiration' do
          access_token, refresh_token, cookie = described_class.tokens(user, (Time.now.utc - Auth.refresh_token_ttl).to_i)

          Timecop.freeze(Auth.access_token_ttl - 15.seconds) do
            _, _, new_refresh_token, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(new_refresh_token).not_to eql(refresh_token)

            new_payload = described_class.send(:decode, new_refresh_token, verify_expiration: false)
            expect(new_payload['exp']).to be_nil
          end
        end
      end
    end

    context 'when refresh_token is valid' do
      context 'when access_token is expired' do
        it 'authenticates in any case' do
          access_token, refresh_token, cookie = described_class.tokens(user, true)

          Timecop.travel(Auth.refresh_token_ttl - 15.seconds) do
            auth, = described_class.authenticate(access_token, refresh_token, cookie)
            expect(auth).to eql(user)
          end
        end
      end
    end

    context 'when refresh_token is invalid' do
      context 'when algorithm does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          payload_digest = described_class.send(:payload_digest, payload)
          cookie_payload = { dig: payload_digest, iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          refresh_payload = { acc: payload_digest }
          refresh_token = ::JWT.encode(refresh_payload, described_class.send(:hmac_secret), 'none')

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when signature does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          payload_digest = described_class.send(:payload_digest, payload)
          cookie_payload = { dig: payload_digest, iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          refresh_payload = { acc: payload_digest }
          refresh_token = ::JWT.encode(refresh_payload, 'a new simple secret', 'HS256')

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when payload does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          refresh_payload = { acc: described_class.send(:payload_digest, payload.merge(sub: user.id + 1)) }
          refresh_token = described_class.send(:encode, refresh_payload)

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when is not a JWT token' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          cookie_payload = { dig: described_class.send(:payload_digest, payload), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          refresh_token = 'Just a string'

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end
    end

    context 'when cookie is invalid' do
      context 'when algorithm does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          payload_digest = described_class.send(:payload_digest, payload)
          refresh_payload = { acc: payload_digest }
          refresh_token = described_class.send(:encode, refresh_payload)

          cookie_payload = { dig: payload_digest, iat: payload[:iat] }
          cookie = ::JWT.encode(cookie_payload, described_class.send(:hmac_secret), 'none')

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when signature does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          payload_digest = described_class.send(:payload_digest, payload)
          refresh_payload = { acc: payload_digest }
          refresh_token = described_class.send(:encode, refresh_payload)

          cookie_payload = { dig: payload_digest, iat: payload[:iat] }
          cookie = ::JWT.encode(cookie_payload, 'a new simple secret', 'HS256')

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when payload does not match' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          refresh_payload = { acc: described_class.send(:payload_digest, payload) }
          refresh_token = described_class.send(:encode, refresh_payload)

          cookie_payload = { dig: described_class.send(:payload_digest, payload.merge(sub: user.id + 1)), iat: payload[:iat] }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when is not a JWT token' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          refresh_payload = { acc: described_class.send(:payload_digest, payload) }
          refresh_token = described_class.send(:encode, refresh_payload)

          cookie = 'Just a string'

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when is empty' do
        it 'does not authenticate' do
          access_token = described_class.send(:encode, payload)
          refresh_payload = { acc: described_class.send(:payload_digest, payload) }
          refresh_token = described_class.send(:encode, refresh_payload)

          cookie = nil

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end

      context 'when issued_at does not match' do
        it 'authenticates when cookie issued short after token' do
          access_token = described_class.send(:encode, payload)
          refresh_payload = { acc: described_class.send(:payload_digest, payload) }
          refresh_token = described_class.send(:encode, refresh_payload)

          iat2 = payload[:iat] + 15
          exp2 = payload[:exp] + 15

          cookie_payload = { dig: described_class.send(:payload_digest, payload.merge(iat: iat2, exp: exp2)), iat: iat2 }
          cookie = described_class.send(:encode, cookie_payload)

          auth, = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to eql(user)
        end

        it 'does not authenticate when cookie issued before access token' do
          access_token = described_class.send(:encode, payload)
          refresh_payload = { acc: described_class.send(:payload_digest, payload) }
          refresh_token = described_class.send(:encode, refresh_payload)

          iat2 = payload[:iat] - 15
          exp2 = payload[:exp] - 15

          cookie_payload = { dig: described_class.send(:payload_digest, payload.merge(iat: iat2, exp: exp2)), iat: iat2 }
          cookie = described_class.send(:encode, cookie_payload)

          auth = described_class.authenticate(access_token, refresh_token, cookie)
          expect(auth).to be_nil
        end
      end
    end
  end
end
