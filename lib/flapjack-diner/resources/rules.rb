require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rules

        def create_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            # TODO proper validation of time_restrictions field
            # FIXME accept conditions_list as an array of strings and create the array that Flapjack accepts here
            validate :query => :conditions_list, :as => :string
            validate :query => :is_blackhole, :as => :boolean
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_post(:rules, '/rules', data)
        end

        def rules(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/rules', ids, data) # {
            # FIXME convert conditions_list string to an array
          # }
        end

        def update_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            # TODO proper validation of time_restrictions field
            # FIXME accept conditions_list as an array of strings and create the array that Flapjack accepts here
            validate :query => :conditions_list, :as => :string
            validate :query => :is_blackhole, :as => :boolean
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:rules, "/rules", data)
        end

        def delete_rules(*ids)
          raise "'delete_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          perform_delete(:rules, '/rules', *ids)
        end
      end
    end
  end
end
