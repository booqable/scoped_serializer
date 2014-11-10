module ScopedSerializer
  class Scope

    METHODS = [:root, :attributes, :association, :belongs_to, :has_one, :has_many]

    attr_accessor :name, :attributes, :associations, :options

    class << self

      ##
      # Initializes a scope from hash.
      #
      # @example
      #   Scope.from_hash({ :attributes => [:title, :created_at] })
      #
      def from_hash(data={})
        scope = new self
        scope.attributes *data[:attributes]

        (data[:associations] || []).each do |association|
          scope.association association
        end

        scope
      end

    end

    def initialize(name, default=nil, &block)
      @name = name
      @options = {}
      @attributes = []
      @associations = {}

      # Merge defaults
      merge!(default) if default

      self.instance_eval &block if block_given?
    end

    ##
    # Merges data with given scope.
    #
    # @example
    #   scope.merge!(another_scope)
    #
    def merge!(scope)
      @options.merge!(scope.options)

      @attributes += scope.attributes
      @associations.merge!(scope.associations)

      @attributes.uniq!

      self
    end

    ##
    # Defines the root key.
    #
    # @example
    #   scope :collection
    #     root :reservations
    #   end
    #
    def root(key)
      @options.merge!({ :root => key })
    end

    ##
    # Defines attributes.
    #
    # @example
    #   scope :collection
    #     attributes :status
    #   end
    #
    def attributes(*attrs)
      if attrs.any?
        @attributes += attrs
        @attributes.uniq!
      else
        @attributes
      end
    end

    ##
    # Defines an association.
    #
    # @example
    #   scope :collection
    #     association :customer
    #     association :posts => :user, :serializer => UserPostSerializer, :root => :user_posts
    #   end
    #
    def association(*args)
      _association(args, { :preload => true })
    end
    alias :belongs_to :association
    alias :has_one    :association
    alias :has_many   :association

    ##
    # Duplicates scope.
    #
    def dup
      clone = Scope.new(name)
      clone.merge!(self)
    end

    ##
    # Actually defines the association but without default_options.
    #
    def _association(args, default_options={})
      return if options.nil?

      options = args.first

      if options.is_a?(Hash)
        options     = {}.merge(options)
        name        = options.keys.first
        properties  = options.delete(name)

        @associations[name] = default_options.merge({ :include => properties }).merge(options)
      elsif options.is_a?(Array)
        options.each do |option|
          association option
        end
      else
        @associations[options] = args[1] || {}
      end
    end

  end
end
