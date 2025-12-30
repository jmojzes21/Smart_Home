package jmojzes21.smart_home_backend.data_access.interfaces;

import java.util.List;
import jmojzes21.smart_home_backend.models.Device;

public interface IDeviceRepository {

  List<Device> getUserDevices(String username);

}
