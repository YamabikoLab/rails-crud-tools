module Rails
  module Crud
    def self.setup_notifications
      if $crud_config && $crud_config.enabled
        ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, started, finished, unique_id, data|
          if data[:sql] =~ /(INSERT|UPDATE|DELETE|SELECT)/
            operation = case $1
                        when 'INSERT' then 'C'
                        when 'UPDATE' then 'U'
                        when 'DELETE' then 'D'
                        when 'SELECT' then 'R'
                        else 'Unknown'
                        end

            table_name = data[:sql].match(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM)\s+`?(\w+)`?/i)[1]

            # table_nameにoperationを紐づける
            $table_operations ||= {}
            $table_operations[table_name] ||= []
            $table_operations[table_name] << operation unless $table_operations[table_name].include?(operation)

            File.open(Rails.root.join($crud_config.base_dir, $crud_config.sql_log), 'a') do |file|
              file.puts "#{Time.now} - #{data[:name]} - #{data[:sql]}"
            end
          end
        end
      end
    end
    # モジュールがロードされたときに初期化処理を実行
    setup_notifications
  end
end