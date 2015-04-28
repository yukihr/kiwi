require 'active_record/fixtures'

module Kiwi
  module SeedLoader
    class InvalidNameError < StandardError; end

    class << self
      def load_seed
        ['all', Rails.env].each do |seed|
          seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
          next unless File.exist?(seed_file)
          puts "*** Loading #{seed} seed data ***"
          module_eval(File.open(seed_file).read)
        end
        puts '*** Processing... ***'
        import_fixtures
      end

      def use_fixture(name, test_data: false)
        puts "Use fixture: #{test_data ? 'test_data/' : ''}#{name}."
        @fixtures ||= {}
        @fixtures[name] ||= []
        @fixtures[name] << (test_data ? 'test_data' : '')
      end

      def import_fixtures
        @fixtures.each do |name, paths|
          directories = paths.map do |path|
            Rails.root.join('db', 'fixtures', path)
          end
          import_fixture(name, directories)
        end
      end

      def concat_fixtures(name, directories)
        files = directories.map { |dir| "#{dir}/#{name}.yml" }
        contents = files.map { |file| File.read(file) }
        contents.join("\n")
      end

      def import_fixture(name, directories)
        puts "Importing fixture: #{name}.."
        data = concat_fixtures(name, directories)
        tmp_dir = Rails.root.join('tmp', 'fixtures')
        tmp_file = tmp_dir.join("#{name}.yml")
        FileUtils.mkdir_p(tmp_dir)
        File.write(tmp_file, data)
        ActiveRecord::FixtureSet.create_fixtures(tmp_dir, name)
      end
    end
  end
end
