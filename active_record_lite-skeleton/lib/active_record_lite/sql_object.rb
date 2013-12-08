require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  include Associatable

  # sets the table_name
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    arr = DBConnection.execute("
      SELECT *
      FROM #{self.table_name}
      ")
    self.parse_all(arr)
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    arr = DBConnection.execute("
      SELECT *
      FROM #{self.table_name}
      WHERE id = #{id}
      ")
    self.parse_all(arr).first
  end

  # call either create or update depending if id is nil.
  def save
    #should i make the attr here?
    #self.class.my_attr_accessor(*self.class.attributes)

    if self.id.nil?
      self.send(:create)
      self.id = DBConnection.last_insert_row_id()
    else
      self.send(:update)
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
    self.class.attributes.map do |attr_name|
      self.send(attr_name)
    end
  end

  private
    # executes query that creates record in db with objects attribute values.
    # use send and map to get instance values.
    # after, update the id attribute with the helper method from db_connection
    def create
      #should i make the attr here?
      #self.class.my_attr_accessor(*self.class.attributes)

      DBConnection.execute("
        INSERT INTO #{self.class.table_name}
        ( #{self.class.attributes.join(", ")} )
        VALUES
        ( #{self.class.attributes.count.times.map{"?"}.join(", ")} )",
        *attribute_values
        )
    end

    # executes query that updates the row in the db corresponding to this instance
    # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
    def update
      #should i make the attr here?
      #self.class.my_attr_accessor(*self.class.attributes)

      set_line = []
      self.class.attributes.each do |attr_name|
        set_line << "#{attr_name} = ?"
      end
      set_line = set_line.join(", ")

      DBConnection.execute("
        UPDATE #{self.class.table_name}
        SET #{set_line}
        WHERE id = #{self.send(:id)}",
        *attribute_values
        )
    end
end
