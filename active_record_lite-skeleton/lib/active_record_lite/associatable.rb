require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :other_class_name, :foreign_key, :primary_key

  def other_class
    @other_class_name.constantize
  end

  def other_table
    self.other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams

  def initialize(name, params)
    @other_class_name = params[:class_name] || name.camelcase
    @foreign_key = params[:foreign_key] || "#{@other_class_name}_id"
    @primary_key = params[:primary_key] || "id"
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    p self

    # out = DBConnection.execute("
    #   SELECT *
    #   FROM #{aps.other_table}
    #   WHERE #{self.id} = #{aps.other_table}
    # ")
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
