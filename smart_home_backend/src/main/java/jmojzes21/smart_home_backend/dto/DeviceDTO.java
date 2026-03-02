package jmojzes21.smart_home_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;
import jmojzes21.smart_home_backend.models.Device;

public class DeviceDTO {

  @JsonProperty("hostname")
  private String hostname;

  @JsonProperty("uuid")
  private UUID uuid;

  @JsonProperty("name")
  private String name;

  @JsonProperty("type")
  private String type;

  public DeviceDTO(Device device) {
    this.hostname = device.getHostname();
    this.uuid = device.getUuid();
    this.name = device.getName();
    this.type = device.getType().getKey();
  }

  public String getHostname() {
    return hostname;
  }

  public UUID getUuid() {
    return uuid;
  }

  public String getName() {
    return name;
  }

  public String getType() {
    return type;
  }

}
