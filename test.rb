#!/usr/bin/env ruby
require_relative 'lib/rtelldus'

devices = RTelldus.devices

devices.each do |device|
    puts "ID: #{device.id}"
    puts "  Name: #{device.name}"
    puts "  Model: #{device.model}"
    puts "  Protocol: #{device.protocol}"
    puts "  Methods: #{device.supported_commands}"
    puts "  Last Command: #{device.last_command.inspect}"
end
puts devices.at(0).register_callback(lambda{|data| puts "Method #{data[:method]}"})
puts devices.at(1).register_callback(lambda{|data| puts "Hej #{data[:method]}"})
#puts devices.at(1).register_callback(lambda{|data| puts "Lampor, Method #{data[:method]}"})
#devices.at(0).turn_off
sleep(100)
