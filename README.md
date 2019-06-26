# remote-atx-power
Power on ATX remotely


## Requirements

* WiringPi compatible board (Raspberry Pi, Orange Pi, Odroid etc)
* 8 dupont female-female cables
* 2 resistors 
* 2 opto couplers
* 12 pins


## Schemtics

[IMAGE]

## Usage

./action.sh [action]

Where action:

* (empty action) - single short power button press to power on
* off - check the power led and ping, if ATX is on - single short power button press to shutdown
* long - long power button press, should trigger acpi immediate power off
* dry - just print status

## Example

To turn power on:

`./action.sh`

Note: if the server is on the button will not be pressed to avoid accidental shutdown

To shutdown:

`./action off`
