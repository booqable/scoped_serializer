require 'scoped_serializer/scope'
require 'scoped_serializer/base_serializer'
require 'scoped_serializer/serializer'
require 'scoped_serializer/default_serializer'
require 'scoped_serializer/array_serializer'
require 'scoped_serializer/collection_serializer'

##
# ScopedSerializer takes care of complex and abstract serialization classes.
# It does this by allowing serialization scopes. For example, you can define a collection and a resource scope.
# This means you can render a different JSON output based on context (index/show).
# You can define any scope you want, there are no predefined scopes.
#
# ScopedSerializer supports association and automatically eager loads them when needed.
#
# @example
#
#   class OrderSerializer < ScopedSerializer::Serializer
#     attributes :status, :price_in_cents
#
#     scope :collection do
#       association :customer => :addresses
#     end
#
#     scope :resource do
#       association :customer
#       association :notes, :employee
#     end
#   end
#
#  ScopedSerializer.render(@order, :scope => :resource)
#  ScopedSerializer.render(Order.order('id ASC'), :scope => :collection)
#

module ScopedSerializer

  class << self

    ##
    # Renders a given object.
    # Object can be an ActiveRecord object, array or a ActiveRecord collection.
    #
    # @return [Hash]
    #
    def render(object, options={})
      options.merge!({
        :super => true
      })

      self.for(object, options).as_json
    end

    ##
    # Returns an instantized serializer for the given object.
    #
    def for(object, options={})
      if object.respond_to?(:each)
        serializer = find_serializer(object)
      else
        serializer = options[:serializer] || find_serializer(object) || DefaultSerializer
      end

      serializer.new(object, options) if serializer
    end

    ##
    # Finds serializer based on object's class.
    #
    def find_serializer(object)
      return object.serializer_class if object.respond_to?(:serializer_class)

      case object
      when ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy
        CollectionSerializer
      when Array
        ArraySerializer
      else
        find_serializer_by_class(object.class)
      end
    end

    def find_serializer_by_class(object_class)
      "#{object_class.name}Serializer".safe_constantize
    end

  end
end
