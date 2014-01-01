require 'ffi'
require_relative 'rtelldus/version'
require_relative 'rtelldus/core'
require_relative 'rtelldus/device'
require_relative 'rtelldus/sensor'

module RTelldus
  # Get all the devices. That is all the devices Tellstick know about
  # (the content of the file usually located in /etc/tellstick.conf).
  #
  # @return [Array] of devices.
  def self.devices
    devices = []
    RTelldus::API.number_of_devices.times do |i|
      devices << Device.new(API.get_device_id(i), API.name(i))
    end
    devices
  end


  def self.sensors
    RTelldus::API.init
    sensors = []
    result = API::TELLSTICK_SUCCESS
    while(true) do
      protocol = FFI::MemoryPointer.new(:string, 32)
      model  = FFI::MemoryPointer.new(:string, 32)
      data_types  = FFI::MemoryPointer.new(:int, 2)
      id = FFI::MemoryPointer.new(:int, 2)
      test = API.sensor(protocol, 32, model, 32, id, data_types)
      if test.to_i == RTelldus::API::TELLSTICK_SUCCESS
        sensors << Sensor.new(protocol.get_string(0, 32), model.get_string(0, 32), id.get_int32(0))
      else
        break
      end
    end
    sensors
  end

  def self.from_predefined(key, id)
    predefined = SENSORS[key.to_sym]
    if predefined
      return Sensor.new(predefined[:protocol], predefined[:model], id)
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
    return nil if name.blank?

    Device.new id, name
  end

  def self.register_raw_event_callback(proc)
    object_id  = FFI::MemoryPointer.new(:int32)
    object_id.write_int32(self.object_id)
    callback = Proc.new do |data, controller_id, callback_id, context|
      device = ObjectSpace._id2ref(context.get_int32(0))
      device.callback_functions[callback_id].call({
        id: controller_id,
        data: data
      })
    end
    id = RTelldus::API.register_raw_device_event(callback, object_id)
    RTelldus::callback_functions[id] = proc
    id
  end

  def self.callback_functions
    @callback_functions = {} if @callback_functions == nil
    @callback_functions
  end
end
