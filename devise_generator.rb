class DeviseGenerator < Rails::Generators::Base
    def run_install
        add_devise_gem
        generate_devise_install
        configure_devise
        set_up_models
    end

    def add_devise_gem
        gem "devise"
        run "bundle install"
    end

    def generate_devise_install
        generate "devise:install"
        generate "devise:views"
    end

    def configure_devise
        # Set up Default Mailer Options
        insert_into_file "config/environments/development.rb", "  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }\n", :after => "Rails.application.configure do\n"

        create_devise_files
        insert_into_devise_files
    end

    def create_devise_files
        # Create Alerts File
        create_file "app/views/layouts/_alerts.html.erb"

        # Create Header File
        create_file "app/views/layouts/_header.html.erb"
    end

    def insert_into_devise_files
        # Insert Content into Alerts File
        insert_into_file(
            "app/views/layouts/_alerts.html.erb",
            "<% if notice %>
                <p class=\"notice\"><%= notice %></p>
            <% end %>
            <% if alert %>
              <p class=\"alert\"><%= alert %></p>
            <% end %>",
            after: "")

        # Insert Content into Header File
        insert_into_file(
            "app/views/layouts/_header.html.erb",
            "<% if user_signed_in? %>
              <%= link_to 'Edit profile', edit_user_registration_path %> |
              <%= link_to 'Logout', destroy_user_session_path, method: :delete  %>
            <% else %>
              <%= link_to 'Sign up', new_user_registration_path  %> |
              <%= link_to 'Login', new_user_session_path  %>
            <% end %>",
            after: "")

        #Insert
        insert_into_file(
            "app/views/layouts/application.html.erb",
            "<%= render \"layouts/header\" %>
            <%= render \"layouts/alerts\" %>",
            after: "<body>\n")
    end

    def set_up_models
        model_name = ask("What would you like the user model to be called? [user]")
        model_name = "user" if model_name.blank?
        generate "devise", model_name
        run "rake db:migrate"
    end
end