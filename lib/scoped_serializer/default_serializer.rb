module ScopedSerializer
  class DefaultSerializer < BaseSerializer

    def initialize(resource, scope=:default, options={})
      @resource = resource
    end

    def as_json(options={})
      @resource.as_json(options)
    end

  end
end
