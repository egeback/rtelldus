module RTelldus
  class Device
    attr_reader :id, :name 

    def initialize(id, name)
      @id = id
      @name = name
      @callback_functions = {}
      API.init
    end

    def name
      read_string API.name(id)
    end

    def name=(name)
      API.set_name(id, name)
    end

    def model
      read_string API.model(id)
    end

    def protocol
      read_string API.protocol(id)
    end      

    def supported_commands
      methods = API.methods(id, API.all_supported_methods_int)
      API.supported_methods.select { |k,v| (methods & v) != 0 }.keys
    end
  
    def has_command?(command)
      supported_commands.include? command
    end

    def last_command
      cmd = API.last_sent_commmand(id, API.all_supported_methods_int)
      API.supported_methods.key cmd
    end

    def device_parameter(parameter_name)
      read_string API.get_device_parameter(id, parameter_name, nil)
    end

    def device_parameter(parameter_name, value)
      read_string API.set_device_parameter(id, parameter_name, value)
    end

    def dim_value
      value = read_string API.last_sent_value(id)
      value == '' ? nil : value.to_i
    end
   
    def dim(value)
      API.dim(id, value)
    end

    def learn
      API.learn(id)
    end

    def turn_on
      API.turn_on(id)
     end

    def turn_off
      API.turn_off(id)
    end

    def sound_bell
      API.sound_bell(id)
    end

    def register_callback(proc)
      object_id  = FFI::MemoryPointer.new(:int32)
      object_id.write_int32(self.object_id)
      callback = Proc.new do |device_id, method, data, callback_id, context|
        device = ObjectSpace._id2ref(context.get_int32(0))
        if device_id.to_i == device.id.to_i
          device.callback_functions[callback_id].call({
            device_id: device_id,
            method: method,
            data: data
          })
        end
      end
      id = API.register_device_event(callback, object_id)
      @callback_functions[id] = proc
      id
    end

    def unregister_callback(id)
      API.unregister_callback(id)
      @callback_functions.delete(id)
    end
    
    def callback_functions
      @callback_functions
    end

    def unregister_callbacks
      @callback_functions.each do |k,v|
      	API.unregister_callback(@master_callback_id)
        @callback_functions.delete(k)
      end
      @callback_functions
    end

    def to_s
      name
    end

    private

    def read_string(pointer)
      API.read_string pointer
    end
  end
end
