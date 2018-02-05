Gaffe.configure do |config|
  config.errors_controller =  {
      %r[^/] => 'Web::ErrorsController'
  }
end

Gaffe.enable!
