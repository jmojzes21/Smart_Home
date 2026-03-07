package jmojzes21.smart_home_backend.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.AttributeOverrides;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "air_quality", schema = "public")
public class AirQuality {
  
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "air_quality_seq")
  @SequenceGenerator(name = "air_quality_seq", sequenceName = "air_quality_id_seq", allocationSize = 1)
  @Column(name = "id")
  @JsonIgnore
  private Long id;

  @Column(name = "time")
  @NotNull
  private LocalDateTime time;

  @Column(name = "device_uuid")
  @JsonIgnore
  private UUID deviceUuid;

  @Embedded
  @AttributeOverrides({
      @AttributeOverride(name = "average", column = @Column(name = "temp_avg")),
      @AttributeOverride(name = "min", column = @Column(name = "temp_min")),
      @AttributeOverride(name = "max", column = @Column(name = "temp_max"))
  })
  @NotNull
  private AqMetrics temperature;

  @Embedded
  @AttributeOverrides({
      @AttributeOverride(name = "average", column = @Column(name = "hum_avg")),
      @AttributeOverride(name = "min", column = @Column(name = "hum_min")),
      @AttributeOverride(name = "max", column = @Column(name = "hum_max"))
  })
  @NotNull
  private AqMetrics humidity;

  @Embedded
  @AttributeOverrides({
      @AttributeOverride(name = "average", column = @Column(name = "press_avg")),
      @AttributeOverride(name = "min", column = @Column(name = "press_min")),
      @AttributeOverride(name = "max", column = @Column(name = "press_max"))
  })
  @NotNull
  private AqMetrics pressure;

  @Embedded
  @AttributeOverrides({
      @AttributeOverride(name = "average", column = @Column(name = "pm25_avg")),
      @AttributeOverride(name = "min", column = @Column(name = "pm25_min")),
      @AttributeOverride(name = "max", column = @Column(name = "pm25_max"))
  })
  @NotNull
  private AqMetrics pm25;

  public AirQuality() {}

  public long getId() {
    return id;
  }

  public void setId(long id) {
    this.id = id;
  }

  public LocalDateTime getTime() {
    return time;
  }

  public void setTime(LocalDateTime time) {
    this.time = time;
  }

  public UUID getDeviceUuid() {
    return deviceUuid;
  }

  public void setDeviceUuid(UUID deviceUuid) {
    this.deviceUuid = deviceUuid;
  }

  public AqMetrics getTemperature() {
    return temperature;
  }

  public void setTemperature(AqMetrics temperature) {
    this.temperature = temperature;
  }

  public AqMetrics getHumidity() {
    return humidity;
  }

  public void setHumidity(AqMetrics humidity) {
    this.humidity = humidity;
  }

  public AqMetrics getPressure() {
    return pressure;
  }

  public void setPressure(AqMetrics pressure) {
    this.pressure = pressure;
  }

  public AqMetrics getPm25() {
    return pm25;
  }

  public void setPm25(AqMetrics pm25) {
    this.pm25 = pm25;
  }

}
