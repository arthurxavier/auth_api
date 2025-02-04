require "rails_helper"

RSpec.describe RedisRecord, type: :lib do
  class TestRecord < RedisRecord
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :username, :email

    identifier :username

    validates :email, presence: true

    def attributes
      { username: @username, email: @email }
    end
  end

  let(:attribute_record1) do
    { username: "bob_doe", email: "bob@example.com", created_at: 2.days.ago.to_i, updated_at: 2.days.ago.to_i }
  end
  let(:attribute_record2) do
    { username: "alice_smith", email: "alice_smith@email.com", created_at: 1.day.ago.to_i }
  end

  let(:attributes) do
    [ attribute_record1, attribute_record2 ]
  end

  before do
    attributes.each do |attribute_record|
      key = TestRecord.redis_key(attribute_record[:username])
      attribute_record.each do |field, value|
        $redis.hset(key, field, value)
      end
    end
  end

  after do
    $redis.flushdb
  end

  describe ".identifier" do
    context "when setting the identifier" do
      it "sets the identifier for the class" do
        expect(TestRecord.identifier).to eq(:username)
      end

      it "sets the identifier for the instance" do
        record = TestRecord.new
        record.username = "john_doe"
        expect(record.send(record.class.identifier)).to eq("john_doe")
      end
    end

    context "when getting the identifier" do
      class NewClass < RedisRecord
        attr_accessor :id
      end

      it "returns the identifier for the class" do
        expect(NewClass.identifier).to eq(:id)
      end

      it "returns the identifier for the instance" do
        record = NewClass.new
        record.id = 3
        expect(record.send(record.class.identifier)).to eq(3)
      end
    end
  end

  describe ".redis_key" do
    context "when calling the method with an argument" do
      it "returns the key with the value" do
        expect(TestRecord.redis_key("john_doe")).to eq("testrecord:john_doe")
      end
    end

    context "when calling the method without an argument" do
      it "returns the key for all records" do
        expect(TestRecord.redis_key).to eq("testrecord:all")
      end
    end
  end

  describe ".set" do
    it "saves the data in Redis" do
      TestRecord.set({ username: "charlie_brown", email: "charlie@example.com" })
      data = $redis.hgetall("testrecord:charlie_brown")
      expect(data["username"]).to eq("charlie_brown")
      expect(data["email"]).to eq("charlie@example.com")
      expect(data["created_at"]).to be_present
      expect(data["updated_at"]).to be_present
    end

    context "when the created_at and updated_at fields are provided" do
      let(:manually_at) { 1.day.ago.to_i }

      it "saves the data in Redis with the provided timestamps" do
        TestRecord.set({ username: "charlie_brown", email: "charlie@example.com", created_at: manually_at, updated_at: manually_at })
        data = $redis.hgetall("testrecord:charlie_brown")
        expect(data["created_at"].to_i).to eq(manually_at)
        expect(data["updated_at"].to_i).to eq(manually_at)
      end
    end

    context "when the record already exists" do
      let(:created_at) { 2.days.ago.to_i }

      before do
        TestRecord.set({ username: "john_doe", email: "email@email.com", created_at: created_at, updated_at: created_at })
      end

      it "updates the record in Redis" do
        TestRecord.set({ username: "john_doe", email: "john_doe@email.com" })
        data = $redis.hgetall("testrecord:john_doe")
        expect(data["email"]).to eq("john_doe@email.com")
        expect(data["created_at"].to_i).to eq(created_at)
        expect(data["updated_at"]).to be_present
        expect(data["updated_at"].to_i).to be > data["created_at"].to_i
      end

      context "when is updated_at is updated manually" do
        let(:manually_at) { 1.day.ago.to_i }

        it "does not update the updated_at field" do
          TestRecord.set({ username: "john_doe", email: "email@email.com", updated_at: 1.day.ago.to_i })
          data = $redis.hgetall("testrecord:john_doe")
          expect(data["updated_at"].to_i).to eq(manually_at)
        end
      end
    end
  end

  describe ".exists?" do
    it "returns true if the record exists" do
      expect(TestRecord.exists?("bob_doe")).to be_truthy
    end

    it "returns false if the record does not exist" do
      expect(TestRecord.exists?("nonexistent_user")).to be_falsey
    end
  end

  describe "#save" do
    context "when the record is invalid" do
      it "does not save the record in Redis" do
        record = TestRecord.new(username: "bob_doe", email: nil)
        expect(record.save).to be_falsey
      end
    end

    context "when the record is valid" do
      context "when the record is new" do
        it "saves the record in Redis" do
          record = TestRecord.new(username: "john_doe", email: "email@email.com")

          expect(record.save).to be_truthy

          key = record.class.redis_key(record.username)
          saved_data = $redis.hgetall(key)
          expect(saved_data["username"]).to eq("john_doe")
          expect(saved_data["email"]).to eq("email@email.com")
        end
      end

      context "when the record already exists" do
        it "updates the record in Redis" do
          record = TestRecord.new(username: "alice_smith", email: "alice@example.com")
          record.save

          record_updated = TestRecord.new(username: "alice_smith", email: "new_email@example.com")

          expect(record_updated.save).to be_truthy

          key = record_updated.class.redis_key(record_updated.username)
          saved_data = $redis.hgetall(key)
          expect(saved_data["email"]).to eq("new_email@example.com")
        end
      end
    end
  end

  describe ".count" do
    it "returns the correct number of records in Redis" do
      expect(TestRecord.count).to eq(2)
    end

    context "when there are no records" do
      it "returns 0" do
        $redis.flushdb
        expect(TestRecord.count).to eq(0)
      end
    end
  end

  describe ".all" do
    it "returns all records from Redis" do
      records = TestRecord.all
      expect(records.map(&:username)).to match_array(%w[bob_doe alice_smith])
    end

    context "when there are no records" do
      it "returns an empty array" do
        $redis.flushdb
        expect(TestRecord.all).to be_empty
      end
    end
  end

  describe ".find" do
    it "finds the correct record by username" do
      # The search is now done by username, not by id
      record = TestRecord.find("bob_doe")
      expect(record.username).to eq("bob_doe")
    end

    context "when the record is not found" do
      it "raises an error with the correct message" do
        expect { TestRecord.find("nonexistent_user") }
          .to raise_error(RedisRecord::RecordNotFound, "Record with value nonexistent_user not found")
      end
    end
  end

  describe ".find_by" do
    it "finds a record by username" do
      record = TestRecord.find_by("username", "bob_doe")
      expect(record.email).to eq("bob@example.com")
    end

    it "returns nil if the record is not found" do
      expect(TestRecord.find_by("username", "nonexistent_user")).to be_nil
    end
  end

  describe ".create" do
    it "creates a new record in Redis" do
      # The creation is now done by the key using the username
      record = TestRecord.create(username: "john_doe", email: "email@email.com")
      expect(record.username).to eq("john_doe")
    end

    context "when the record is invalid" do
      it "returns a nil record" do
        record = TestRecord.create(username: "bob_doe", email: nil)
        expect(record).to be_nil
      end
    end
  end

  describe ".first" do
    it "returns the first record from Redis" do
      record = TestRecord.first
      expect(record.username).to eq("bob_doe")
    end

    context "when there are no records" do
      it "returns nil" do
        $redis.flushdb
        expect(TestRecord.first).to be_nil
      end
    end
  end

  describe ".last" do
    it "returns the last record from Redis" do
      record = TestRecord.last
      expect(record.username).to eq("alice_smith")
    end

    context "when there are no records" do
      it "returns nil" do
        $redis.flushdb
        expect(TestRecord.last).to be_nil
      end
    end
  end

  describe ".delete" do
    it "deletes a record from Redis" do
      expect($redis.exists?("testrecord:bob_doe")).to be_truthy
      expect { TestRecord.delete("bob_doe") }.to change { $redis.exists?("testrecord:bob_doe") }.from(true).to(false)
    end

    context "when the record does not exist" do
      it "raises an error" do
        expect { TestRecord.delete("nonexistent_user") }.to raise_error(RedisRecord::RecordNotFound).with_message("Record with value nonexistent_user not found")
      end
    end
  end

  describe ".destroy_all" do
    it "destroys all records from Redis" do
      expect { TestRecord.destroy_all }.to change { $redis.keys("testrecord:*").count }.from(2).to(0)
    end
  end

  describe ".delete_all" do
    it "deletes all records from Redis" do
      expect { TestRecord.delete_all }.to change { $redis.keys("testrecord:*").count }.from(2).to(0)
    end
  end

  describe "#destroy" do
    it "destroys the record from Redis" do
      record = TestRecord.create(username: "to_destroy", email: "to_destroy@email.com")

      expect { record.destroy }.to change { $redis.exists?("testrecord:to_destroy") }.from(true).to(false)
    end
  end
end
