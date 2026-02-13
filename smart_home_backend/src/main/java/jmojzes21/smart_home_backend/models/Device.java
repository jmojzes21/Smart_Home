package jmojzes21.smart_home_backend.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "device", schema = "public")
public class Device {

  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private Integer id;

  @JoinColumn(name = "user_id")
  @ManyToOne
  private User user;

  @Column(name = "hostname")
  private String hostname;

  @Column(name = "name")
  private String name;

  @JoinColumn(name = "type_id")
  @ManyToOne
  private DeviceType type;

  @Column(name = "secret_key")
  private String secretKey;

  public Device() {}

  public Integer getId() {
    return id;
  }

  public void setId(Integer id) {
    this.id = id;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public String getHostname() {
    return hostname;
  }

  public void setHostname(String hostname) {
    this.hostname = hostname;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public DeviceType getType() {
    return type;
  }

  public void setType(DeviceType type) {
    this.type = type;
  }

  public String getSecretKey() {
    return secretKey;
  }

  public void setSecretKey(String secretKey) {
    this.secretKey = secretKey;
  }
  
}
