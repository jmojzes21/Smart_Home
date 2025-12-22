enum DeviceType {
  airQuality,
  smartLeds,
  unknown;

  static DeviceType parse(String type) {
    switch (type) {
      case 'air_quality':
        return DeviceType.airQuality;
      case 'smart_leds':
        return DeviceType.smartLeds;
      default:
        return DeviceType.unknown;
    }
  }
}
