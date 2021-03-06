require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe 'One to One Associations' do
  before :all do
    module ::Blog
      class Article
        include DataMapper::Resource

        property :title, String, :key => true
        property :body,  Text,   :required => true
      end

      class Author
        include DataMapper::Resource

        property :name, String, :key => true

        belongs_to :without_default,       'Article', :child_key => [ :without_default_id       ], :required => false
        belongs_to :with_default,          'Article', :child_key => [ :with_default_id          ], :required => false
        belongs_to :with_default_callable, 'Article', :child_key => [ :with_default_callable_id ], :required => false
      end
    end

    @article_model = Blog::Article
    @author_model  = Blog::Author

    @default_value          = @author_model.new(:name => 'Dan Kubb')
    @default_value_callable = @author_model.new(:name => 'John Doe')

    @subject_without_default       = @article_model.has(1, :without_default,       @author_model, :child_key => [ :without_default_id       ])
    @subject_with_default          = @article_model.has(1, :with_default,          @author_model, :child_key => [ :with_default_id          ], :default => @default_value)
    @subject_with_default_callable = @article_model.has(1, :with_default_callable, @author_model, :child_key => [ :with_default_callable_id ], :default => lambda { |resource, relationship| @default_value_callable })
  end

  supported_by :all do
    before :all do
      @default_value.save
      @default_value_callable.save
    end

    describe 'acts like a subject' do
      before do
        @resource = @article_model.new(:title => 'DataMapper Rocks!', :body => 'TSIA')
      end

      it_should_behave_like 'A semipublic Subject'
    end
  end
end
