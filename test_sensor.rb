#!/usr/bin/env ruby
require_relative 'lib/rtelldus'

sensors = RTelldus.sensors

sensors.each do |sensor|
    puts "ID: #{sensor.id}"
    puts "  Model: #{sensor.model}"
    puts "  Protocol: #{sensor.protocol}"
    puts "  Temperature: #{sensor.temperature}"
    puts "  Humidity: #{sensor.humidity}"
end

puts "Temperature of sensor with ID 61 and type oregon #{RTelldus.from_predefined(:oregon, 61).temperature}"
sensors.at(0).register_callback(lambda{|data| puts data.inspect}) if sensors.length >0
RTelldus::register_raw_event_callback(lambda{|data| puts data.inspect})
sleep(1000)
