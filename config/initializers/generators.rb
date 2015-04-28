Rails.application.config.generators do |g|
  g.javascripts false
  g.stylesheets false
  g.template_engine :slim
  g.helper false
  g.assets false
  g.jbuilder false
  g.test_framework :test_unit
end
