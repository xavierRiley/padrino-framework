[
  '', 
  '-core', 
  '-gen', 
  '-helpers', 
  '-testing',
  '-mailer', 
  '-cache', 
  '-admin', 
].each { |component|
  $LOAD_PATH.unshift(File.expand_path("../padrino#{component}/lib", __FILE__))
}
