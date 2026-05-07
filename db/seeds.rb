alice = User.find_or_create_by!(email: "alice@example.com") { |u| u.pin_digest = BCrypt::Password.create("1234") }
Account.find_or_create_by!(user: alice) { |a| a.balance = 1000.00 }

bob = User.find_or_create_by!(email: "bob@example.com") { |u| u.pin_digest = BCrypt::Password.create("5678") }
Account.find_or_create_by!(user: bob) { |a| a.balance = 500.00 }
