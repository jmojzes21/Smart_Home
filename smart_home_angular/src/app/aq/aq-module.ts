import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AqPage } from './pages/aq-page/aq-page';
import { CoreModule } from '../core/core-module';
import { AqRoutingModule } from './aq-routing-module';

@NgModule({
  declarations: [AqPage],
  imports: [CommonModule, AqRoutingModule, CoreModule],
})
export class AqModule {}
