package jmojzes21.smart_home_backend.data_access.interfaces;

import java.util.List;
import java.util.UUID;
import jmojzes21.smart_home_backend.models.Device;

public interface IDeviceRepository {

  Device getDeviceByUuid(UUID uuid);

  List<Device> getUserDevices(String username);

}
