RTelldus
========

Telldus Tellstick API for Ruby

Supports:
* Devices
* Sensors
* Callbacks

Example
=====
<pre>
<code>
# Get all devices
devices = RTelldus.devices

# Get device with id 1
device = RTelldus.get 1

# Get device name
device.name

# Get device status
device.status

# Turn on device
device.turn_on

# Turn of device
device.turn_off
</code>
</pre>
