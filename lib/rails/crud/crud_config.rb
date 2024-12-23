class CrudConfig
  include Singleton

  attr_accessor :enabled, :base_dir, :crud_file, :crud_log, :method_col, :action_col, :table_start_col, :header_bg_color

  def initialize(config_file)
    config = if File.exist?(config_file)
               YAML.load_file(config_file)
    else
      {}
             end

    @enabled = config.key?('enabled') ? config['enabled'] : true
    @base_dir = config['base_dir'] || 'doc'
    @crud_file = config['crud_file'] || 'crud.xlsx'
    @crud_log = config['crud_log'] || 'crud.log'
    @method_col = config['method_col'] || 'Verb'
    @action_col = config['action_col'] || 'Controller#Action'
    @table_start_col = config['table_start_col'] || 'active_admin_comments'
    @header_bg_color = config['header_bg_color'] || '00FFCC'
  end

  def crud_file_path
    File.join(@base_dir, @crud_file)
  end

  def crud_log_path
    File.join(@base_dir, @crud_log)
  end
end