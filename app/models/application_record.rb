class ApplicationRecord < ActiveRecord::Base
  include Discard::Model
  include PgSearch::Model

  primary_abstract_class

  attr_accessor :admin
end
