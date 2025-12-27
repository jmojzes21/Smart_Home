import { DeviceType } from './device_type';

export class Device {
  public id!: string;
  public name!: string;
  public type!: DeviceType;
  public hostname!: string;

  constructor(id: string, name: string, type: DeviceType, hostname: string) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.hostname = hostname;
  }
}
