require 'test/unit'

require 'rubygems'
require 'active_record'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.logger = Logger.new('test.log')
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Thing < ActiveRecord::Base  #:nodoc:
end

class NullifierTest < Test::Unit::TestCase  #:nodoc:

  def setup
    ActiveRecord::Schema.suppress_messages do
      ActiveRecord::Schema.define(:version => 1) do
        create_table :things do |t|
          t.string  :nullable1, :null => true
          t.string  :nullable2, :null => true
          t.string  :nullable3, :null => true
          t.string  :not_nullable, :null => false
          t.integer :field1, :null => true
          t.datetime :field2, :null => true
        end
      end
    end
  end

  def teardown
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
  
  def test_nullifier
    Thing.instance_eval do
      acts_as_nullifier
    end
    
    t = Thing.create(:not_nullable => 'foo')
    assert_nil(t.nullable1)
    assert_nil(t.nullable2)
    assert_equal('foo', t.not_nullable)
    assert_nil(t.field1)
    assert_nil(t.field2)
    
    t.nullable1 = 'nullable1'
    t.nullable2 = 'nullable2'
    t.not_nullable = 'not_nullable'
    t.save
    t.reload
    assert_equal('nullable1', t.nullable1)
    assert_equal('nullable2', t.nullable2)
    assert_equal('not_nullable', t.not_nullable)
    
    t.nullable1 = ''
    t.nullable2 = ' '
    t.not_nullable = ''
    t.save
    t.reload
    assert_nil(t.nullable1)
    assert_not_nil(t.nullable2)
    assert_not_nil(t.not_nullable)
    assert_equal('', t.not_nullable)
  end

  def test_nullifier_only
    Thing.instance_eval do
      acts_as_nullifier :only => :nullable2
    end
    
    t = Thing.create(:not_nullable => 'foo')
    
    t.nullable1 = 'nullable1'
    t.nullable2 = 'nullable2'
    t.not_nullable = 'not_nullable'
    t.save
    t.reload
    assert_equal('nullable1', t.nullable1)
    assert_equal('nullable2', t.nullable2)
    assert_equal('not_nullable', t.not_nullable)
    
    t.nullable1 = ''
    t.nullable2 = ''
    t.not_nullable = ''
    t.save
    t.reload
    assert_not_nil(t.nullable1)
    assert_equal('', t.nullable1)
    assert_nil(t.nullable2)
    assert_not_nil(t.not_nullable)
    assert_equal('', t.not_nullable)
  end

  def test_nullifier_except
    Thing.instance_eval do
      acts_as_nullifier :except => :nullable2
    end
    
    t = Thing.create(:not_nullable => 'foo')
    
    t.nullable1 = 'nullable1'
    t.nullable2 = 'nullable2'
    t.not_nullable = 'not_nullable'
    t.save
    t.reload
    assert_equal('nullable1', t.nullable1)
    assert_equal('nullable2', t.nullable2)
    assert_equal('not_nullable', t.not_nullable)
    
    t.nullable1 = ''
    t.nullable2 = ''
    t.not_nullable = ''
    t.save
    t.reload
    assert_nil(t.nullable1)
    assert_not_nil(t.nullable2)
    assert_equal('', t.nullable2)
  end
  
  def test_nullifier_only_except
    Thing.instance_eval do
      acts_as_nullifier :only => [:nullable2, :nullable3], :except => :nullable2
    end
    
    t = Thing.create(:not_nullable => 'foo')
    assert_nil(t.nullable2)
    
    t.nullable1 = 'nullable1'
    t.nullable2 = 'nullable2'
    t.nullable3 = 'nullable3'
    t.not_nullable = 'not_nullable'
    t.save
    t.reload
    assert_equal('nullable1', t.nullable1)
    assert_equal('nullable2', t.nullable2)
    assert_equal('nullable3', t.nullable3)
    assert_equal('not_nullable', t.not_nullable)
    
    t.nullable1 = ''
    t.nullable2 = ''
    t.nullable3 = ''
    t.not_nullable = ''
    t.save
    t.reload
    assert_not_nil(t.nullable1)
    assert_not_nil(t.nullable2)
    assert_nil(t.nullable3)
    assert_equal('', t.nullable1)
    assert_equal('', t.nullable2)
  end
end