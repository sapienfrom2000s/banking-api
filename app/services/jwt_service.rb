class JwtService
  ALGORITHM = "HS256"
  SECRET = Rails.application.secret_key_base

  def self.encode(payload)
    payload[:exp] ||= 1.hour.from_now.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError
    nil
  end
end
