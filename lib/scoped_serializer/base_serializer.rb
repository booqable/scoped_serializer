module ScopedSerializer
  class BaseSerializer

    ##
    # Sets scope and settings based on @options.
    #
    def set_scope(scope)
      if @options[:associations].present? || @options[:attributes].present?
        @scope = scope.dup
        @scope.attributes *@options[:attributes] if @options[:attributes]
        @scope._association [@options[:associations]] if @options[:associations]
      else
        @scope = scope
      end
    end

    ##
    # Tries to find the default root key.
    #
    # @example
    #   default_root_key(User) # => 'user'
    #
    def default_root_key(object_class)
      if object_class.respond_to?(:model_name)
        object_class.model_name.element
      else
        object_class.name
      end
    end

    ##
    # Returns JSON using {serializable_hash} which must be implemented on a class.
    # Uses the root key from @options when set.
    #
    def as_json(options={})
      options = @options.merge(options)

      if options[:root]
        { options[:root].to_sym => serializable_hash }.merge(meta_hash)
      else
        serializable_hash
      end
    end

    def meta_hash
      if meta.present?
        { :meta => meta }
      else
        {}
      end
    end

    def meta
      @options[:meta] || {}
    end

  end
end
