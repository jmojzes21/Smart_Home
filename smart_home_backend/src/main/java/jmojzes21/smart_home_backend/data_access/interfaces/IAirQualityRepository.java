package jmojzes21.smart_home_backend.data_access.interfaces;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import jmojzes21.smart_home_backend.models.AirQuality;

public interface IAirQualityRepository {

  List<AirQuality> getByDevice(UUID deviceUuid, LocalDateTime startTime, LocalDateTime endTime, int limit);
  
  void add(AirQuality airQuality);

  void flush();

}
