import 'package:go_router/go_router.dart';
import 'package:smart_home_core/device.dart';

import '../logic/services/service_factory.dart';
import '../logic/vm/home_page_view_model.dart';
import '../widgets/metrics_card.dart';
import 'exception_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kvaliteta zraka'), actions: [buildAppBarMenu(context)]),
      body: ChangeNotifierProvider(
        create: (context) {
          var serviceFactory = ServiceFactory(context.read<DeviceManager>().device);
          return HomePageViewModel(
            aqService: serviceFactory.getAirQualityService(),
            openExceptionPage: (message) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ExceptionPage(message)));
            },
          );
        },
        //child: buildBody(context),
        child: Consumer<HomePageViewModel>(builder: (context, model, child) => buildBody(context, model)),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Početna'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Postavke'),
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context, HomePageViewModel model) {
    if (model.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(80),
        child: Center(child: buildMetrics(context, model)),
      ),
    );
  }

  Widget buildMetrics(BuildContext context, HomePageViewModel model) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: Row(
            children: [
              Expanded(
                child: MetricsCard(
                  image: getImage('assets/air_quality/temperature.png'),
                  title: Text('Temperatura', style: textTheme.titleMedium),
                  value: Text('${model.airQuality.temperature.toStringAsFixed(1)} °C', style: textTheme.titleLarge),
                ),
              ),
              SizedBox(width: 40),
              Expanded(
                child: MetricsCard(
                  image: getImage('assets/air_quality/humidity.png'),
                  title: Text('Vlaga', style: textTheme.titleMedium),
                  value: Text('${model.airQuality.humidity.round()} %', style: textTheme.titleLarge),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: MetricsCard(
                image: getImage('assets/air_quality/cloud.png'),
                title: Text('Tlak', style: textTheme.titleMedium),
                value: Text('${model.airQuality.pressure.toStringAsFixed(1)} hPa', style: textTheme.titleLarge),
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: MetricsCard(
                image: getImage('assets/air_quality/wind.png'),
                title: Text('PM2.5', style: textTheme.titleMedium),
                value: RichText(
                  text: TextSpan(
                    style: textTheme.titleLarge,
                    children: [
                      TextSpan(text: '${model.airQuality.pm25} µg/m'),
                      TextSpan(
                        text: '3',
                        style: textTheme.titleLarge!.copyWith(fontFeatures: [FontFeature.superscripts()]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildAppBarMenu(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(onPressed: () => context.replace('/devices'), leadingIcon: Icon(Icons.exit_to_app), child: Text('Zatvori uređaj')),
      ],
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(Icons.more_vert),
        );
      },
    );
  }

  Widget getImage(String name) {
    return Image.asset(name, width: 80, height: 80, filterQuality: FilterQuality.medium);
  }
}
