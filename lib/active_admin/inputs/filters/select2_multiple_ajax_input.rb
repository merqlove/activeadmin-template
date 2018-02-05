module ActiveAdmin
  module Inputs
    module Filters
      class Select2MultipleAjaxInput < ::Formtastic::Inputs::SelectInput

        include ::ActiveAdmin::Inputs::Filters::Base

        def extra_input_html_options
          {
            class: 'autocomplete-select2',
            multiple: multiple?,
            data: {
              # id: options[:collection].to_json,
              placeholder: options[:placeholder],
              filter: true,
              tags: multiple?,
              url: template.send(options[:url])
            }
          }
        end

        # Return input name used by metasearch
        def input_name
          multiple? ? "#{method}_id_in" : "#{method}_id_eq"
        end

        # Do not return any item when building select, values are loaded by ajax
        def collection
          value = template.params[:q].try(:[], input_name)
          return [] unless value.present?
          klass = reflection_for(method).klass
          klass.where(id: value).map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] }
        end
      end
    end
  end
end
