### Added

- **`Q_ASSIST_OPTIONS` bit 2 applies `Q_ASSIST_DELAY` to the airspeed assist trigger.** With the
  bit set, the airspeed trigger goes through the same hysteresis as the angle and altitude
  triggers: assist starts once airspeed has been below `Q_ASSIST_SPEED` for `Q_ASSIST_DELAY`,
  clears once it has been back above for twice that, and announces itself with a
  `Speed assist` status text. With the bit clear the trigger is unchanged - immediate, no text -
  which stays the right default for an airframe with a clean pitot. No new parameter.

### Notes

- Aimed at pitot probes that dip transiently in a steep bank or in turbulence while ground speed
  and the EKF show no slow-down. A dip of that kind starts a multi-second assist episode, which
  on a VTOL landing approach caps bank at `LEVEL_ROLL_LIMIT` through the turn-in and can skip the
  airbrake stage. Probe placement is the real fix; this makes the trigger consistent with the
  other two.
