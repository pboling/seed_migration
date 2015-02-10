namespace :seed do
  desc "Run new data migrations."
  task :migrate do
    on roles(:all), :only => { :primary => true } do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake 'seed:migrate'
        end
      end
    end
  end

  desc "Revert last data migration."
  task :rollback do
    on roles(:all), :only => { :primary => true } do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake 'seed:rollback'
        end
      end
    end
  end
end
