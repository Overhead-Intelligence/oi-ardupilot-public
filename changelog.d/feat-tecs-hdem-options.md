### Added

- TECS_OPTIONS bit 4 (16) HDEM_LAG_FF applies the autoland height-demand lag compensation to all height control, correcting a chronic low altitude miss in terrain following
- TECS_OPTIONS bit 3 (8) HDEM_NO_RETRACT stops TECS shrinking its own climb-rate limit while pitch, throttle or the energy-rate demand is clipped

### Notes

- Both TECS_OPTIONS bits default off and take effect without a reboot. 24 enables both; an aircraft already using bit 1 needs 26
