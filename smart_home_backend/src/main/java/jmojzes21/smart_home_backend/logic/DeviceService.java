package jmojzes21.smart_home_backend.logic;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.DeviceRepository;
import jmojzes21.smart_home_backend.dto.DeviceDTO;

@ApplicationScoped
public class DeviceService {

  @Inject
  private DeviceRepository deviceRepository;

  public List<DeviceDTO> getUserDevices(String username) {
    return deviceRepository.getUserDevices(username).stream()
        .map(DeviceDTO::new)
        .toList();
  }

}
