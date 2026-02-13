package jmojzes21.smart_home_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jmojzes21.smart_home_backend.models.Device;

public class DeviceDTO {

  @JsonProperty("hostname")
  private String hostname;

  @JsonProperty("name")
  private String name;

  @JsonProperty("type")
  private String type;
  
  public DeviceDTO(Device device) {
    this.hostname = device.getHostname();
    this.name = device.getName();
    this.type = device.getType().getKey();
  }

  public String getHostname() {
    return hostname;
  }

  public String getName() {
    return name;
  }

  public String getType() {
    return type;
  }

}
