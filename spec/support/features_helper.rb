require 'capybara/poltergeist/browser'
module FeaturesHelper
  def sign_in_as(user, path = nil)
    login_as user, scope: :user
    visit path unless path.blank?
  end

  def fill_in_wysihtml(*args)
    if driver_poltergeist?
      wysihtml_poltergeist(*args)
    else
      wysihtml_all(*args)
    end
  end

  def wysihtml_poltergeist(klass, text)
    fill_in klass, with: text
  end

  def wysihtml_all(klass, text)
    within(".#{klass}") do
      iframe = all("iframe").last
      within_frame(iframe) do
        find('body').set(text)
      end
    end
  end

  def driver_poltergeist?
    Capybara.javascript_driver == :poltergeist
  end

  def driver_accessible?
    ENV['WEBDRIVER'] == 'accessible'
  end
end

RSpec.configure do |config|
  config.include FeaturesHelper, type: :feature
end
