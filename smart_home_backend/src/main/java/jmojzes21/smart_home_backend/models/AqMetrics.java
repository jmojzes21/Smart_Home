package jmojzes21.smart_home_backend.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Embeddable;

@Embeddable
public class AqMetrics {

  @JsonProperty("average")
  private double average;

  @JsonProperty("min")
  private double min;

  @JsonProperty("max")
  private double max;

  public AqMetrics() {}

  public AqMetrics(double average, double min, double max) {
    this.average = average;
    this.min = min;
    this.max = max;
  }

  public double getAverage() {
    return average;
  }

  public void setAverage(double average) {
    this.average = average;
  }

  public double getMin() {
    return min;
  }

  public void setMin(double min) {
    this.min = min;
  }

  public double getMax() {
    return max;
  }

  public void setMax(double max) {
    this.max = max;
  }

}
