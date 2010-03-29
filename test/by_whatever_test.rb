require File.dirname(__FILE__) + '/test_helper.rb'

class ByWhateverTest < Test::Unit::TestCase
  load_schema

  class User < ActiveRecord::Base
    by_whatever
  end
  
  class Category < ActiveRecord::Base
  end

  class Post < ActiveRecord::Base
    by_whatever :user_id
  end
  
  class Comment < ActiveRecord::Base
    by_whatever :except => [:comment_id]
  end
  
  context "With applied by_whatever" do  
    context "User model" do  
      should "have :by_account_id scope" do
        assert User.scopes.has_key?(:by_account_id)
      end
      context "with some data in the db" do
        setup do
          1..4.times do |index|
            User.create(:account_id => 1, :name => "User_#{index}_from_account_1")
          end
          1..5.times do |index|
            User.create(:account_id => 2, :name => "User_#{index}_from_account_2")
          end
        end
        should "return correct numbers due to scopes" do
          assert User.by_account_id(1).count == 4
          assert User.by_account_id(2).count == 5
          assert User.by_account_ids([2,1]).count == 9
        end
      end
    end
    
    context "Post model" do  
      should "have :by_user_id scope" do
        assert Post.scopes.has_key?(:by_user_id)
      end
      should "not have :by_category_id scope" do
        assert !Post.scopes.has_key?(:category_id)
      end
    end
    
    context "Comment model" do  
      [:user_id, :created_at, :post_id].each do |column|
        scope_name = :"by_#{column}"
        should("have #{scope_name} scope") {assert Comment.scopes.has_key?(scope_name)}
      end
      should("not have :by_comment_id scope") {assert !Comment.scopes.has_key?(:by_comment_id)}
    end

    [Comment, User, Post].each do |model_class|
      context "#{model_class.to_s} model" do
        [:minute, :hour, :day, :week, :month].each do |range|
          scope_name = :"during_last_#{range}"
          should "has scope :#{scope_name.to_s}" do
            assert model_class.scopes.has_key?(scope_name)
          end
        end
      end
    end
  end
end
