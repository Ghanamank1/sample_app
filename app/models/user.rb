class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token, :reset_token

    before_save   :downcase_email
    before_create :create_activation_digest
    
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, 
              presence:true, 
              length: {maximum: 255}, 
              format: {with: VALID_EMAIL_REGEX}, 
              uniqueness: { case_sensitive: false}
    validates :name, 
              presence: true, 
              length: {maximum: 50}
    validates :password,
              presence:true,
              length: {minimum: 6},
              allow_nil: true 

    has_secure_password

    # returns the hash digest of the given string. 
    # for the password in the Usertest helper 
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                        BCrypt::Engine.cost

        BCrypt::Password.create(string, cost: cost)
    end

    # returns a random token
    # for the remember digest
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # remembers a user in the database for use in persistent
    # sessions
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest
    def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # Forgets a user 
    def forget 
        update_attribute(:remember_digest, nil)
    end
    # NOTE: it seems to change the remember_digest in the data
    # base to nil so that we don't keep using it 
    # since if its there, then the user will be logged in at all
    # times. because of the authenticated? method
    # when user logs out, we forget them 

    # Sends the action email 
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # activates the account (in the database)
    def activate
        # after refactoring
        self.update_columns(
            activated: true, activated_at: Time.zone.now)
        
        # before refactoring
        # self.update_attribute(:activated, true)
        # self.update_attribute(:activated_at, Time.zone.now)  
    end

    def create_reset_digest 
        self.reset_token = User.new_token
        self.update_columns(
            reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
        self.reset_sent_at < 2.hours.ago
    end

    private 
        # Converts email to all lower-case.
        def downcase_email
            self.email = email.downcase 
        end 

        # Creates and assigns the activation token and digest
        def create_activation_digest 
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
