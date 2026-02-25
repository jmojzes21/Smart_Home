package jmojzes21.smart_home_backend.controllers;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.dto.UserLogin;
import jmojzes21.smart_home_backend.logic.AuthService;

@Path("/api/auth")
public class AuthController {

  @Inject
  private AuthService authService;

  @POST
  @Path("/user/login")
  @Consumes(MediaType.APPLICATION_JSON)
  @Produces(MediaType.APPLICATION_JSON)
  public UserDTO userLogin(@Valid UserLogin userLogin) {
    return authService.authenticateUser(userLogin);
  }

}
