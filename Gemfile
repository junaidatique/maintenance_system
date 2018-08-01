source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.3.3'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.1'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'faker', :git => 'git://github.com/stympy/faker.git', :branch => 'master'
  gem 'business_time'
  gem 'ruby-debug-ide', '0.6.0'
  gem 'debase', '0.2.1'
  gem 'rcodetools'
  gem 'rubocop'
  gem 'rufo'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'jquery-rails'
gem "mongoid", "~> 6.1"
gem 'devise'
gem 'simple_enum', '~> 2.3.0' , require: 'simple_enum/mongoid'
gem 'slim-rails'
gem 'growlyflash'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jquery-ui-rails'
gem 'select2-rails'
gem 'html2slim', '~> 0.2.0'
gem 'jquery-datatables-rails'
gem 'ajax-datatables-rails'
gem 'wysiwyg-rails'
gem 'cocoon'
gem 'cancancan'
gem 'momentjs-rails'
gem 'bootstrap3-datetimepicker-rails'
gem 'simple_form'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem "mongoid-paperclip"
gem 'mongoid-autoinc'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'state_machines-audit_trail'
gem 'state_machines-mongoid'
gem 'rails-jquery-autocomplete'
gem 'combine_pdf'
gem 'roo'
# gem 'rubyzip' , '= 1.0.0'
# gem 'axlsx', '= 2.0.1'
# gem 'axlsx_rails'

gem 'rubyzip'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'