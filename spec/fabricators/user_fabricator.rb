Fabricator(:user) do
  username { Faker::Internet.username }
  password { Faker::Internet.password(min_length: 8, max_length: 16, mix_case: true, special_characters: true) }
end
