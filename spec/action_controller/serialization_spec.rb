require 'spec_helper'
require 'fixtures/application'
require 'fixtures/controllers'
require 'rspec/rails'

class BlogPostsController < TestController
end

describe ActionController::Serialization, type: :controller do

  include_context :dummy_serializers

  controller(BlogPostsController) do
    def index
      render :json => BlogPost.where({})
    end
    def show
      render :json => BlogPost.first
    end
  end

  it 'should render collection scope' do
    ScopedSerializer.should_receive(:for).with(BlogPost.where({}), :collection, anything)
    get :index
    controller.serializer_scope.should == :collection
  end

  it 'should render resource scope' do
    ScopedSerializer.should_receive(:for).with(BlogPost.first, :resource, anything)
    get :show, :id => 1
    controller.serializer_scope.should == :resource
  end

end
