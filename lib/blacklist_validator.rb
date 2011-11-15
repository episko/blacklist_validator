# -*- encoding: utf-8 -*-

class BlacklistValidator < ActiveModel::EachValidator
  attr_accessor :blacklist

  def initialize(options)
    load_blacklist!
    super(options)
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || invalid_message(record, attribute)) if blacklisted?(value)
  end

  #######################
  ### Private methods ###
  #######################

  private

  def invalid_message(record, attribute)
    I18n.t  :blacklisted,
            scope: "#{record.class.i18n_scope}.errors.models.#{record.class.model_name.i18n_key}.attributes.#{attribute}",
            default: "is blacklisted"
  end

  def blacklisted?(str)
    @blacklist.each { |word| return true if greedy_match?(str, word) }
    false
  end

  def greedy_match?(str, word)
    str =~ /(#{word})+/i
  end

  def load_blacklist!
    @blacklist = YAML::load(File.read(File.join(File.dirname(__FILE__), "../config/blacklist.yml")))
  end

end