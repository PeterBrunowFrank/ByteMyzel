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

def creater(datei)
	if !File.exist?(datei) || File.size(datei) < (0xFFFF + 255)
		File.open(datei, "wb") do |f|
			((0xFFFF + 255) + 1).times { f.write([127].pack('C')) }
		end
	end
end

class Emergency
	# Number( 0, 1, 2, …) , Team (0 / 1), log = History-Array ["E2","F3",…] 2 Byte
	# intent= ?own will? (0-255)
	attr_accessor :nr, :team, :log, :intent
	# Position
	attr_accessor :x, :y, :z
	@@nr=0
	@@all=[]
	# Next Number
	def self.new_num; @@nr+=1; end
	# Cube Livespace
	def self.all_instances; @@all; end
	def initialize(x, y, z)
		@x, @y, @z = x, y, z	# set coordinates
		@nr= self.class.new_num			# starts with 1 as first Number
		@team = (@nr % 2)		# one to the "right",one by "left" team
		@log=[]					# empty history
		@intent=127				# norm
		@ready = true			# for stepvalidating
		@@all << self			# redundant, yes-but view of Emergencies … useable as "self.all_instances"
	end
	def to_s
		"Team:#{@team} Number:#{@nr.to_s.rjust(5)} intent:#{@intent.to_s.rjust(3)} at: #{@x.to_s.center(3)} #{@y.to_s.center(3)}#{@z.to_s.center(5)} stepable:#{(stepable) ? '✓' :' '} near:#{(looknear) ? '✓' : ' '} far(10):#{(lookfar(10)) ? '✓' : ' '}"
	end
	def step
		if @z-1 < 0    # reached ground? starts new from top
			@x=rand(CUBEW)
			@y=rand(CUBEL)
			@z=CUBED
		end
		@z-=1 if rand(5)==0
		if @intent < 0
			# write_neg_history
			@intent=127
			# restart? where? normaly top
		elsif @intent > 255
			# write_good_history
			@intent=127
			# restart? where? normaly top
		else
			@intent -= 1   # decreases every step
		end
		#puts "back to livespace:#{debug_trace}"
	end
	def stepable # true is free
		@@all.none? { |em| em.x == @x && em.y == @y && em.z == @z-1 }
	end
	def looknear(pushback=false) # true if other emergency near
		return (pushback ? [] : false) if @z==0
		if pushback
	  		@@all.select do |em|
				em.x.between?(@x-1, @x+1) &&
				em.y.between?(@y-1, @y+1) &&
				em.z==@z-1
  			end
		else
	  		!@@all.none? do |em|
				em.x.between?(@x-1, @x+1) &&
				em.y.between?(@y-1, @y+1) &&
				em.z==@z-1
  			end
		end
	end
	def lookdown(pushback=false) # true if other emergency near
		return (pushback ? [] : false) if @z==0
		if pushback
	  		@@all.select do |em|
				em.x==@x &&
				em.y==@y &&
				em.z.between?(0, @z-1)
  			end
		else
	  		!@@all.none? do |em|
				em.x==@x &&
				em.y==@y &&
				em.z.between?(0, @z-1)
	  		end
		end
	end
	def lookfar(wide, pushback=false) # true if other emergency littlebit wider
		return (pushback ? [] : false) if @z==0
		half = wide/2
		if pushback
	  		@@all.select do |em|
  				next if em==self
				em.x.between?(@x-half, @x+half) &&
				em.y.between?(@y-half, @y+half) &&
				em.z.between?(@z-wide, @z-1)
  			end
		else
	  		!@@all.none? do |em|
  				next if em==self
				em.x.between?(@x-half, @x+half) &&
				em.y.between?(@y-half, @y+half) &&
				em.z.between?(@z-wide, @z-1)
  			end
		end
	end
	def emerge
		step if stepable
		puts to_s
		log_builder
		puts "@LOG: #{@log.join(' ')}"
	end
	def logger(obj)
		byte = 0
		byte |= 1 << 7 if obj.team==@team
		byte |= 1 << 6 if lookfar(10,true).include?(obj)
		byte |= 1 << 5 if looknear(true).include?(obj)
		byte |= 1 << 4 if lookdown(true).include?(obj)
		byte |= 1 << 3 if obj.x <= @x
		byte |= 1 << 2 if obj.x >= @x
		byte |= 1 << 1 if obj.y <= @y
		byte |= 1 << 0 if obj.y >= @y
		byte.to_s(16).rjust(2, '0').upcase
	end
	def log_builder
		tmp=[]
		tmp = (lookfar(10,true) + lookdown(true) + looknear(true)).uniq
		nearest_two=[]
		if tmp.any?
			tmp_two = tmp.sort_by do |em|
				(em.x - @x).abs + (em.y - @y).abs + ((em.z - @z) * 2).abs
			end.first(2)
			tmp_two.each do |em|
				nearest_two << logger(em)
			end
			new_entry = nearest_two.join
			@log << new_entry if @log.last != new_entry

			@log << nearest_two.join unless @log.last==nearest_two.join
			@log.shift if @log.size>15
		end
		#links=rechts=127
		#tmp=logger(self)[0]
		#if tmp != nil
		#	rechts=reader(logger(self)[0])
		#end
		#@w-=40 # dreh links
		#tmp=logger(self)[0]
		#if tmp != nil
		#	links=reader(logger(self)[0])
		#end
		#@w+=20 # dreh ursprung
		#[links, rechts]
	end
	def writer(hex_str,wert)
		if hex_str.size==2
			offset = hex_str.to_i(16)
		else
			offset = hex_str.to_i(16) + 255  # Fester Offset
		end
		File.open($datei, "r+b") do |file|
			file.seek(offset)
			file.write([wert].pack('C'))
		end
	end
	def reader(hex_str)
		File.open($datei, 'rb') do |file|
			# Offset berechnen (GLEICH wie in write!)
			if hex_str.size == 2
				offset = hex_str.to_i(16)
			else
				offset = hex_str.to_i(16) + 255
			end
			# Direkt zum Offset springen (KEIN Header!)
			file.seek(offset)
			# Ein Byte lesen
			wert = file.read(1)&.unpack('C')&.first
			wert
		end
	end
end
