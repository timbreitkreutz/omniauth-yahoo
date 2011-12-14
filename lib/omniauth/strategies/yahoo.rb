require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies

    # An omniauth 1.0 strategy for yahoo authentication
    class Yahoo < OmniAuth::Strategies::OAuth
      
      option :name, 'yahoo'
      
      option :client_options, {
        :access_token_path => '/oauth/v2/get_token',
        :authorize_path => '/oauth/v2/request_auth',
        :request_token_path => '/oauth/v2/get_request_token',
        :site => 'https://api.login.yahoo.com'
      }

      uid { 
        access_token.params['xoauth_yahoo_guid']
      }
      
      info do 
        {
          :nickname => user_info['nickname'],
          :name => user_info['givenName'] || user_info['nickname'],
          :image => user_info['image']['imageUrl'],
          :description => user_info['message'],
          :urls => {
            'Profile' => user_info['profileUrl'],
          }
        }
      end
      
      extra do
        {
          :raw_info => raw_info
        }
      end

      # Return info gathered from the yahoo.people.getInfo API call 
     
      def raw_info
        # This is a public API and does not need signing or authentication
        request = "http://social.yahooapis.com/v1/user/#{uid}/profile?format=json"
        @raw_info ||= MultiJson.decode(access_token.get(request).body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      # Provide the "Person" portion of the raw_info
      
      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info["profile"]
      end
    end
  end
end
