require 'yaml'

if ARGV != []
  RUN_IN_DIR  = ARGV[1]
  CONFIG_FILE = ARGV[0]

  skeptic_command = YAML.load_file(CONFIG_FILE).map { |k, v| v != true ? '--%s %s' % [k, v] : '--%s' % k }
                                               .map { |k, _| k.gsub('_', '-') }
                                               .join(' ')
                                               .prepend('skeptic ')

  ruby_files      = Dir.entries(RUN_IN_DIR).keep_if { |x| x.end_with? '.rb' }
                                           .map     { |x| x.prepend RUN_IN_DIR }
end

exit_with = 'Kernel.exit(0)'

ruby_files.each do |file|
  output = system([skeptic_command, file].join(' '))
  exit_with = 'Kernel.exit(1)' if output == false
end

eval exit_with
