require 'acts_as_sanitized'
ActiveRecord::Base.send(:include, NinaJansen::Acts::Sanitized)
