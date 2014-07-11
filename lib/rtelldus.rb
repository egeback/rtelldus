require 'ffi'
require_relative 'rtelldus/version'
require_relative 'rtelldus/core'
require_relative 'rtelldus/device'
require_relative 'rtelldus/sensor'

module RTelldus
  @@callback_functions = {}

  def self.init
    RTelldus::API.init
  end

  init

  # Get all the devices. That is all the devices Tellstick know about
  # (the content of the file usually located in /etc/tellstick.conf).
  #
  # @return [Array] of devices.
  def self.devices
    devices = []
    RTelldus::API.number_of_devices.times do |i|
      devices << Device.new(API.get_device_id(i))
    end
    devices
  end

  def self.sensors
    sensors = []
    result = API::TELLSTICK_SUCCESS
    while(true) do
      protocol = FFI::MemoryPointer.new(:string, 32)
      model  = FFI::MemoryPointer.new(:string, 32)
      data_types  = FFI::MemoryPointer.new(:int, 2)
      id = FFI::MemoryPointer.new(:int, 2)
      test = API.sensor(protocol, 32, model, 32, id, data_types)
      if test.to_i == RTelldus::API::TELLSTICK_SUCCESS
        sensors << Sensor.new(protocol.get_string(0, 32), model.get_string(0, 32), id.get_int32(0), data_types.get_int32(0))
      else
        break
      end
    end
    sensors
  end

  def self.from_predefined(key, id)
    predefined = SENSORS[key.to_sym]
    if predefined
      return Sensor.new(predefined[:protocol], predefined[:model], id, predefined[:data_type])
    else
      raise "Unknown sensor product. Predefined sensors: #{SENSORS.map{|k,v| k}.join(', ')}"
    end
  end

  def self.close
   RTelldus::API.close
  end

  # Find a device by it's id.
  #
  # @param id the id of the device
  # @return [Device, nil] the device or nil.
  def self.find(id)
    id = id.to_i
    name = read_string RTelldus::API.name(id)
    return nil if name.empty? || name == 'UNKNOWN'

    Device.new(id)

    #Device.new id, name
  end

  def self.get(id)
    self.find(id)
  end

  def self.register_raw_event_callback(proc)
    callback = Proc.new do |data, controller_id, callback_id, context|
      RTelldus::callback_functions[callback_id].call({
        controller_id: controller_id,
        data: data
      })
    end
    id = RTelldus::API.register_raw_device_event(callback, nil)
    RTelldus::callback_functions[id] = proc
    id
  end

  def self.register_sensor_callback(proc)
    callback = Proc.new do |p_protocol, p_model, sensor_id, data_type, p_value, timestamp, callback_id, context|
      protocol = p_protocol.read_string_to_null.dup
      model = p_model.read_string_to_null.dup
      value = p_value.read_string_to_null.dup

      RTelldus::callback_functions[callback_id].call({
        kind: (data_type == RTelldus::API::TELLSTICK_TEMPERATURE ? :temperature : :humidity),
        value: value.to_f, timestamp: Time.at(timestamp.to_i),
        id: sensor_id
      })
    end
    id = RTelldus::API.register_sensor_event(callback, nil)
    self.callback_functions[id] = callback
    id
  end


  def self.unregister_callback(id)
    API.unregister_callback(id)
    RTelldus::callback_functions.delete(id)
  end

  def self.unregister_callbacks
    self.callback_functions.each do |k,v|
      RTelldus::API.unregister_callback(k)
      RTelldus::callback_functions.delete(k)
    end
    RTelldus::callback_functions
  end

  private
  def self.callback_functions
    @@callback_functions
  end

  def self.read_string(pointer)
    API.read_string pointer
  end
end
