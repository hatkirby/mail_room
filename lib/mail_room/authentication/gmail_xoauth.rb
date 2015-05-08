require 'gmail_xoauth'
require 'oauth2'

module MailRoom
  module Authentication
    # GmailXOAuth Authentication method
    # @author Kelly Rauchenberger
    class GmailXOAuth
      # Build a new authentication, hold the mailbox configuration
      # @param [MailRoom::Mailbox]
      def initialize(mailbox)
        @mailbox = mailbox
        
        @oauth_client = OAuth2::Client.new(@mailbox.client_id, @mailbox.client_secret,  {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth', :token_url => '/o/oauth2/token'})
        @access_token = OAuth2::AccessToken.from_hash(@oauth_client, :refresh_token => @mailbox.refresh_token).refresh!
      end
      
      # Authenticate using gmail_xoauth and the provided access token
      # @param imap [Net::IMAP] the IMAP connection to authenticate on
      def authenticate(imap)
        begin
          imap.authenticate('XOAUTH2', @mailbox.email, @access_token.token)
        rescue Net::IMAP::NoResponseError
          @access_token = OAuth2::AccessToken.from_hash(@oauth_client, :refresh_token => @mailbox.refresh_token).refresh!
          
          begin
            imap.authenticate('XOAUTH2', @mailbox.email, @access_token.token)
          rescue Net::IMAP::NoResponseError
            return false
          end
        end
        
        return true
      end
    end
  end
end