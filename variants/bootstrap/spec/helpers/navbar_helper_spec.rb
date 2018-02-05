# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NavbarHelper, type: :helper do
  include NavbarHelper

  before do
    allow(self).to receive(:params).and_return(controller: 'users')
  end

  it '#navbar_link_to adds active class according to :active_when' do
    tag = navbar_link_to(
      'Test',
      'http://example.com',
      title: 'foo',
      active_when: { controller: 'users' }
    )

    expect(tag).to eq('<li class="active">'\
      '<a title="foo" href="http://example.com">Test</a>'\
      '</li>')
  end

  it '#navbar_link_to honors regular expressions' do
    tag = navbar_link_to(
      'Test',
      'http://example.com',
      active_when: { controller: /^user.*/ }
    )

    expect(tag).to eq('<li class="active"><a href="http://example.com">Test</a></li>')
  end

  test "#navbar_link_to otherwise doesn't add active class" do
    tag = navbar_link_to('Welcome', '/', active_when: { controller: 'web/welcome' })
    expect(tag).to eq('<li><a href="/">Welcome</a></li>')
  end
end
