require 'spec_helper'

describe ScopedSerializer::Scope do

  let(:scope) { ScopedSerializer::Scope.new(:default) }

  describe '.from_hash' do

    it 'should initialize a scope from hash' do
      scope = ScopedSerializer::Scope.from_hash({
        :attributes => [:title, :created_at],
        :associations => [:user, :account]
      })

      scope.attributes.should == [:title, :created_at]
      scope.associations.should == { :user => {}, :account => {}}
    end

  end

  describe '#initialize' do

    it 'should initialize with defaults' do
      scope.root :test
      scope.attributes :id, :name
      scope.association :blog_posts

      new_scope = ScopedSerializer::Scope.new(:name, scope)
      new_scope.options.should == { :root => :test }
      new_scope.attributes.should == [:id, :name]
      new_scope.associations.should == { :blog_posts => {} }
    end

    it 'should initialize with block' do
      scope = ScopedSerializer::Scope.new(:default) do
        attributes :id, :name
      end

      scope.attributes.should == [:id, :name]
    end

  end

  describe 'options' do

    it 'should set root' do
      scope.root :test
      scope.options[:root].should == :test
    end

  end

  describe '#attributes' do

    it 'should store attributes' do
      scope.attributes :id, :name
      scope.attributes.should == [:id, :name]
    end

    it 'should keep attributes uniq' do
      scope.attributes :id, :name, :name
      scope.attributes :name
      scope.attributes.should == [:id, :name]
    end

  end

  describe '#association' do

    it 'should store association by hash' do
      scope.association :blog_posts => :user, :serializer => 'test'

      scope.associations.should == {
        :blog_posts => {
          :include    => :user,
          :serializer => 'test',
          :preload    => true,
        }
      }
    end

    it 'should store association by single argument' do
      scope.association :blog_posts

      scope.associations.should == {
        :blog_posts => {}
      }
    end

    it 'should store association by single argument and separate options' do
      scope.association :blog_posts, :serializer => 'test'

      scope.associations.should == {
        :blog_posts => {
          :serializer => 'test'
        }
      }
    end

    it 'should support association types as methods' do
      scope.should respond_to :belongs_to
      scope.should respond_to :has_one
      scope.should respond_to :has_many
    end

  end

end
