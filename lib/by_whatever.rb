module ByWhatever
  def self.included(base)
    base.send :extend, ClassMethods
  end
 
  module ClassMethods
    def by_whatever(*args)
      options = args.extract_options!
      columns = args.blank? ? self.column_names : args.to_a.map(&:to_s).uniq
      columns -= options[:except].to_a.map(&:to_s)
 
      %w(minute hour day week month).each do |range|
        self.class_eval do
          named_scope "during_last_#{range}", lambda{{:conditions => ['created_at >= ?', Time.now.utc-1.send(range)]}}
        end
      end
  
      columns.each do |column|
        self.class_eval do
          named_scope "by_#{column}", lambda {|value| {:conditions => ["#{column} = ?", value]}}
          named_scope "by_#{column.pluralize}", lambda {|value| value.blank? || !value.is_a?(Array) ? [] : {:conditions => ["#{column} in (?)", value]} }
       end
      end 
    end
  end
end
 
ActiveRecord::Base.send :include, ByWhatever
