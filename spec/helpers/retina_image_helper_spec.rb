require 'rails_helper'

RSpec.describe RetinaImageHelper, type: :helper do
  include RetinaImageHelper

  it 'retina_image_tag' do
    tag = retina_image_tag('example.png', alt: 'example')

    expect(tag).to match(%r{\A<img srcset=".*" alt=".*" src=".*" />\z})
    expect(tag).to match(/alt="example"/)
    expect(tag).to match(%r{src="/images/example.png"})
    expect(tag).to match(%r{srcset="/images/example.png 1x,/images/example@2x.png 2x"})
  end
end
