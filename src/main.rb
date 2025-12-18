# ΔΠΞ DeltaPIXi.com: Emergent Behavior Simulation
# A Ruby program simulating emergent behavior and adaptive learning.
#
# Copyright (C) 2025 ΔΠΞ DeltaPIXi.com Peter Brunow-Frank
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# LICENSE file in the project root for the full license text.
#
require "./classes.rb"
require 'optparse'

# Default Werte
options = {
  gui: false,
  instances: 20,
  binfile: "data.bin"
}

# OptionParser konfigurieren
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby main.rb [options] [instances]"

  opts.on("-g", "--gui", "Starte mit GUI (Ruby2D)") do
    options[:gui] = true
  end

  opts.on("-bf FILE", "--binfile FILE", String, "Binary data file (default:'data.bin')") do |file|
	options[:binfile] = file
  end

  opts.on("-k", "--konsole", "Starte in Konsole (explizit)") do
    options[:gui] = false
  end

  opts.on("-h", "--help", "Zeige diese Hilfe") do
    puts opts
    exit
  end

  opts.on("-i N", "--instances N", Integer, "Anzahl Instanzen (default: 10)") do |n|
    options[:instances] = n
  end
end

# Parse die Argumente
begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  puts "Fehler: #{e.message}"
  puts parser
  exit 1
end

# Restliche Argumente (Positional) verarbeiten
ARGV.each do |arg|
  if arg =~ /^\d+$/
    options[:instances] = arg.to_i
  elsif arg =~ /^[\w.\-\/]+$/
	options[:binfile] = arg
  elsif arg == "-g"
    options[:gui] = true
  elsif arg == "-k"
    options[:gui] = false
  end
end
puts "File: #{options[:binfile]}"
puts "GUI: #{options[:gui]}"
puts "Instanzen: #{options[:instances]}"

CUBEW=8 # Cube-width
CUBEL=8 # Cube-length
CUBED=30 # Cube-deep
if !File.exist?("#{options[:binfile]}") || File.size("#{options[:binfile]}") < (0xFFFF + 255)
	creater("#{options[:binfile]}")
end

mainloop = Proc.new do
	Emergency.all_instances.each do |em|
		em.emerge
	end
end
# options[:gui] und options[:instances] verwenden
unless options[:gui] # NUR WEIL ICH KONSOLE OBEN IN DER ABFRAGE WOLLTE SO KRUMM ;-) !!!
	puts "Starte Konsole mit #{options[:instances]} Instanzen"
	options[:instances].times { Emergency.new(rand(CUBEW),rand(CUBEL),rand(CUBED)) }
	loop do
		system('clear')
		mainloop.call
		sleep 0.5
	end
else
	require "ruby2d"
	puts "Starte GUI mit #{options[:instances]} Instanzen"
	set title: "ΔΠΞ DeltaPiXi"
	set background: "#000000"
	set fullscreen: true
	W=1000;H=600
	set(width: W, height: H)
	set fps_cap: 60
	options[:instances].times { GuiEmergency.new(rand(CUBEW),rand(CUBEL),rand(CUBED)) }
	update do
		mainloop.call
		# grafik abfragen, verändern, etc.
	end
	show
end
