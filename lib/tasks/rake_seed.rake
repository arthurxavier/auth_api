namespace :db do
  desc "Populate Redis with seed data"
  task :seed => :environment do
    user_data = {
      username: 'john',
      password: 'Password#123'
    }

    user_id = $redis.incr('user_id_counter')

    $redis.set("user:#{user_id}", user_data.to_json)

    puts "User #{user_data[:username]} created in Redis with ID #{user_id}!"
  end
end
