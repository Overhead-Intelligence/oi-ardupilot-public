### Added

- LightWare I2C filtered rangefinder types: RNGFNDx_TYPE 94 (median first return) and 95 (median last return)

### Fixed

- LightWare I2C filtered drivers returned about 1.95 m instead of 96 m out of range, from centimetres being read as metres when max_distance_cm() became max_distance()
