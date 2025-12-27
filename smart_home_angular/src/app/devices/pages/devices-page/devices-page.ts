import { Component, inject, OnInit, signal } from '@angular/core';
import { DeviceService } from '../../../core/services/device-service';
import { Device } from '../../../core/models/device';
import { signalUpdateFn } from '@angular/core/primitives/signals';

@Component({
  selector: 'app-devices-page',
  standalone: false,
  templateUrl: './devices-page.html',
  styleUrl: './devices-page.scss',
})
export class DevicesPage implements OnInit {
  private deviceService: DeviceService = inject(DeviceService);

  public devices = signal<Device[]>([]);

  private async getDevices() {
    this.devices.set(await this.deviceService.getDevices());
  }

  ngOnInit() {
    this.getDevices();
  }
}
