module RTelldus
  module API
    extend FFI::Library

    ffi_lib ['/Library/Frameworks/TelldusCore.framework/TelldusCore', 'TelldusCore', 'telldus-core.so.2']

    METHODS = enum(
    	:TELLSTICK_TURNON,                       1,
    	:TELLSTICK_TURNOFF,                      2,
    	:TELLSTICK_BELL,                         4,
    	:TELLSTICK_TOOGLE,                       8,
    	:TELLSTICK_DIM,                         16,
    	:TELLSTICK_LEARN,                       32,
    	:TELLSTICK_EXECUTE,                     64,
    	:TELLSTICK_UP,                         128,
    	:TELLSTICK_DOWN,                       256,
    	:TELLSTICK_STOP,                       512
    )

    enum :sensor_values_type, [
    	:TELLSTICK_TEMPERATURE,                  1,
		:TELLSTICK_HUMIDITY,                     2,
		:TELLSTICK_RAINRATE,                     4,
		:TELLSTICK_RAINTOTAL,                    8,
		:TELLSTICK_WINDDIRECTION,               16,
		:TELLSTICK_WINDAVERAGE,                 32,
		:TELLSTICK_WINDGUST,                    64
	]

    TELLSTICK_TEMPERATURE                     = 1
    TELLSTICK_HUMIDITY                        = 2

    enum :error_code, [ 
    	:TELLSTICK_SUCCESS,                      0,
        :TELLSTICK_ERROR_NOT_FOUND,             -1,
        :TELLSTICK_ERROR_PERMISSION_DENIED,     -2,
        :TELLSTICK_ERROR_DEVICE_NOT_FOUND,      -3,
        :TELLSTICK_ERROR_METHOD_NOT_SUPPORTED,  -4,
        :TELLSTICK_ERROR_COMMUNICATION,         -5,
        :TELLSTICK_ERROR_CONNECTING_SERVICE,    -6,
        :TELLSTICK_ERROR_UNKNOWN_RESPONSE,      -7,
        :TELLSTICK_ERROR_SYNTAX,                -8,
        :TELLSTICK_ERROR_BROKEN_PIPE,           -9,
        :TELLSTICK_ERROR_COMMUNICATING_SERVICE,-10,
        :TELLSTICK_ERROR_UNKNOWN,              -99
    ]

    TELLSTICK_SUCCESS                      = 0
    TELLSTICK_ERROR_NOT_FOUND              = -1
    TELLSTICK_ERROR_PERMISSION_DENIED      = -2
    TELLSTICK_ERROR_DEVICE_NOT_FOUND       = -3
    TELLSTICK_ERROR_METHOD_NOT_SUPPORTED   = -4
    TELLSTICK_ERROR_COMMUNICATION          = -5
    TELLSTICK_ERROR_CONNECTING_SERVICE     = -6
    TELLSTICK_ERROR_UNKNOWN_RESPONSE       = -7
    TELLSTICK_ERROR_SYNTAX                 = -8
    TELLSTICK_ERROR_BROKEN_PIPE            = -9
    TELLSTICK_ERROR_COMMUNICATING_SERVICE  =-10
    TELLSTICK_ERROR_UNKNOWN                =-99

    enum :device, [
    	:TELLSTICK_TYPE_DEVICE,                  1,
    	:TELLSTICK_TYPE_GROUP,                   2,
    	:TELLSTICK_TYPE_SCENE,                   3
    ]

    enum :controller, [
    	:TELLSTICK_CONTROLLER_TELLSTICK,         1,
    	:TELLSTICK_CONTROLLER_TELLSTICK_DUO,     2,
    	:TELLSTICK_CONTROLLER_TELLSTICK_NET,     3
    ]

    enum :device_changes, [
    	:TELLSTICK_DEVICE_ADDED,                 1,
    	:TELLSTICK_DEVICE_CHANGED,               2,
    	:TELLSTICK_DEVICE_REMOVED,               3,
    	:TELLSTICK_DEVICE_STATE_CHANGED,         4
    ]

    enum :change_types, [
    	:TELLSTICK_CHANGE_NAME,                  1,
		:TELLSTICK_CHANGE_PROTOCOL,              2,
		:TELLSTICK_CHANGE_MODEL,                 3,
		:TELLSTICK_CHANGE_METHOD,                4,
		:TELLSTICK_CHANGE_AVAILABLE,             5,
		:TELLSTICK_CHANGE_FIRMWARE,              6
	]

    # Callbacks
    #void (WINAPI *TDDeviceEvent)(int deviceId, int method, const char *data, int callbackId, void *context);
    callback :TDDeviceEvent, [:int, :int, :string, :int, :pointer], :void
    #void (WINAPI *TDDeviceChangeEvent)(int deviceId, int changeEvent, int changeType, int callbackId, void *context);"
    callback :TDDeviceChangeEvent, [:int, :int, :int, :int], :void
    #void (WINAPI *TDRawDeviceEvent)(const char *data, int controllerId, int callbackId, void *context);
    callback :TDRawDeviceEvent, [:string, :int, :int, :pointer], :void
    #void (WINAPI *TDSensorEvent)(const char *protocol, const char *model, int id, int dataType, const char *value, int timestamp, int callbackId, void *context);
    callback :TDSensorEvent, [:string, :string, :int, :int, :string, :int, :int, :pointer], :void
    #void (WINAPI *TDControllerEvent)(int controllerId, int changeEvent, int changeType, const char *newValue, int callbackId, void *context);
    callback :TDControllerEvent, [:int, :int, :int, :string, :int], :void

	#Methods
	#void WINAPI tdInit(void);
	attach_function :init, :tdInit, [], :void
	#int WINAPI tdGetNumberOfDevices()
    attach_function :number_of_devices, :tdGetNumberOfDevices, [], :int
    #int WINAPI tdRegisterDeviceEvent( TDDeviceEvent eventFunction, void *context );
    attach_function :register_device_event, :tdRegisterDeviceEvent, [:TDDeviceEvent, :pointer], :int
    #int WINAPI tdRegisterDeviceChangeEvent( TDDeviceChangeEvent eventFunction, void *context);
	attach_function :register_raw_device_event, :tdRegisterRawDeviceEvent, [:TDRawDeviceEvent, :pointer], :int
    #int WINAPI tdRegisterRawDeviceEvent( TDRawDeviceEvent eventFunction, void *context );
	attach_function :register_device_change_event, :tdRegisterDeviceChangeEvent, [:TDDeviceChangeEvent, :pointer], :int
    #int WINAPI tdRegisterSensorEvent( TDSensorEvent eventFunction, void *context );
    attach_function :register_sensor_event,:tdRegisterSensorEvent, [:TDSensorEvent, :pointer], :int
    #int WINAPI tdRegisterControllerEvent( TDControllerEvent eventFunction, void *context);
	#attach_function :register_controller_event, :tdRegisterControllerEvent, [:TDControllerEvent, :pointer], :int  # Version 2.1.2
    #int WINAPI tdUnregisterCallback( int callbackId );
	attach_function :unregister_callback, :tdUnregisterCallback, [:int], :void
	#void WINAPI tdClose(void);
	attach_function :close, :tdClose, [], :void
	 #void WINAPI tdReleaseString(char *string)
    attach_function :release_string, :tdReleaseString, [:pointer], :void

	#int WINAPI tdTurnOn(int intDeviceId);
    attach_function :turn_on, :tdTurnOn, [:int], :error_code
    #int WINAPI tdTurnOff(int intDeviceId);
    attach_function :turn_off, :tdTurnOff, [:int], :error_code
    #int WINAPI tdBell(int intDeviceId);
    attach_function :bell, :tdBell, [:int], :error_code
    #int WINAPI tdDim(int intDeviceId, unsigned char level);
    attach_function :dim, :tdDim, [:int, :char], :error_code
    #int WINAPI tdExecute(int intDeviceId);
    attach_function :execute, :tdExecute, [:int], :error_code
    #int WINAPI tdUp(int intDeviceId);
    attach_function :up, :tdUp, [:int], :error_code
    #int WINAPI tdDown(int intDeviceId);
    attach_function :down, :tdDown, [:int], :error_code
    #int WINAPI tdStop(int intDeviceId);
    attach_function :stop, :tdStop, [:int], :error_code
    #int WINAPI tdLearn(int intDeviceId);
    attach_function :learn, :tdLearn, [:int], :error_code
    #int WINAPI tdMethods(int id, int methodsSupported);
    attach_function :methods, :tdMethods, [:int, :int], :int
    #int WINAPI tdLastSentCommand( int intDeviceId, int methodsSupported );
    attach_function :last_sent_commmand, :tdLastSentCommand, [:int, :int], :int
    #char *WINAPI tdLastSentValue( int intDeviceId );
    attach_function :last_sent_value, :tdLastSentValue, [:int], :pointer

    #int WINAPI tdGetNumberOfDevices();
    attach_function :number_devices, :tdGetNumberOfDevices, [], :int
    #int WINAPI tdGetDeviceId(int intDeviceIndex);
    attach_function :get_device_id, :tdGetDeviceId, [:int], :int
    #int WINAPI tdGetDeviceType(int intDeviceId);
    attach_function :get_device_type, :tdGetDeviceType, [:int], :device

    #char * WINAPI tdGetErrorString(int intErrorNo);
    attach_function :get_error_string, :tdGetErrorString, [:int], :pointer

    #char * WINAPI tdGetName(int intDeviceId);
    attach_function :name, :tdGetName, [:int], :pointer
    #bool WINAPI tdSetName(int intDeviceId, const char* chNewName);
    attach_function :set_name, :tdSetName, [:int, :string], :bool
    #char * WINAPI tdGetProtocol(int intDeviceId);
    attach_function :protocol, :tdGetProtocol, [:int], :pointer

    #bool WINAPI tdSetProtocol(int intDeviceId, const char* strProtocol);
    attach_function :set_protocol, :tdSetProtocol, [:int, :string], :bool
    #char * WINAPI tdGetModel(int intDeviceId);
    attach_function :model, :tdGetModel, [:int], :pointer
    #bool WINAPI tdSetModel(int intDeviceId, const char *intModel);
    attach_function :set_model, :tdSetModel, [:int, :string], :bool
    
    #char * WINAPI tdGetDeviceParameter(int intDeviceId, const char *strName, const char *defaultValue);
    attach_function :get_device_parameter, :tdGetDeviceParameter, [:int, :string, :string], :pointer
    #bool WINAPI tdSetDeviceParameter(int intDeviceId, const char *strName, const char* strValue);
    attach_function :set_device_parameter, :tdSetDeviceParameter, [:int, :string, :string], :bool

    #int WINAPI tdAddDevice();
    attach_function :add_device, :tdAddDevice, [], :int
    #bool WINAPI tdRemoveDevice(int intDeviceId);
    attach_function :remove_device, :tdRemoveDevice, [:int], :bool    

    #int WINAPI tdSendRawCommand(const char *command, int reserved);
    attach_function :send_raw_command, :tdSendRawCommand, [:string, :int], :int 

    #void WINAPI tdConnectTellStickController(int vid, int pid, const char *serial);
    attach_function :connect_tellstick_controller, :tdConnectTellStickController, [:int, :int, :string], :void

    #void WINAPI tdDisconnectTellStickController(int vid, int pid, const char *serial);
    attach_function :disconnect_tellstick_controller, :tdDisconnectTellStickController, [:int, :int, :string], :void

    #int WINAPI tdSensor(char *protocol, int protocolLen, char *model, int modelLen, int *id, int *dataTypes);
    attach_function :sensor, :tdSensor, [:pointer, :int, :pointer, :int, :pointer, :pointer], :int
    #int WINAPI tdSensorValue(const char *protocol, const char *model, int id, int dataType, char *value, int len, int *timestamp);
    attach_function :sensor_value, :tdSensorValue, [:string, :string, :int, :int, :pointer, :int, :pointer], :int

    #int WINAPI tdController(int *controllerId, int *controllerType, char *name, int nameLen, int *available);
    #attach_function :tdController, [:pointer, :pointer, :pointer, :int, :pointer], :int # Version 2.1.2
    #int WINAPI tdControllerValue(int controllerId, const char *name, char *value, int valueLen);
    #attach_function :tdControllerValue, [:int, :pointer, :pointer, :int], :int # Version 2.1.2
    #int WINAPI tdSetControllerValue(int controllerId, const char *name, const char *value);
    #attach_function :tdSetControllerValue, [:int, :string, :string], :int # Version 2.1.2
    #int WINAPI tdRemoveController(int controllerId);
    #attach_function :tdRemoveController, [:int], :int # Version 2.1.2

    def self.read_string(pointer)
      string = pointer.read_string_to_null.dup
      release_string pointer
      string
    end

    def self.supported_methods
      METHODS.to_hash
    end
            
    def self.all_supported_methods_int
      supported_methods.values.inject(0) { |result, element| result | element }      
    end
  end
end
