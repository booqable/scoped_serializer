module ScopedSerializer
  class CollectionSerializer < ArraySerializer

    def initialize(*args)
      super

      # Configure root element
      @options[:root] = default_root_key(@array.klass).pluralize if @options[:root].nil?
    end

    def to_csv(options={})
      attributes = ScopedSerializer.find_serializer_by_class(@array.klass)
             .find_scope(options[:scope] || :default)
             .attributes

      super(options.merge(:columns => attributes))
    end

  end
end
