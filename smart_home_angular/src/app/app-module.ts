import { NgModule, provideBrowserGlobalErrorListeners } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing-module';
import { App } from './app';
import { CoreModule } from './core/core-module';
import { DevicesModule } from './devices/devices-module';
import { AqModule } from './aq/aq-module';

@NgModule({
  declarations: [App],
  imports: [BrowserModule, CoreModule, DevicesModule, AqModule, AppRoutingModule],
  providers: [provideBrowserGlobalErrorListeners()],
  bootstrap: [App],
})
export class AppModule {}
