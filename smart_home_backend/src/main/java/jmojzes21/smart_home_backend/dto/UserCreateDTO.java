package jmojzes21.smart_home_backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jmojzes21.smart_home_backend.models.User;

public class UserCreateDTO {

  @JsonProperty("username")
  @NotBlank()
  private String username;

  @JsonProperty("first_name")
  @NotBlank()
  private String firstName;

  @JsonProperty("last_name")
  @NotBlank()
  private String lastName;

  @JsonProperty("password")
  @NotBlank()
  private String password;

  public UserCreateDTO() {}

  public User toUser(String salt, String passwordHash) {
    var user = new User();
    user.setUsername(username.trim());
    user.setFirstName(firstName.trim());
    user.setLastName(lastName.trim());
    user.setSalt(salt);
    user.setPassword(passwordHash);
    return user;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getFirstName() {
    return firstName;
  }

  public void setFirstName(String firstName) {
    this.firstName = firstName;
  }

  public String getLastName() {
    return lastName;
  }

  public void setLastName(String lastName) {
    this.lastName = lastName;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

}
