class MassObject
  # takes a list of attributes.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    @attributes = attributes.map do |attr|
      attr.to_sym
    end

    self.my_attr_accessor(*attributes)
  end

  # takes a list of attributes.
  # makes getters and setters
  def self.my_attr_accessor(*attributes)
    attributes.each do |attribute|
      #setter
      define_method(attribute) do
        self.instance_variable_get("@#{attribute}")
      end

      #getter
      define_method("#{attribute}=") do |value|
        self.instance_variable_set("@#{attribute}", value)
      end
    end
  end

  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    out_arr = []
    results.each do |obj_hash|
      out_arr << self.new(obj_hash)
    end
    out_arr
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
    params.each do |attr_name, attr_val|
      if self.class.attributes.include?(attr_name.to_sym)
        self.instance_variable_set("@#{attr_name}", attr_val)
        #self.send("#{attr_name}=", attr_val)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end
