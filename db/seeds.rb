alice = User.create!(email: "alice@example.com", pin_digest: BCrypt::Password.create("1234"))
alice.create_account!(balance: 1000.00)

bob = User.create!(email: "bob@example.com", pin_digest: BCrypt::Password.create("5678"))
bob.create_account!(balance: 500.00)
