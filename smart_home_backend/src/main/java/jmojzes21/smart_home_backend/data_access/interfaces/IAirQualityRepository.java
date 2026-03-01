package jmojzes21.smart_home_backend.data_access.interfaces;

import java.util.List;
import jmojzes21.smart_home_backend.models.AirQuality;

public interface IAirQualityRepository {

  List<AirQuality> getByDevice(int deviceId);

  void add(AirQuality airQuality);

  void flush();

}
