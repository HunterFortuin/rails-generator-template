# Create correct version of README
remove_file "README.rdoc"
create_file "README.md", "TODO"

# Write Gems to Gemfile
gem "figaro"
gem "rspec-rails", group: :test
gem "factory_girl_rails", group: :test
gem 'ffaker', group: :test
gem "shoulda-matchers", "< 3.0.0", require: false, group: :test
gem "pry", group: :development
gem "letter_opener", group: :development
gem "better_errors", group: :development
gem "binding_of_caller", group: :development
gem 'rails_12factor', group: :production

# Remove Turbolinks
gsub_file("Gemfile", "gem 'turbolinks'", "# gem 'turbolinks' GET OUTTA HERE TURBOLINKS, NOBODY LIKES YOU")
gsub_file("app/views/layouts/application.html.erb", ", 'data-turbolinks-track' => true", "")
gsub_file("app/assets/javascripts/application.js", "//= require turbolinks\n", '')

# Install the Bunlde
run "bundle install"

# Run Gem Scripts
run "bundle exec figaro install"
generate "rspec:install"

# Set Up Generator Rules
generator_rules = ["g.test_framework :rspec, ficture: true", "g.fixture_replacement :factory_girl, dir: 'spec/factories'", "g.view_specs false", "g.helper_specs false", "g.stylesheets false", "g.javascripts false", "g.helper false"]
insert_into_file "config/application.rb", :after => "class Application < Rails::Application\n" do
    "    config.generators do |g|\n#{generator_rules.map{|rule| "      #{rule}" }.join("\n")}\n    end\n"
end

# Static Pages Controller
if yes? "Is there a main products page? (yes/no)"
  @products = true
  generate :controller, "static_pages home about products contact"
else
  @products = false
  generate :controller, "static_pages home about contact"
end

# Route Generation
route "root 'static_pages\#home'"
route "get 'home' => 'static_pages\#home'"
route "get 'about' => 'static_pages\#about'"
route "get 'contact' => 'static_pages\#contact'"
route "get 'products' => 'static_pages\#products'" if @products

# Remove Default Generated Routes
gsub_file("config/routes.rb", "get 'static_pages/home'\n", '')
gsub_file("config/routes.rb", "get 'static_pages/about'\n", '')
gsub_file("config/routes.rb", "get 'static_pages/contact'\n", '')
gsub_file("config/routes.rb", "get 'static_pages/products'\n", '') if @products
gsub_file("config/routes.rb", /^\s*#.*\n/, '') # removes all commments from routes

# Set up environment files
insert_into_file "config/environments/development.rb", "config.action_mailer.delivery_method = :letter_opener", :after => "Rails.application.configure do\n"
name = ask("What's the URL of this site?")
insert_into_file "config/environments/production.rb", "config.action_mailer.default_url_options = { host: '#{name}' }", after: "Rails.application.configure do\n"

# Set up stylesheet folder
inside('app/assets') do
    run "svn checkout https://github.com/HunterFortuin/rails-generator-template/trunk/stylesheets"
    remove_file "stylesheets/application.css"
end

# Initalize Git
git :init

# Add database.yml to gitignore
append_file ".gitignore", "config/database.yml"
append_file ".gitignore", "TODO"

# Create an example_database.yml file
run "cp config/database.yml config/example_database.yml"

# Add all files to git
git add: "--all"
git commit: "-m 'initialized project'"