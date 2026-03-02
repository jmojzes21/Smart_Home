package jmojzes21.smart_home_backend.logic;

import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import jmojzes21.smart_home_backend.data_access.AirQualityRepository;
import jmojzes21.smart_home_backend.data_access.DeviceRepository;
import jmojzes21.smart_home_backend.exceptions.AppException;
import jmojzes21.smart_home_backend.exceptions.NotFoundException;
import jmojzes21.smart_home_backend.models.AirQuality;
import jmojzes21.smart_home_backend.models.Device;
import jmojzes21.smart_home_backend.models.DeviceType;
import org.eclipse.microprofile.config.Config;
import org.eclipse.microprofile.config.ConfigProvider;

@ApplicationScoped
public class AirQualityService {

  @Inject
  private AirQualityRepository airQualityRepo;

  @Inject
  private DeviceRepository deviceRepo;

  private int aqHistoryLimit = 1000;

  @PostConstruct
  public void init() {
    Config config = ConfigProvider.getConfig();
    Optional<Integer> aqHistoryLimit = config.getOptionalValue("app.aq_history_limit", Integer.class);
    aqHistoryLimit.ifPresent(value -> this.aqHistoryLimit = value);
  }

  public List<AirQuality> getAirQualityByDevice(UUID deviceUuid, LocalDateTime startTime, LocalDateTime endTime) {
    return airQualityRepo.getByDevice(deviceUuid, startTime, endTime, aqHistoryLimit);
  }

  @Transactional
  public void saveAirQuality(UUID deviceUuid, AirQuality airQuality) {

    Device device = deviceRepo.getDeviceByUuid(deviceUuid);
    if (device == null) {
      throw new NotFoundException("Uređaj ne postoji!");
    }

    if (!device.getType().getKey().equals(DeviceType.AIR_QUALITY)) {
      throw new AppException("Nije moguće spremiti kvalitetu zraka za taj uređaj!");
    }

    airQuality.setDeviceUuid(deviceUuid);
    airQualityRepo.add(airQuality);
    airQualityRepo.flush();
  }

}
