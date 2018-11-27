module Formtastic
  module Inputs

    class Select2MultipleAjaxInput < ::Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          class: 'autocomplete-select2',
          multiple: true,
          data: {
            placeholder: options[:placeholder],
            tags: true,
            url: options[:url]
          }
        }
      end
    end
  end
end
