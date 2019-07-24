module JsonSerializedAttribute
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def has_json_serialized_attribute(attr_name, options = {})
      define_method(attr_name) do
        saved_value = self.send("#{attr_name}_serialized")

        return nil if saved_value.nil? and options[:allow_nil]

        output = options[:default] ?
          JSON.parse( saved_value || options[:default].to_json )
        :
          JSON.parse( saved_value )

        if options[:after_decode]
          output = options[:after_decode].call(output)
        end

        output.is_a?(Hash) ? output.with_indifferent_access : output
      end

      define_method("#{attr_name}=") do |value|
        if options[:before_encode]
          value = options[:before_encode].call(value)
        end

        write_attribute("#{attr_name}_serialized", value.to_json)
      end
    end
  end
end
