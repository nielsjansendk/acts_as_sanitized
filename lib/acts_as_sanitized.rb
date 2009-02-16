module NinaJansen
  class TextHelperWrapper
    include ActionView::Helpers
    include Singleton
  end
  module Acts #:nodoc: all
    module Sanitized
      def self.included(base)
        base.extend(ClassMethods)
        
      end
       
      module ClassMethods
        
        def acts_as_sanitized(options = {})
          include NinaJansen::Acts::Sanitized::InstanceMethods
          alias_method :write_attribute_without_sanitize, :write_attribute
          alias_method :write_attribute, :write_attribute_with_sanitize

          options[:clean_fields] = options[:clean_fields].collect{ |field| field.to_sym } if options[:clean_fields]
          options[:strip_fields] = options[:strip_fields].collect{ |field| field.to_sym } if options[:strip_fields]
          write_inheritable_attribute(:acts_as_sanitized_options, {
            :clean_fields => options[:clean_fields],
            :strip_fields => options[:strip_fields],
          })

          class_inheritable_reader :acts_as_sanitized_options

          if (!acts_as_sanitized_options[:clean_fields])
            acts_as_sanitized_options[:clean_fields] = []
          end
          
          if (!acts_as_sanitized_options[:strip_fields])
            acts_as_sanitized_options[:strip_fields] = []
          end
        end
      end

      module InstanceMethods
        if Object.const_defined?(:WhiteListHelper)
          include WhiteListHelper
          def sanitize_field(content)
            white_list(content) { |node, bad| white_listed_bad_tags.include?(bad) ? nil : node.to_s.gsub(/</, '&lt;') } 
          end
        else
          def sanitize_field(content)
            TextHelperWrapper.instance.sanitize(content)      
          end
        end
        
        def write_attribute_with_sanitize(attr_name, value)

          if !value.nil? && acts_as_sanitized_options[:clean_fields].include?(attr_name.to_sym)
            value = sanitize_field(value) 
          end

          if !value.nil? && acts_as_sanitized_options[:strip_fields].include?(attr_name.to_sym)
            value = strip_tags_field(value) 
          end 
          write_attribute_without_sanitize(attr_name, value)          
        end
        
        def strip_tags_field(content)
          TextHelperWrapper.instance.strip_tags(content) unless content.nil?
        end
      end
    end
  end
end
