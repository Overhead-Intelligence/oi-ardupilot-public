### Fixed

- A rangefinder below its minimum range is treated as zero height on the ground and in VTOL takeoff, as it already was in VTOL land final, so GPS height error can no longer release the VTOL motors or the forward-throttle scaler while the aircraft is on the pad

### Notes

- The rangefinder-on-ground fix is the only change in this release not behind an option; it alters nothing in flight, so TERRAIN_OFS_MAX can now be chosen for flight alone
