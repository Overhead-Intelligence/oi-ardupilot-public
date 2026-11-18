### Added

- **LightWare I2C filtered rangefinder types.** `RNGFNDx_TYPE` 94 reports the median of recent
  first-return distances and 95 the median of recent last-return distances, for lidars whose raw
  stream is noisy over vegetation and water.

### Fixed

- **A centimetre-for-metre unit error in those two drivers.** `max_distance_cm()` was replaced by
  `max_distance()`, which returns metres, while the drivers kept centimetre internals, so four
  sites added a 100 cm out-of-range margin to a value in metres and then scaled the sum by 0.01.
  An out-of-range return read as about 1.95 m instead of 96 m.
