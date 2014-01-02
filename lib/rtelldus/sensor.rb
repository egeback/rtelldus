module RTelldus

  class Sensor

    attr_reader :protocol, :model, :id, :callback_functions

    def initialize(protocol, model, id)
      @protocol = protocol
      @model = model
      @id = id
      @callback_functions = {}
      RTelldus::API.init
    end

    def temperature
      value  = FFI::MemoryPointer.new(:string, 4)
      time  = FFI::MemoryPointer.new(:int, 2)
      RTelldus::API.sensor_value(@protocol, @model, @id, 1, value, 4, time)
      {value: value.get_string(0,4).to_f, time: Time.at(time.get_int32(0))}
    end

    def humidity
      value = FFI::MemoryPointer.new(:string, 4)
      time = FFI::MemoryPointer.new(:int, 2)
      RTelldus::API.sensor_value(@protocol, @model, @id, RTelldus::API::TELLSTICK_HUMIDITY, value, 4, time)
      {value: value.get_string(0,4).to_f, time: Time.at(time.get_int32(0))}
    end

    def register_callback(proc)
      object_id  = FFI::MemoryPointer.new(:int32)
      object_id.write_int32(self.object_id)
      callback = Proc.new do |protocol, model, sensor_id, data_type, value, timestamp, callback_id, context|
        sensor = ObjectSpace._id2ref(context.get_int32(0))
        if sensor_id.to_i == sensor.id.to_i
          sensor.callback_functions[callback_id].call({
            kind: (data_type == RTelldus::API::TELLSTICK_TEMPERATURE ? :temperature : :humidity),
            value: value.to_f, timestamp: Time.at(timestamp.to_i),
            id: sensor_id
          })
        end
      end
      id = RTelldus::API.register_sensor_event(callback, object_id)
      @callback_functions[id] = proc
      id
    end

    def unregister_callback(id)
      API.unregister_callback(id)
      @callback_functions.delete(id)
    end

    def unregister_callbacks
      @callback_functions.each do |k,v|
        RTelldus::API.unregister_callback(k)
        @callback_functions.delete(k)
      end
      @callback_functions
    end
  end

  # A mapping of known protocols and models
  # for different sensor products.
  SENSORS = {
    # Clas Ohlson Esic 36-179* sensors
    wt450h: {
      protocol: "mandolyn",
      model: "temperaturehumidity"
    },
    oregon: {
      protocol: "oregon",
      model: "1A2D"
    }
  }
end