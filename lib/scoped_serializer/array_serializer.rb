module ScopedSerializer
  class ArraySerializer < BaseSerializer

    attr_reader :array, :scope, :scope_name, :options

    def initialize(array, scope_name=:default, options={})
      @array = array
      @scope_name = scope_name
      @options = options || {}
    end

    def serializable_hash(options={})
      array.collect do |object|
        ScopedSerializer.for(object, @scope_name, @options.merge(:root => false)).as_json
      end
    end

    def meta
      data = super

      if @array.respond_to?(:total_count)
        data = {}.merge(data).merge({ :total_count => @array.total_count })
      end

      data
    end

  end
end
