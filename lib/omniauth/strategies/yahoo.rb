require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies

    # An omniauth 1.0 strategy for yahoo authentication
    class Yahoo < OmniAuth::Strategies::OAuth

      option :name, 'yahoo'

      option :client_options, {
        :access_token_path  => '/oauth/v2/get_token',
        :authorize_path     => '/oauth/v2/request_auth',
        :request_token_path => '/oauth/v2/get_request_token',
        :site               => 'https://api.login.yahoo.com'
      }

      uid {
        access_token.params['xoauth_yahoo_guid']
      }

      info do
        primary_email = nil
        if user_info['emails']
          email_info    = user_info['emails'].find{|e| e['primary']} || user_info['emails'].first
          primary_email = email_info['handle']
        end
        {
          :nickname    => user_info['nickname'],
          :name        => "#{user_info['givenName']} #{user_info['familyName']}" || user_info['nickname'],
          :first_name  => user_info['givenName'],
          :last_name   => user_info['familyName'],
          :image       => user_info['image']['imageUrl'],
          :description => user_info['message'],
          :email       => primary_email,
          :urls        => {
            'Profile' => user_info['profileUrl'],
          }
        }
      end

      extra do
        hash = {}
        hash[:raw_info] = raw_info unless skip_info?
        hash[:contacts] = contacts_info
        hash
      end

      # Return info gathered from the v1/user/:id/profile API call

      def raw_info
        # This is a public API and does not need signing or authentication
        request = "http://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
        @raw_info ||= MultiJson.decode(access_token.get(request).body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "Contacts" portion of the raw_info

      def contacts_info
        request = "http://social.yahooapis.com/v1/user/#{uid}/contacts?format=json"
        @contacts_info ||= begin
          _contacts_info = slim(MultiJson.decode(access_token.get(request).body))
          @env['omniauth.contacts'] = _contacts_info
          _contacts_info
        end
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "Profile" portion of the raw_info

      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info["profile"]
      end

      private

      def slim(contacts)
        _contacts = []

        contacts['contacts']['contact'].each do |contact|
          email, nickname = nil, nil

          contact['fields'].each do |field|
            email = field['value'] if field['type'] == 'email'
            nickname = field['value'] if field['type'] == 'nickname'
          end
          _contacts << { :email => email, :nickname => nickname }
        end
        _contacts
      end
    end
  end
end
