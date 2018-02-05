module ActiveAdmin
  module Inputs
    module Filters
      class Select2TagsAjaxInput < ::Formtastic::Inputs::SelectInput

        include ::ActiveAdmin::Inputs::Filters::Base

        def extra_input_html_options
          {
            class: 'autocomplete-select2',
            multiple: multiple?,
            data: {
              id: retrieve_value || [],
              placeholder: options[:placeholder],
              tags: multiple?,
              filter: true,
              'named-tag' => true,
              context: options[:context] || 'tags',
              url: template.send(options[:url])
            }
          }
        end

        # Return input name used by metasearch
        def input_name
          multiple? ? "#{method}_name_in" : super()
        end

        def retrieve_value
          template.params[:q].try(:[], input_name)
        end

        # Do not return any item when building select, values are loaded by ajax
        def collection
          value = retrieve_value
          return [] unless value.present?
          klass = reflection_for(method).klass
          klass.where(name: value).map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] }
        end
      end
    end
  end
end
