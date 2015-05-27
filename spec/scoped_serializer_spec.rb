require 'spec_helper'

class AnonymousSerializer < ScopedSerializer::Serializer
end

describe ScopedSerializer do

  include_context :dummy_serializers

  describe 'defining' do

    it 'should support inheritance' do
      class BlogPostInheritedSerializer < BlogPostSerializer
        attributes :date
        scope :resource do
          attributes :another_property
        end
      end

      # Inherit default scope
      BlogPostInheritedSerializer.find_scope(:default).attributes.should == [:title, :date]

      # Overwritten scope
      BlogPostInheritedSerializer.find_scope(:resource).attributes.should == [:title, :date, :another_property]
      BlogPostInheritedSerializer.find_scope(:resource).associations.should == {}

      # Inherit other scopes
      BlogPostInheritedSerializer.find_scope(:another_scope).attributes.should == [:title, :something, :date]
      BlogPostInheritedSerializer.find_scope(:another_scope).associations.should == { :comments => {} }
    end

  end

  describe 'scopes' do

    after(:each) do
      ScopedSerializer::Serializer.inherited(AnonymousSerializer)
    end

    describe 'default scope' do

      it 'should always have a default scope' do
        scope = AnonymousSerializer.default_scope
        scope.should be_present
        scope.name.should == :default
      end

      it 'should store settings on default scope' do
        AnonymousSerializer.attributes :status
        scope = AnonymousSerializer.default_scope
        scope.attributes.should == [:status]
      end

    end

    describe 'defining scopes' do

      it 'should define a scope with attributes and associations' do
        AnonymousSerializer.scope :some_name do
          attributes :id, :name
          association :customer
        end

        scope = AnonymousSerializer.find_scope(:some_name)
        scope.should be_present
        scope.name.should == :some_name
        scope.attributes.should == [:id, :name]
        scope.associations.should == { :customer => {} }
      end

    end

  end

  describe 'rendering' do

    describe 'collections' do

      it 'should render collection' do
        json = ScopedSerializer.render(BlogPost.order('id ASC'))

        data = json[:blog_posts]
        data.count.should == 2

        data[0].should == {
          :title => 'This is post 1'
        }

        data[1].should == {
          :title => 'This is post 2'
        }
      end

      it 'should render collection with associations' do
        json = ScopedSerializer.render(BlogPost.order('id ASC'), :associations => [{ :comments => :user }])

        data = json[:blog_posts]
        data.count.should == 2

        data[0].should == {
          :title => 'This is post 1',
          :comments => [
            {
              :text => 'This is comment 1',
              :user => {
                :name => 'Jane Doe'
              }
            }
          ]
        }

        data[1].should == {
          :title => 'This is post 2',
          :comments => [
            {
              :text => 'This is comment 2',
              :user => {
                :name => 'John Doe'
              }
            }
          ]
        }
      end

      it 'should render collection with scope' do
        json = ScopedSerializer.render(BlogPost.order('id ASC'), :scope => :resource)

        data = json[:blog_posts]
        data.count.should == 2

        data[0].should == {
          :title => 'This is post 1',
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

        data[1].should == {
          :title => 'This is post 2',
          :user => {
            :name => 'Jane Doe'
          },
          :comments => [
            {
              :text => 'This is comment 2',
              :user => {
                :name => 'John Doe',
                :blog_posts => [
                  {
                    :title => 'This is post 1'
                  }
                ]
              }
            }
          ]
        }
      end

    end

  end

  describe '.for' do

    it 'should return instantized serializer' do
      serializer = ScopedSerializer.for(post_1)
      serializer.class.should == BlogPostSerializer
      serializer.scope.should == BlogPostSerializer.find_scope(:default)
      serializer.resource.should == post_1
    end

    it 'should fallback to DefaultSerializer' do
      ScopedSerializer.stub(:find_serializer).and_return(nil)
      serializer = ScopedSerializer.for(post_1)
      serializer.class.should == ScopedSerializer::DefaultSerializer
    end

  end

  describe '.find_serializer_by_class' do

    it 'should lookup serializer defined in class.serializer_class' do
      serializer = ScopedSerializer.find_serializer_by_class(TestCustom)
      serializer.should == CustomSerializer
    end

    it 'should default to {class_name}Serializer' do
      serializer = ScopedSerializer.find_serializer_by_class(BlogPost)
      serializer.should == BlogPostSerializer
    end

  end

end
