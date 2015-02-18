module ScopedSerializer
  class CollectionSerializer < ArraySerializer

    def initialize(*args)
      super

      options = args.extract_options!

      # Allow to define own model class
      @model_class = options.delete(:model_class) || @array.klass

      # Configure root element
      @options[:root] = default_root_key(@model_class).pluralize if @options[:root].nil?
    end

    def to_csv(options={})
      attributes = ScopedSerializer.find_serializer_by_class(@model_class)
             .find_scope(options[:scope] || :default)
             .attributes

      super(options.merge(:columns => attributes))
    end

  end
end
