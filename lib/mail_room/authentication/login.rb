module MailRoom
  module Authentication
    # Login Authentication method
    # @author Kelly Rauchenberger
    class Login
      # Build a new authentication, hold the mailbox configuration
      # @param [MailRoom::Mailbox]
      def initialize(mailbox)
        @mailbox = mailbox
      end
      
      # Authenticate normally
      # @param imap [Net::IMAP] the IMAP connection to authenticate on
      def authenticate(imap)
        imap.login(@mailbox.email, @mailbox.password)
      end
    end
  end
end