shared_context :dummy_serializers do

  class BlogPostSerializer < ScopedSerializer::Serializer
    attributes :title
    scope :resource do
      belongs_to :user
      has_many :comments => { :user => :blog_posts }
    end
    scope :another_scope do
      attributes :something
      has_many :comments
    end
  end

  class CommentSerializer < ScopedSerializer::Serializer
    attributes :text
    scope :resource do
      belongs_to :blog_post
      belongs_to :user
    end
  end

  class UserSerializer < ScopedSerializer::Serializer
    attributes :name
    scope :resource do
      has_many :blog_posts => :comments
    end
  end

  with_model :BlogPost do
    table do |t|
      t.string :title
      t.belongs_to :user
      t.timestamps
    end

    model do
      has_many :comments
      belongs_to :user
    end
  end

  with_model :Comment do
    table do |t|
      t.string :text
      t.belongs_to :blog_post
      t.belongs_to :user
      t.timestamps
    end

    model do
      belongs_to :blog_post
      belongs_to :user
    end
  end

  with_model :User do
    table do |t|
      t.string :name
      t.timestamps
    end

    model do
      has_many :comments
      has_many :blog_posts
    end
  end

  let!(:user_1) { User.create(:name => 'John Doe') }
  let!(:user_2) { User.create(:name => 'Jane Doe') }

  let!(:post_1) { BlogPost.create(:title => 'This is post 1', :user => user_1) }
  let!(:post_2) { BlogPost.create(:title => 'This is post 2', :user => user_2) }

  let!(:comment_1) { Comment.create(:text => 'This is comment 1', :user => user_2, :blog_post => post_1) }
  let!(:comment_2) { Comment.create(:text => 'This is comment 2', :user => user_1, :blog_post => post_2) }

end
