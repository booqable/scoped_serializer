module ActionController
  module Serialization

    extend ActiveSupport::Concern

    ##
    # Returns scope based on action.
    #
    def serializer_scope
      scope = case action_name
      when 'new', 'show', 'edit', 'update', 'create', 'destroy'
        :resource
      when 'index'
        :collection
      else
        :default
      end
    end

    ##
    # Default serializer options.
    #
    def default_serializer_options
      {}
    end

    ##
    # JSON serializer to use.
    #
    def build_json_serializer(object, options={})
      ScopedSerializer.for(object, { :scope => serializer_scope, :super => true }.merge(options.merge(default_serializer_options)))
    end

    ##
    # Renders specific JSON serializer see {ScopedSerializer}.
    #
    [:_render_option_json, :_render_with_renderer_json].each do |method|
      define_method method do |resource, options|
        serializer = build_json_serializer(resource, options)

        if serializer
          super(serializer, options)
        else
          super(resource, options)
        end
      end
    end

  end
end
