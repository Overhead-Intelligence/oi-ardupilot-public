### Added

- Q_TRANS_HOLD holds attitude and heading with the VTOL controller through the forward transition airspeed wait, bounded by Q_TRANS_HDG_ERR and Q_TRANS_YAW_SCL
- Q_TRANS_MIN_T and Q_TRANS_LIFT stop the airspeed wait ending before a minimum time or while the lift motors are still carrying the aircraft

### Notes

- All five Q_TRANS_ parameters default to leaving the transition unchanged
