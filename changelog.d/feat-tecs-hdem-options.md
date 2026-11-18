### Added

- **`TECS_OPTIONS` bits that correct a chronic low altitude miss in terrain following.** Bit 4
  (`HDEM_LAG_FF`, value 16) applies the height-demand lag compensation TECS already uses on an
  autoland approach to all height control, removing a standing offset of `TECS_HDEM_TCONST` x
  climb rate that no downstream loop can take out. Bit 3 (`HDEM_NO_RETRACT`, value 8) stops TECS
  shrinking its own climb-rate limit while pitch, throttle or the energy-rate demand is clipped.
  Both default off, so the firmware behaves like the base release until one is set;
  `TECS_OPTIONS` 24 turns on both, and an aircraft already using bit 1 needs 26.

### Notes

- Both bits take effect immediately; no reboot is needed.
- Measured in flight on a terrain-following quadplane: with bit 4 on, the demand's steady-state
  error on sustained climbs fell from -3.09 m per m/s of climb (the predicted
  -`TECS_HDEM_TCONST`) to -0.03, and the accumulated climbing error over a sortie from -6.2 m to
  -0.1 m. Bit 3 was then exercised on its own over twelve matched climb legs: it suppressed the
  climb-limit retraction completely (the limit held at 100% of `TECS_CLMB_MAX` against 91% with
  the bit clear, while the energy-rate clip was active 99% of the leg against 7%), and changed
  the achieved climb rate by about 3%. The gap is small because that aircraft's
  `TECS_CLMB_MAX` was set to roughly what it can actually climb, which leaves the retraction
  little to take away; expect bit 3 to matter more where `TECS_CLMB_MAX` is set above what the
  airframe can sustain.
