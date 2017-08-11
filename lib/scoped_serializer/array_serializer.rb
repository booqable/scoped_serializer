module ScopedSerializer
  class ArraySerializer < BaseSerializer

    attr_reader :array, :options

    def initialize(array, options={})
      @array = array
      @options = options || {}
      @options[:each_serializer] ||= @options.delete(:serializer)
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
        csv << columns if columns.present?

        serializable_objects.each do |object|
          csv << object.attributes_hash.values
        end
      end
    end

    protected

      def serializable_objects
        @serializable_objects ||= array.collect do |object|
          ScopedSerializer.for(object, @options.merge(:root => false, :serializer => @options[:each_serializer]))
        end
      end

  end
end
