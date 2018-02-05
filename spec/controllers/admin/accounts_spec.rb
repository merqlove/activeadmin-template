require 'rails_helper'

describe Admin::AccountsController do
  let(:admin) { FactoryBot.build_stubbed(:admin) }
  before do
    expect(controller).to receive(:authenticate_admin_user!) { true }
  end

  context '#index & #show' do
    before do
      expect(controller).to receive(:current_admin) { admin }.exactly(1).times
    end

    after do
      expect(response).to redirect_to action: :edit, id: admin.friendly_id
    end

    it 'should redirect to #edit' do
      get :index
    end

    it 'should redirect to #edit' do
      get :show, params: { id: admin.friendly_id }
    end
  end

  context '#clear_cache' do
    before do
      @previous_url = Rails.application.routes.url_helpers.admin_pages_path
      Rails.cache.fetch(:some_key) { { test: true } }
      request.env['HTTP_REFERER'] = @previous_url
    end

    after do
      expect(response).to redirect_to(@previous_url)
      expect(Rails.cache.fetch(:some_key)).to eq(nil)
    end

    it 'should redirect to :back' do
      get :clear_cache
    end
  end
end
