namespace :seed do
  desc "Run new data migrations."
  task :migrate => :environment do
    on roles(:all), :only => { :primary => true } do
      within current_path do
        rake 'seed:migrate'
      end
    end
  end

  desc "Revert last data migration."
  task :rollback => :environment do
    on roles(:all), :only => { :primary => true } do
      within current_path do
        rake 'seed:rollback'
      end
    end
  end
end
