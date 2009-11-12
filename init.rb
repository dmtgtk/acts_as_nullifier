require 'active_record/acts/nullifier'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Nullifier)
