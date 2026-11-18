### Fixed

- **The fixed-wing autotune no longer cuts P and D on its first event after boot.** The
  oscillation tracking (`min_Dmod`, `max_Dmod` and the per-event slew and gain maxima) was only
  reset when an event ended, and a freshly allocated autotune starts zero-filled, so the first
  completed event of every boot took the oscillation branch and applied P x 0.35, D x 0.75 to
  gains that were not oscillating. A later start in the same boot inherited whatever the previous
  session left behind. `AP_AutoTune::start()` now clears the tracking.
- **The roll, pitch and yaw autotunes now pause while the VTOL motors are helping** - during Q
  assist, the transition timer, the landing airbrake, and in any VTOL mode. The VTOL motors'
  contribution was being read as controller oscillation. Any event in progress is dropped and the
  tracking and filters restart when the pause ends; the gains, feed-forward estimate and limits
  found so far are kept.
