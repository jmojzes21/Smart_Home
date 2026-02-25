package jmojzes21.smart_home_backend.controllers;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;
import jmojzes21.smart_home_backend.dto.DeviceDTO;
import jmojzes21.smart_home_backend.logic.DeviceService;

@Path("/api/users/{username}/devices")
public class DeviceController {

  @Inject
  private DeviceService deviceService;

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public List<DeviceDTO> getDevices(@PathParam("username") String username) {
    return deviceService.getUserDevices(username);
  }

}
