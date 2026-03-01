package jmojzes21.smart_home_backend.logic;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.AirQualityRepository;
import jmojzes21.smart_home_backend.models.AirQuality;

@ApplicationScoped
public class AirQualityService {

  @Inject
  private AirQualityRepository airQualityRepo;

  public List<AirQuality> getAirQualityByDevice(int deviceId) {
    return airQualityRepo.getByDevice(deviceId);
  }

  @Transactional
  public void saveAirQuality(int deviceId, AirQuality airQuality) {
    airQuality.setDeviceId(deviceId);

    airQualityRepo.add(airQuality);
    airQualityRepo.flush();
  }

}
