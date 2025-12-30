package jmojzes21.smart_home_backend.controllers;

import jakarta.validation.Valid;
import java.util.List;
import jmojzes21.smart_home_backend.dto.UserCreateDTO;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.logic.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@RequestMapping("/api/users")
public class UserController {

  private final UserService userService;

  public UserController(UserService userService) {
    this.userService = userService;
  }

  @GetMapping()
  public List<UserDTO> getUsers() {
    return userService.getUsers();
  }

  @PostMapping()
  public void createUser(@RequestBody @Valid UserCreateDTO userCreate) {
    userService.addUser(userCreate);
  }

}
