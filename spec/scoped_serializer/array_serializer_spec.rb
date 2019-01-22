require 'spec_helper'

describe ScopedSerializer::ArraySerializer do

  include_context :dummy_serializers

  let(:array) { [post_1, post_2] }

  describe '#meta' do

    it 'should add meta when array responds to total_count' do
      array.stub(:total_count).and_return(2)
      serializer = ScopedSerializer::ArraySerializer.new(array, :root => :posts)

      serializer.meta.should == { :total_count => 2 }
      serializer.as_json[:meta][:total_count].should == 2
    end

  end

  describe '#to_csv' do

    it 'should render columns and attributes as csv' do
      serializer = ScopedSerializer::ArraySerializer.new(array, :root => :posts)
      data = serializer.to_csv(:columns => ['title', 'rating'])

      rows = CSV.parse(data)
      rows[0].should == ['title', 'rating']
      rows[1].should == [post_1.title, post_1.rating.to_f.to_s]
      rows[2].should == [post_2.title, post_2.rating.to_f.to_s]
    end

  end

  describe '#to_xls' do

    it 'should render columns and attributes as xls' do
      serializer = ScopedSerializer::ArraySerializer.new(array)
      data = serializer.to_xls(:columns => ['title', 'rating'])

      rows = CSV.parse(data, :col_sep => "\t")
      rows[0].should == ['title', 'rating']
      rows[1].should == [post_1.title, post_1.rating.to_f.to_s]
      rows[2].should == [post_2.title, post_2.rating.to_f.to_s]
    end

  end

end
