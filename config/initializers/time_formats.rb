Date::DATE_FORMATS[:abbrev_ordinal] = lambda do |date|
  date.strftime("%b #{ActiveSupport::Inflector.ordinalize(date.day)}, %Y")
end
