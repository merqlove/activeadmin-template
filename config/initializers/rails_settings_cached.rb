module RailsSettingsCustomBase
  module ClassMethods
    def cache_key(var_name, scope_object)
      scope = ['rails_settings_cached', cache_prefix_by_startup]
      scope << @cache_prefix.call if defined?(@cache_prefix) && @cache_prefix
      scope << "#{scope_object.class.name}-#{scope_object.id}" if scope_object
      scope << var_name.to_s
      scope.join('/')
    end

    def [](key)
      return super(key) unless rails_initialized?
      val = Rails.cache.fetch(cache_key(key, defined?(@object) ? @object : nil)) do
        super(key)
      end
      val
    end
  end
  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

RailsSettings::Base.send(:prepend, RailsSettingsCustomBase)