require 'spec_helper'
require 'dummy/application'
require 'dummy/controllers'
require 'rspec/rails'

class BlogPostsController < TestController
end

describe ActionController::Serialization, type: :controller do

  include_context :dummy_serializers

  controller(BlogPostsController) do
    def index
      render :json => BlogPost.all
    end
    def show
      render :json => BlogPost.first
    end
  end

  let(:json) { JSON.parse(response.body) }

  it 'should render collection scope' do
    get :index

    controller.serializer_scope.should == :collection
    json['blog_posts'].should == [
      {
        'title' => 'This is post 1',
        'rating' => 4.0
      },
      {
        'title' => 'This is post 2',
        'rating' => 9.0
      }
    ]
  end

  it 'should render resource scope' do
    get :show, :id => 1

    controller.serializer_scope.should == :resource
    json['blog_post']['user'].should be_present
  end

end
