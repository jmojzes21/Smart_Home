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

  @Column(name = "access_key")
  private String accessKey;

  @Column(name = "auth_key")
  private String authKey;

  @Column(name = "auth_salt")
  private String authSalt;

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

  public String getAccessKey() {
    return accessKey;
  }

  public void setAccessKey(String accessKey) {
    this.accessKey = accessKey;
  }

  public String getAuthKey() {
    return authKey;
  }

  public void setAuthKey(String authKey) {
    this.authKey = authKey;
  }

  public String getAuthSalt() {
    return authSalt;
  }

  public void setAuthSalt(String authSalt) {
    this.authSalt = authSalt;
  }
}
