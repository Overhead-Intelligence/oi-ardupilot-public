# Changelog

Overhead Intelligence's ArduPilot firmware. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

These version numbers are this fork's own and are independent of ArduPilot's. Every release
names the upstream ArduPilot release it is built on, and the firmware reports both: the banner
and the dataflash log read `OI-1.0.0 (abcd1234) [ArduPlane V4.7.2]`.

## [Unreleased]

## [1.0.0] - 2026-11-19

### Added

- Q_ASSIST_OPTIONS bit 2 applies Q_ASSIST_DELAY to the airspeed assist trigger, so a transient pitot dip no longer starts an assist episode
- LightWare I2C filtered rangefinder types: RNGFNDx_TYPE 94 (median first return) and 95 (median last return)
- TECS_OPTIONS bit 4 (16) HDEM_LAG_FF applies the autoland height-demand lag compensation to all height control, correcting a chronic low altitude miss in terrain following
- TECS_OPTIONS bit 3 (8) HDEM_NO_RETRACT stops TECS shrinking its own climb-rate limit while pitch, throttle or the energy-rate demand is clipped
- Q_TRANS_HOLD holds attitude and heading with the VTOL controller through the forward transition airspeed wait, bounded by Q_TRANS_HDG_ERR and Q_TRANS_YAW_SCL
- Q_TRANS_MIN_T and Q_TRANS_LIFT stop the airspeed wait ending before a minimum time or while the lift motors are still carrying the aircraft

### Fixed

- LightWare I2C filtered drivers returned about 1.95 m instead of 96 m out of range, from centimetres being read as metres when max_distance_cm() became max_distance()
- Fixed wing autotune no longer cuts P and D on its first completed event after every boot
- Fixed wing autotune pauses while the VTOL motors are assisting, in Q assist, the transition timer, the landing airbrake and any VTOL mode
- A rangefinder below its minimum range is treated as zero height on the ground and in VTOL takeoff, as it already was in VTOL land final, so GPS height error can no longer release the VTOL motors or the forward-throttle scaler while the aircraft is on the pad

### Notes

- Both TECS_OPTIONS bits default off and take effect without a reboot. 24 enables both; an aircraft already using bit 1 needs 26
- All five Q_TRANS_ parameters default to leaving the transition unchanged
- The rangefinder-on-ground fix is the only change in this release not behind an option; it alters nothing in flight, so TERRAIN_OFS_MAX can now be chosen for flight alone
