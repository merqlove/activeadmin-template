require 'rails_helper'

RSpec.describe JavascriptHelper, type: :helper do
  include JavascriptHelper
  include Sprockets::Rails::Helper

  before do
    allow_unknown_assets
  end

  it "#javascript_include_async_tag doesn't do anything in debug mode" do
    allow(self).to receive(:request_debug_assets?).and_return(true)

    js_tag = javascript_include_tag('foo', skip_pipeline: true)
    js_async_tag = javascript_include_async_tag('foo', skip_pipeline: true)
    expect(js_async_tag).to eq(js_tag)
  end

  it 'javascript_include_async_tag adds async attribute' do
    expect(
      javascript_include_async_tag('foo', skip_pipeline: true)
    ).to eq('<script src="/javascripts/foo.js" async="async"></script>')
  end

  # This allows non-existent asset filenames to be used within a test, for
  # sprockets-rails >= 3.2.0.
  def allow_unknown_assets
    return unless respond_to?(:unknown_asset_fallback)
    allow(self).to receive(:unknown_asset_fallback).and_return(true)
  end
end
