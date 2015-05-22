require 'spec_helper'

describe ScopedSerializer::BaseSerializer do

  include_context :dummy_serializers

  describe '#default_root_key' do

    it 'it should lookup root key in serializer' do
      base_serializer = ScopedSerializer::BaseSerializer.new
      base_serializer.default_root_key(RootKey).should == 'some_key'
    end

    it 'should default to model class name' do
      base_serializer = ScopedSerializer::BaseSerializer.new
      base_serializer.default_root_key(BlogPost).should == 'blog_post'
    end

  end

end
