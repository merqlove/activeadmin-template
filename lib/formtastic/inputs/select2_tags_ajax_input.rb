module Formtastic
  module Inputs

    class Select2TagsAjaxInput < ::Formtastic::Inputs::SelectInput
      def extra_input_html_options
        {
          class: 'autocomplete-select2',
          :multiple => true,
          data: {
            placeholder: options[:placeholder],
            tags: true,
            'named-tag' => true,
            context: options[:context] || 'tags',
            can_create_tag: true,
            url: options[:url]
          }
        }
      end
    end

  end
end
