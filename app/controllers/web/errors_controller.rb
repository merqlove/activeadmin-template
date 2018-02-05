module Web
  class ErrorsController < ::Web::ApplicationController
    include Gaffe::Errors

    def show
      render "web/errors/#{@rescue_response}", status: @status_code
    end
  end
end
