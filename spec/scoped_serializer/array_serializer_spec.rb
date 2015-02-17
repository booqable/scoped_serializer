require 'spec_helper'

describe ScopedSerializer::ArraySerializer do

  include_context :dummy_serializers

  describe '#meta' do

    it 'should add meta when array responds to total_count' do
      array = [post_1, post_2]
      array.stub(:total_count).and_return(2)
      serializer = ScopedSerializer::ArraySerializer.new(array, :root => :posts)

      serializer.meta.should == { :total_count => 2 }
      serializer.as_json[:meta][:total_count].should == 2
    end

  end

end
