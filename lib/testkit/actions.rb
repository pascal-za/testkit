module TestKit
  module Actions
    def click(identifier)
      execute("findWithin", identifier) do |result|
        execute("click")
      end
    end
    
    def fill_in_with_defaults(klass_template)
      raise "No structure DSL specified for #{klass_template}, is Migrant installed and its DSL filled out?" unless klass_template.respond_to?(:schema)
      
      fill_in(klass_template.schema.columns.collect { |name, column| [name, column.example] })
    end
    
    def fill_in(fields)
      fields.each do |field_name, value|
        execute("findWithin", field_name) do |result|
          execute("set", value)
        end
      end
    
    end
    
    def within(selector, &block)
      instance_eval(&block)
    end
    
  end
end
