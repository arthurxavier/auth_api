class UniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    existing_record = record.class.find_by(attribute, value)

    if existing_record && existing_record.send(attribute) == value
      record.errors.add(attribute, "has already been taken")
    end
  end
end
