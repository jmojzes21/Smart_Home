export enum DeviceType {
  airQuality,
  unknown,
}

export class DeviceTypeHelper {
  static parseType(text: string) {
    switch (text) {
      case 'air_quality':
        return DeviceType.airQuality;
      default:
        return DeviceType.unknown;
    }
  }
}
