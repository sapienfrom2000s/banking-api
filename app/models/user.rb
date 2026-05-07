class User < ApplicationRecord
  has_one :account, dependent: :destroy
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :pin_digest, presence: true

  def authenticate_pin(pin)
    BCrypt::Password.new(pin_digest).is_password?(pin)
  end
end
