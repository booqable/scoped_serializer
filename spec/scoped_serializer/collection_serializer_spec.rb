require 'spec_helper'

describe ScopedSerializer::CollectionSerializer do

  include_context :dummy_serializers

  let(:collection) { BlogPost.where({}) }

  describe '#to_csv' do

    it 'should render columns and attributes as csv' do
      serializer = ScopedSerializer::CollectionSerializer.new(collection)
      data = serializer.to_csv

      rows = CSV.parse(data)
      rows[0].should == ['title']
      rows[1].should == [post_1.title]
      rows[2].should == [post_2.title]
    end

  end

  describe '#to_xls' do

    it 'should render columns and attributes as xls' do
      serializer = ScopedSerializer::CollectionSerializer.new(collection)
      data = serializer.to_xls

      rows = CSV.parse(data, :col_sep => "\t")
      rows[0].should == ['title']
      rows[1].should == [post_1.title]
      rows[2].should == [post_2.title]
    end

  end

end
