require 'spec_helper'

describe ScopedSerializer::Serializer do

  include_context :dummy_serializers

  let(:serializer) { BlogPostSerializer.new(post_1) }

  describe 'options' do

    describe 'root' do

      it 'should define a root by options' do
        serializer = BlogPostSerializer.new(post_1, { :root => :test })
        serializer.stub(:serializable_hash).and_return({})

        serializer.as_json[:test].should == {}
      end

      it 'should define a root by scope' do
        scope = BlogPostSerializer.find_scope(:default)
        scope.root :test

        serializer = BlogPostSerializer.new(post_1)
        serializer.stub(:serializable_hash).and_return({})

        serializer.as_json[:test].should == {}
      end

    end

    describe 'scope' do

      it 'should set scope defined by options' do
        serializer = BlogPostSerializer.new(post_1, { :scope => :resource })
        serializer.scope.name.should == :resource
      end

      it 'should use custom scope from a hash' do
        serializer = BlogPostSerializer.new(post_1, { :scope => { :attributes => [:created_at] } })
        serializer.as_json.should == {
          :blog_post => {
            :created_at => post_1.created_at
          }
        }
      end

    end

  end

  describe '#attributes_hash' do

    it 'should iterate through attributes and render them' do
      serializer = BlogPostSerializer.new(post_1, :scope => :resource)
      serializer.attributes_hash.should == {
        :title => 'This is post 1'
      }
    end

  end

  describe '#associations_hash' do

    it 'should iterate through associations and render them' do
      serializer = BlogPostSerializer.new(post_1, :scope => :resource)
      serializer.associations_hash.should == {
        :user => {
          :name => 'John Doe'
        },
        :comments => [
          {
            :text => 'This is comment 1',
            :user => {
              :name => 'Jane Doe',
              :blog_posts => [
                {
                  :title => 'This is post 2'
                }
              ]
            }
          }
        ]
      }
    end

  end

  describe '#render_association' do

    it 'should return rendered association' do
      serializer.render_association(:user).should == { :user => { :name => 'John Doe' } }
      serializer.render_association(:user => :blog_posts).should == {
        :user => {
          :name => 'John Doe',
          :blog_posts => [
            {
              :title => 'This is post 1'
            }
          ]
        }
      }
    end

  end

  describe '#serializable_hash' do

    it 'should return a hash of attributes_hash and associations_hash' do
      serializer.stub(:attributes_hash).and_return({ :title => 'hi' })
      serializer.stub(:associations_hash).and_return({ :blog_posts => [] })

      serializer.serializable_hash.should == {
        :title => 'hi',
        :blog_posts => []
      }
    end

  end

  describe '#fetch_property' do

    it 'should get property if it doesnt exist on the serializer' do
      serializer = BlogPostSerializer.new(post_1)

      post_1.stub(:some_attribute).and_return('original!')
      serializer.stub(:some_attribute).and_return('override!')

      serializer.fetch_property(:some_attribute).should == 'override!'
      serializer.fetch_property(:title).should == post_1.title
    end

  end

end
