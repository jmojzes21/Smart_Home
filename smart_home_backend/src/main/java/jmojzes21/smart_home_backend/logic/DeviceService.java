package jmojzes21.smart_home_backend.logic;

import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IDeviceRepository;
import jmojzes21.smart_home_backend.dto.DeviceDTO;
import org.springframework.stereotype.Service;

@Service
public class DeviceService {

  private final IDeviceRepository deviceRepository;

  public DeviceService(IDeviceRepository deviceRepository) {
    this.deviceRepository = deviceRepository;
  }

  public List<DeviceDTO> getUserDevices(String username) {
    return deviceRepository.getUserDevices(username).stream()
        .map(DeviceDTO::new)
        .toList();
  }

}
