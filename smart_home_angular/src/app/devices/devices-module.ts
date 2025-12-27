import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AppRoutingModule } from '../app-routing-module';
import { DevicesPage } from './pages/devices-page/devices-page';
import { CoreModule } from '../core/core-module';

@NgModule({
  declarations: [DevicesPage],
  imports: [CommonModule, AppRoutingModule, CoreModule],
})
export class DevicesModule {}
