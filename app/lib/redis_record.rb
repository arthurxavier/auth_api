# RedisRecord is a base class for models that use Redis as data store.
# It provides methods to save, retrieve, update, and delete records in Redis,
# simulating an ActiveRecord-like interface.
#
# Example usage:
#
# Structure
#
#   class User < RedisRecord
#     attr_accessor :id, :username, :password
#
#     identifier :id  # Specify which attribute is the identifier (e.g., :id)
#   end
#
#   user = User.new(id: 1, username: "john_doe", password: "securepass")
#   user.save  # Saves the user to Redis
#
# RedisRecord handles creating a Redis key and storing the record's attributes as a hash in Redis.

class RedisRecord
  class_attribute :_identifier, instance_writer: false, default: :id

  attr_accessor :created_at, :updated_at

  def self.identifier(attr = nil)
    self._identifier = attr if attr
    _identifier
  end

  def self.redis_key(value)
    "#{self.name.downcase}:#{value}"  #Example: "user:john_doe"
  end

  def self.set(attributes)
    key = redis_key(attributes[self.identifier])
    now = Time.now.to_i

    if $redis.exists?(key)
      attributes[:updated_at] ||= now
    else
      attributes[:created_at] ||= now
      attributes[:updated_at] ||= now
    end

    attributes.each { |field, value| $redis.hset(key, field, value) }
  end

  def self.exists?(value)
    $redis.exists?(redis_key(value))
  end

  def self.new_record?(value)
    !$redis.exists?(redis_key(value))
  end

  def save
    return false unless valid?

    self.class.set(attributes)
    @persisted = true
    true
  end

  def self.count
    $redis.keys("#{self.name.downcase}:*").count
  end

  def self.all
    key_pattern = "#{self.name.downcase}:*"

    keys = $redis.keys(key_pattern)

    records = keys.map do |key|
      record_data = $redis.hgetall(key)
      record = new(record_data)
      record
    end

    records.sort_by { |record| record.created_at }
  end

  def self.find(value)
    user_data = $redis.hgetall(redis_key(value))
    raise RecordNotFound, "Record with value #{value} not found" if user_data.blank?

    new(user_data)
  end

  def self.find_by(attribute, value)
    all_records = self.all
    found_record = all_records.find { |record| record.send(attribute) == value }
    found_record
  end

  def self.create(attributes)
    record = new(attributes)
    if record.save
      record
    else
      nil
    end
  end

  def self.first
    self.all.first
  end

  def self.last
    self.all.last
  end

  def self.delete(id)
    if exists?(id)
      $redis.del(redis_key(id))
      true
    else
      raise RecordNotFound, "Record with value #{id} not found"
    end
  end

  def self.delete_keys
    keys = $redis.keys("#{self.name.downcase}:*")
    $redis.del(*keys) unless keys.empty?
  end

  class << self
    alias_method :destroy_all, :delete_keys
    alias_method :delete_all, :delete_keys
  end

  def destroy
    self.class.delete(self.send(self.class.identifier))
  end

  class RecordNotFound < StandardError; end
end
