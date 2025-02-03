# This validator handles the password strength validation
# - Minimum 8 characters
# - At least one uppercase letter
# - At least one number
# - At least one special character
class StrongPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*]).{8,}$/
      record.errors.add(attribute, "must include at least one uppercase letter, one number, and one special character")
    end
  end
end
