package jmojzes21.smart_home_backend.controllers;

import java.util.List;
import jmojzes21.smart_home_backend.dto.DeviceDTO;
import jmojzes21.smart_home_backend.logic.DeviceService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@RequestMapping("/api/users/{username}/devices")
public class DeviceController {

  private final DeviceService deviceService;

  public DeviceController(DeviceService deviceService) {
    this.deviceService = deviceService;
  }

  @GetMapping()
  public List<DeviceDTO> getDevices(@PathVariable String username) {
    return deviceService.getUserDevices(username);
  }

}
