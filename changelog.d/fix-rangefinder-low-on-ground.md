### Fixed

- **A downward rangefinder reading below its minimum range is now treated as zero height while
  the aircraft is on the ground and during a VTOL takeoff**, as it already was in VTOL land
  final. Previously `relative_ground_altitude()` fell back to the terrain database or the height
  above home in that case. On a vehicle taking EKF height from GPS that fallback carries the GPS
  height error, which above 5 m releases the VTOL motors from throttle suppression and above
  `Q_VFWD_ALT` + 2 m opens the forward-throttle scaler, so the forward motor can run with the
  aircraft still on the pad. `TERRAIN_OFS_MAX` can now be chosen for flight alone instead of
  being used to mask this.

### Notes

- This is the one change in this release that is not behind an option bit. It alters
  `relative_ground_altitude()` only when the rangefinder reads `OutOfRangeLow` **and** the
  aircraft is not flying or is in a VTOL takeoff; in flight nothing changes.
