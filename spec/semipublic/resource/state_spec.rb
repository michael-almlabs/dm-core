require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Resource::State do
  before :all do
    class ::Author
      include DataMapper::Resource

      property :id,      Serial
      property :name,    String
      property :private, Boolean, :accessor => :private

      belongs_to :parent, self, :required => false
    end

    @model = Author
  end

  before do
    @resource = @model.new(:name => 'Dan Kubb')

    @state = DataMapper::Resource::State.new(@resource)
  end

  describe '.new' do
    subject { DataMapper::Resource::State.new(@resource) }

    it { should be_kind_of(DataMapper::Resource::State) }
  end

  describe '#==' do
    subject { @state == @other }

    describe 'with the same class and resource' do
      before do
        @other = DataMapper::Resource::State.new(@resource)
      end

      it { should be_true }

      it 'should be symmetric' do
        should == (@other == @state)
      end
    end

    describe 'with the same class and different resource' do
      before do
        @other = DataMapper::Resource::State.new(@model.new)
      end

      it { should be_false }

      it 'should be symmetric' do
        should == (@other == @state)
      end
    end

    describe 'with a different class and the same resource' do
      before do
        @other = DataMapper::Resource::State::Clean.new(@resource)
      end

      it 'should be true for a subclass' do
        should be_true
      end

      it 'should be symmetric' do
        should == (@other == @state)
      end
    end

    describe 'with a different class and different resource' do
      before do
        @other = DataMapper::Resource::State::Clean.new(@model.new)
      end

      it { should be_false }

      it 'should be symmetric' do
        should == (@other == @state)
      end
    end
  end

  [ :commit, :delete, :rollback ].each do |method|
    describe "##{method}" do
      subject { @state.send(method) }

      it 'should raise an exception' do
        method(:subject).should raise_error(NotImplementedError, "DataMapper::Resource::State##{method} should be implemented")
      end
    end
  end

  describe '#eql?' do
    subject { @state.eql?(@other) }

    describe 'with the same class and resource' do
      before do
        @other = DataMapper::Resource::State.new(@resource)
      end

      it { should be_true }

      it 'should be symmetric' do
        should == @other.eql?(@state)
      end
    end

    describe 'with the same class and different resource' do
      before do
        @other = DataMapper::Resource::State.new(@model.new)
      end

      it { should be_false }

      it 'should be symmetric' do
        should == @other.eql?(@state)
      end
    end

    describe 'with a different class and the same resource' do
      before do
        @other = DataMapper::Resource::State::Clean.new(@resource)
      end

      it { should be_false }

      it 'should be symmetric' do
        should == @other.eql?(@state)
      end
    end

    describe 'with a different class and different resource' do
      before do
        @other = DataMapper::Resource::State::Clean.new(@model.new)
      end

      it { should be_false }

      it 'should be symmetric' do
        should == @other.eql?(@state)
      end
    end
  end

  describe '#get' do
    subject { @state.get(@key) }

    describe 'with a Property subject' do
      before do
        @key = @model.properties[:name]
      end

      it 'should return the value' do
        should == 'Dan Kubb'
      end
    end

    describe 'with a Relationship subject' do
      before do
        # set the association
        @resource.parent = @resource

        @key = @model.relationships[:parent]
      end

      it 'should return the association' do
        should == @resource
      end
    end
  end

  describe '#hash' do
    subject { @state.hash }

    it 'should be the object_id hash of the resource' do
      should == @resource.object_id.hash
    end
  end

  describe '#set' do
    subject { @state.set(@key, @value) }

    describe 'with a Property subject' do
      before do
        @key   = @model.properties[:name]
        @value = 'John Doe'
      end

      it 'should return a state object' do
        should be_kind_of(DataMapper::Resource::State)
      end

      it 'should change the object attributes' do
        method(:subject).should change(@resource, :attributes).from(:name => 'Dan Kubb').to(:name => 'John Doe')
      end
    end

    describe 'with a Relationship subject' do
      before do
        @key   = @model.relationships[:parent]
        @value = @resource
      end

      it 'should return a state object' do
        should be_kind_of(DataMapper::Resource::State)
      end

      it 'should change the object relationship' do
        method(:subject).should change(@resource, :parent).from(nil).to(@resource)
      end
    end
  end
end
