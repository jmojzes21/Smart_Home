import { Injectable } from '@angular/core';
import { Device } from '../../core/models/device';
import { DeviceTypeHelper } from '../../core/models/device_type';

@Injectable({
  providedIn: 'root',
})
export class DeviceService {
  public async getDevices(): Promise<Device[]> {
    let json = localStorage.getItem('devices');
    if (json == null) return <Device[]>[];

    return this.parseDevices(json);
  }

  private parseDevices(text: string) {
    let json = JSON.parse(text);
    let devices: Device[] = json.map((e: any) => this.parseDevice(e));
    return devices;
  }

  private parseDevice(data: any) {
    let id = data['id'] as string;
    let name = data['name'] as string;
    let type = DeviceTypeHelper.parseType(data['type'] as string);
    let hostname = data['hostname'] as string;
    return new Device(id, name, type, hostname);
  }
}
