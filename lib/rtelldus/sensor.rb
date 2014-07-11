module RTelldus

  class Sensor

    attr_reader :protocol, :model, :id, :callback_functions

    def to_json(options={})
    	ret_val = {'protocol' => @protocol, 'model' => @model, 'id' => @id, 'data_types' => @data_types, 'temperature' => temperature}
    	ret_val['humidity'] = humidity if data_types.include?(:TELLSTICK_HUMIDITY)

		  ret_val.to_json
    end

    def initialize(protocol, model, id, data_types)
      @protocol = protocol
      @model = model
      @data_types = data_types
      @id = id
      @callback_functions = {}
    end

    def temperature
      p_value  = FFI::MemoryPointer.new(:string, 4)
      p_time  = FFI::MemoryPointer.new(:int, 2)
      RTelldus::API.sensor_value(@protocol, @model, @id, RTelldus::API::TELLSTICK_TEMPERATURE, p_value, 4, p_time)
      {value: p_value.get_string(0,4).to_f, time: Time.at(p_time.get_int32(0))}
      #{value: read_string(p_value, 0, 4).to_f, time: Time.at(p_time.get_int32(0))}
    end

    def humidity
      p_value  = FFI::MemoryPointer.new(:string, 4)
      p_time  = FFI::MemoryPointer.new(:int, 2)
      RTelldus::API.sensor_value(@protocol, @model, @id, RTelldus::API::TELLSTICK_HUMIDITY, p_value, 4, p_time)
      {value: p_value.get_string(0,4).to_f, time: Time.at(p_time.get_int32(0))}
      #{value: read_string(p_value, 0, 4).to_f, time: Time.at(p_time.get_int32(0))}
    end

    def register_callback(proc)
      object_id  = FFI::MemoryPointer.new(:int32)
      object_id.write_int32(self.object_id)
      callback = Proc.new do |p_protocol, p_model, sensor_id, data_type, p_value, timestamp, callback_id, context|
        sensor = ObjectSpace._id2ref(context.get_int32(0))
        if sensor_id.to_i == sensor.id.to_i
          protocol = p_protocol.read_string_to_null.dup
          model = p_model.read_string_to_null.dup
          value = p_value.read_string_to_null.dup

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

    def data_types
      API.supported_sensor_value_types.select { |k,v| (@data_types & v) != 0 }.keys
    end

    private

    def read_string(pointer, start=nil, stop=nil)
      API.read_string pointer, start, stop
    end
  end

  # A mapping of known protocols and models
  # for different sensor products.
  SENSORS = {
    # Clas Ohlson Esic 36-179* sensors
    wt450h: {
      protocol: "mandolyn",
      model: "temperaturehumidity",
      data_types: 3
    },
    oregon: {
      protocol: "oregon",
      model: "1A2D",
      data_types: 3
    },
    fineoffset: {
      protocol: "fineoffset",
      model: "temperature",
      data_types: 1
    },
    fineoffset_humidity: {
      protocol: "fineoffset",
      model: "temperaturehumidity",
      data_types: 3
    }
  }
end
