require 'rails_helper'

RSpec.describe 'LayoutHelperTest', type: :system do
  before do
    driven_by(:rack_test)
  end

  it 'rendered page contains both base and application layouts' do
    visit('/')
    have_selector('html>head+body')
    have_selector('body p')

    expect(page.title).to match(/Welcome/)
  end
end
