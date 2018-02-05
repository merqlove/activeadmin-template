module Formtastic
  module Inputs

    class Select2AjaxInput < ::Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          class: 'autocomplete-select2',
          data: {
            id: options[:value],
            placeholder: options[:placeholder],
            url: options[:url]
          }
        }
      end
    end

  end
end