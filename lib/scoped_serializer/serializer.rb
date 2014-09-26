module ScopedSerializer
  class Serializer < BaseSerializer

    class << self

      attr_accessor :default_scope, :scopes

      ##
      # Set default values.
      #
      def inherited(base)
        base.scopes = {}

        if scopes.present?
          # Inheritance from a serializer that has scoped defined
          scopes.each do |name, scope|
            base.scopes[name] = Scope.new(name, scope)
          end

          base.default_scope = base.find_scope(:default)
        else
          # Nothing to inherit, set defaults
          base.default_scope = Scope.new(:default)
          base.scopes = { :default => base.default_scope }
        end
      end

      ##
      # Defines a scope. In this scope all scopes methods are available. See {ScopedSerializer::Scope}
      #
      # @example
      #   scope :resource do
      #     association :notes, :employee
      #   end
      #
      def scope(name, &block)
        self.scopes[name] = Scope.new(name, self.default_scope, &block)
      end

      ##
      # Finds a defined scope by name.
      #
      def find_scope(name)
        self.scopes ||= {}
        self.scopes[name] || self.default_scope || Scope.new(:default)
      end

      ##
      # Define available default scope methods.
      # These are default values, thus define them on every scope.
      #
      Scope::METHODS.each do |method|
        define_method method do |*args|
          self.scopes.each do |name, scope|
            scope.send(method, *args)
          end
        end
      end

    end

    attr_reader :resource, :scope, :options

    def initialize(resource, scope=:default, options={})
      @resource = resource
      @options  = options || {}

      if options[:scope].present?
        scope = options[:scope]
      end

      if scope.is_a?(Symbol)
        @scope_name = scope
        @scope = self.class.find_scope(scope)
      else
        @scope_name = scope.name
        @scope = scope
      end

      set_scope(@scope)

      # Inherit options from scope
      @options = {}.merge(@scope.options).merge(@options)

      if @resource
        @options[:root] = default_root_key(@resource.class) unless @options.key?(:root)
      end
    end

    ##
    # Collects attributes for serialization.
    # Attributes can be overwritten in the serializer.
    #
    # @return [Hash]
    #
    def attributes_hash
      @scope.attributes.collect do |attr|
        [attr, fetch_property(attr)]
      end.to_h
    end

    ##
    # Collects associations for serialization.
    # Associations can be overwritten in the serializer.
    #
    # @return [Hash]
    #
    def associations_hash
      hash = {}
      @scope.associations.each do |association, options|
        hash.merge!(render_association(association, options))
      end
      hash
    end

    ##
    # Renders a specific association.
    #
    # @return [Hash]
    #
    # @example
    #   render_association(:employee)
    #   render_association([:employee, :company])
    #   render_association({ :employee => :address })
    #
    def render_association(association_data, options={})
      hash = {}

      if association_data.is_a?(Hash)
        association_data.each do |association, association_options|
          data = render_association(association, options.merge(:include => association_options))
          hash.merge!(data) if data
        end
      elsif association_data.is_a?(Array)
        association_data.each do |option|
          data = render_association(option)
          hash.merge!(data) if data
        end
      else
        if options[:preload]
          includes = options[:preload] == true ? options[:include] : options[:preload]
        end

        object  = fetch_association(association_data, includes)
        data    = ScopedSerializer.for(object, :default, options.merge(:associations => options[:include])).as_json

        hash.merge!(data) if data
      end

      hash
    end

    ##
    # Fetches property from the serializer or resource.
    # This method makes it possible to overwrite defined attributes or associations.
    #
    def fetch_property(property)
      return nil unless property

      unless respond_to?(property)
        object = @resource.send(property)
      else
        object = send(property)
      end
    end

    ##
    # Fetches association and eager loads data.
    # Doesn't eager load when includes is empty or when the association has already been loaded.
    #
    # @example
    #   fetch_association(:comments, :user)
    #
    def fetch_association(name, includes=nil)
      association = fetch_property(name)

      if includes.present? && ! @resource.association(name).loaded?
        association.includes(includes)
      else
        association
      end
    end

    ##
    # The serializable hash returned.
    #
    def serializable_hash(options={})
      {}.merge(attributes_hash).merge(associations_hash)
    end

  end
end
