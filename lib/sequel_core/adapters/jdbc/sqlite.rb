require 'sequel_core/adapters/shared/sqlite'

module Sequel
  module JDBC
    module SQLite
      module DatabaseMethods
        include Sequel::SQLite::DatabaseMethods
        
        def dataset(opts=nil)
          Sequel::JDBC::SQLite::Dataset.new(self, opts)
        end
        
        def execute_insert(sql)
          begin
            log_info(sql)
            @pool.hold do |conn|
              stmt = conn.createStatement
              begin
                stmt.executeUpdate(sql)
                rs = stmt.executeQuery('SELECT last_insert_rowid()')
                rs.next
                rs.getInt(1)
              rescue NativeException, JavaSQL::SQLException => e
                raise Error, e.message
              ensure
                stmt.close
              end
            end
          rescue NativeException, JavaSQL::SQLException => e
            raise Error, "#{sql}\r\n#{e.message}"
          end
        end
        
        private
        
        def connection_pool_default_options
          o = super
          uri == 'jdbc:sqlite::memory:' ? o.merge(:max_connections=>1) : o
        end
      end
    
      class Dataset < JDBC::Dataset
        include Sequel::SQLite::DatasetMethods
      end
    end
  end
end
