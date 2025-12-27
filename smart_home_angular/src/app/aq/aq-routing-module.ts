import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AqPage } from './pages/aq-page/aq-page';

const aqRoutes: Routes = [
  {
    path: 'devices/:name/aq',
    component: AqPage,
  },
];

@NgModule({
  imports: [RouterModule.forChild(aqRoutes)],
  exports: [RouterModule],
})
export class AqRoutingModule {}
