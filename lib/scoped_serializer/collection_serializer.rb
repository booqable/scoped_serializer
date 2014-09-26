module ScopedSerializer
  class CollectionSerializer < ArraySerializer

    def initialize(*args)
      super

      # Configure root element
      @options[:root] = default_root_key(@array.klass).pluralize if @options[:root].nil?
    end

  end
end
