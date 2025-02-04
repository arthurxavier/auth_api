namespace :db do
  desc "Populate Redis with seed data"
  task seed: :environment do
    users = [
      { username: "john_doe", password: "Password#123" },
      { username: "jane_doe", password: "Strong_Password$456" },
      { username: "alice_smith", password: "$Password#789!" },
      { username: "bob_jones", password: "SecurePass#101112" }
    ]

    users.each do |user_data|
      user = User.create(username: user_data[:username], password: user_data[:password])
      puts "User #{user.username} created in Redis!"
    end
  end
end
