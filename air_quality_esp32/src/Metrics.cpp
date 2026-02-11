
#include "Metrics.h"

Metrics::Metrics() {
  reset();
}

void Metrics::reset() {
  sum = 0;
  count = 0;

  averageValue = 0;
  minValue = 0;
  maxValue = 0;
}

void Metrics::addValue(double value) {

  sum += value;
  count++;

  if(count == 1) {
    minValue = value;
    maxValue = value;
  }else{

    if(value < minValue) {
      minValue = value;
    }else if(value > maxValue) {
      maxValue = value;
    }

  }

}

void Metrics::calculateAverage() {

  if(count == 0) {
    averageValue = 0;
    return;
  }

  double average = sum / (double)count;
  averageValue = average;

}

double Metrics::getAverage() {
  return averageValue;
}

double Metrics::getMinValue() {
  return minValue;
}

double Metrics::getMaxValue() {
  return maxValue;
}
