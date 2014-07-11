#!/usr/bin/env ruby
require_relative 'lib/rtelldus'
require 'json'
sensor = nil
begin
  sensors = RTelldus.sensors

  sensors.each do |sensor|
    puts "ID: #{sensor.id}"
    puts "  Model: #{sensor.model}"
    puts "  Protocol: #{sensor.protocol}"
    puts "  Temperature: #{sensor.temperature}"
    puts "  Humidity: #{sensor.humidity}"
    puts "  Data types: #{sensor.data_types}"
  end

  sensor = RTelldus.from_predefined(:oregon, 125)
  puts "Temperature of sensor with ID 125 and type oregon #{sensor.temperature}"
  sensor.register_callback(lambda{|data| puts data.inspect}) if sensors.length >0
  RTelldus::register_raw_event_callback(lambda{|data| puts data.inspect})
  sleep(1000)
rescue SystemExit, Interrupt => e
rescue Exception
  #puts e.message
  #puts e.backtrace.join("\n")
  puts $!.inspect, $@
end
puts "Cleaning up!"
sensor.unregister_callbacks if sensor!=nil
