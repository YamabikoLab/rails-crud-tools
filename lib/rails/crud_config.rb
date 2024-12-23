class CrudConfig
  attr_accessor :enabled, :base_dir, :crud_file, :sql_log, :method_col, :action_col, :table_start_col, :header_bg_color

  def initialize(config_file)
    if File.exist?(config_file)
      config = YAML.load_file(config_file)
    else
      config = {}
    end

    @enabled = config.key?('enabled') ? config['enabled'] : true
    @base_dir = config['base_dir'] || 'doc'
    @crud_file = config['crud_file'] || 'crud.xlsx'
    @sql_log = config['sql_log'] || 'sql.log'
    @method_col = config['method_col'] || 'Verb'
    @action_col = config['action_col'] || 'Controller#Action'
    @table_start_col = config['table_start_col'] || 'active_admin_comments'
    @header_bg_color = config['header_bg_color'] || '00FFCC'
  end

  def crud_file_path
    File.join(@base_dir, @crud_file)
  end

  def sql_log_path
    File.join(@base_dir, @sql_log)
  end
end