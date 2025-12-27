import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NavigationComponent } from './components/navigation/navigation';
import { AppRoutingModule } from '../app-routing-module';
import { RouterLink } from '@angular/router';

@NgModule({
  declarations: [NavigationComponent],
  imports: [CommonModule, AppRoutingModule],
  exports: [NavigationComponent],
})
export class CoreModule {}
