%w[core gen helpers mailer cache admin].each do |component|
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'padrino-#{component}/lib'))
end
