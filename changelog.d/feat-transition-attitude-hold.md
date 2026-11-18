### Added

- **Forward-transition attitude and heading hold (`Q_TRANS_HOLD`).** During the airspeed wait on
  a separate-lift-thrust quadplane, the VTOL attitude controller holds the navigation roll and
  pitch and a soft heading target, and the control surfaces follow its rate demand, using the
  hooks ArduPlane already has for vectored-yaw tiltrotors. Without it the lift motors only follow
  the fixed-wing rate demand and have no attitude loop, so a nose-up moment from the forward
  motor at low airspeed becomes a pitch balloon. `Q_TRANS_HDG_ERR` and `Q_TRANS_YAW_SCL` bound
  the heading correction and the lift-motor yaw authority, because lift-motor yaw twists the wing
  and a lifting wing turns that twist into roll.
- **Transition completion checks (`Q_TRANS_MIN_T`, `Q_TRANS_LIFT`).** The airspeed wait cannot
  end before a minimum time, or while the lift motors are still carrying the aircraft. These
  guard against a pitot that reads high, which otherwise ends the transition at once and ramps
  the lift motors down at hover speed.

### Notes

- All five parameters default to leaving the feature inert (`Q_TRANS_HOLD` 0,
  `Q_TRANS_HDG_ERR` 15, `Q_TRANS_YAW_SCL` 0.5, `Q_TRANS_MIN_T` 0, `Q_TRANS_LIFT` 0), so with the
  defaults this firmware transitions exactly as the base release does.
- `Q_TRANS_LIFT` is compared against the hover-throttle estimate, so it is only meaningful on an
  airframe whose `Q_M_THST_HOVER` is current. Where `Q_M_HOVER_LEARN` is off and the stored value
  has drifted low, set `Q_TRANS_LIFT` from measured hover throttle rather than from the parameter.
