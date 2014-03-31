module DataMigration
    class Migration
        def up
            raise NotImplementedError
        end

        def down
            raise NotImplementedError
        end
    end
end
