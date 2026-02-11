
#pragma once

class Metrics {

  private:

  double sum = 0;
  int count = 0;

  double averageValue = 0;
  double minValue = 0;
  double maxValue = 0;


  public:

  Metrics();

  void reset();

  void addValue(double value);

  void calculateAverage();

  double getAverage();
  double getMinValue();
  double getMaxValue();

};
