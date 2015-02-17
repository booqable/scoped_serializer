module ScopedSerializer
  class ArraySerializer < BaseSerializer

    attr_reader :array, :scope, :scope_name, :options

    def initialize(array, scope_name=:default, options={})
      @array = array
      @scope_name = scope_name
      @options = options || {}
    end

    def serializable_hash(options={})
      serializable_objects.collect(&:as_json)
    end

    def meta
      data = super

      if @array.respond_to?(:total_count)
        data = {}.merge(data).merge({ :total_count => @array.total_count })
      end

      data
    end

    ##
    # Returns attributes as a CSV string.
    #
    def to_csv(options={})
      columns = options.delete(:columns)

      CSV.generate(options) do |csv|
        csv << columns if columns.any?

        serializable_objects.each do |object|
          csv << object.attributes_hash.values
        end
      end
    end

    protected

      def serializable_objects
        @serializable_objects ||= array.collect do |object|
          ScopedSerializer.for(object, @scope_name, @options.merge(:root => false))
        end
      end

  end
end
