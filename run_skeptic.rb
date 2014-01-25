require 'yaml'

CONFIG_DICT = YAML.load_file(ARGV[0])
RUN_IN_DIR  = ARGV[1]

files   = Dir.entries(RUN_IN_DIR).map { |x| x.prepend RUN_IN_DIR if x.end_with? '.rb' }.compact
command = CONFIG_DICT.map { |k, v| v == true ? '--%s' % k : '--%s %s' % [k, v] }
                     .map { |opt| opt.gsub('_', '-') }
                     .join(' ')
                     .prepend('skeptic ')

files.delete("engine/ui.rb")

Kernel.exit(1) if files.map { |file| system(command + ' ' + file) }.include? false
Kernel.exit(0)
