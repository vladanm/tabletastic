module Tabletastic
  module Helper
    # returns and outputs a table for the given active record collection
    def table_for(collection, *args, &block)
      block = Tabletastic.default_table_block unless block_given?
      klass = default_class_for(collection)
      options = args.extract_options!
      initialize_html_options(options, klass)
      result = capture do
        block.call(@table = TableBuilder.new(collection, klass, self, params))
      end
      
      mass_action = @table.mass_actions
      mass_action_prefix = @table.mass_actions_prefix
      
      if (mass_action)
        @selection = [[" ", -1]] #default no action
        mass_action.each do |maction|
          @selection << [maction.to_s,maction]
        end
        form_tag("#{mass_action_prefix}/mass_actions", id: "form_#{options[:html][:id]}", name: "form_#{options[:html][:id]}", method: :post) do
          
          content = content_tag(:div, align: "right") do
            select_tag :mass_actions, options_for_select(@selection), onChange: "form_#{options[:html][:id]}.submit();"
          end
          content += content_tag(:table, result, options[:html])
        end
      else
        content = content_tag(:table, result, options[:html])
      end
    end

    private
    # Finds the class representing the objects within the collection
    def default_class_for(collection)
      if collection.respond_to?(:klass) # ActiveRecord::Relation
        collection.klass
      elsif !collection.empty?
        collection.first.class
      end
    end

    def initialize_html_options(options, klass)
      options[:html] ||= {}
      options[:html][:id] ||= get_id_for(klass)
      options[:html].reverse_merge!(Tabletastic.default_table_html)
    end

    def get_id_for(klass)
      klass ? klass.model_name.collection : ""
    end
  end
end

ActiveSupport.on_load(:action_view) do
  include Tabletastic::Helper
end
