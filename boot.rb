# Add environment specific files to load path
path = File.join(File.expand_path(File.dirname(__FILE__)), 'environment')
$:.unshift(path) unless $:.include?(path)

# Add app/models to loadpath
path = File.join(File.expand_path(File.dirname(__FILE__)), 'app', 'models')
$:.unshift(path) unless $:.include?(path)

# Add app/cache to loadpath
path = File.join(File.expand_path(File.dirname(__FILE__)), 'app', 'cache')
$:.unshift(path) unless $:.include?(path)
