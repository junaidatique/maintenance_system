namespace :db do
  namespace :seed do
    task :flying_log => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "flying_log.seeds.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :scheduled_inspections => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "scheduled_inspections.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :aircraft_fix => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "aircraft_fix.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :tyrelanding_fix => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "tyrelanding_fix.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :create_tyre_parts => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "tyre_parts.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :create_work_package => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "work_package.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
    task :import_xlxs => :environment do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "import_xlxs.seed.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
  end
end