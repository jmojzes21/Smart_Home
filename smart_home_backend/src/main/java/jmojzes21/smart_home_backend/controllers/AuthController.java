package jmojzes21.smart_home_backend.controllers;

import jakarta.validation.Valid;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.dto.UserLogin;
import jmojzes21.smart_home_backend.logic.AuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private final AuthService authService;

  public AuthController(AuthService authService) {
    this.authService = authService;
  }

  @PostMapping("/user/login")
  public UserDTO userLogin(@RequestBody @Valid UserLogin userLogin) {
    return authService.authenticateUser(userLogin);
  }

}
