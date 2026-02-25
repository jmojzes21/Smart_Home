package jmojzes21.smart_home_backend.controllers;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import java.util.List;
import jmojzes21.smart_home_backend.dto.UserCreateDTO;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.logic.UserService;

@Path("/api/users")
public class UserController {

  @Inject
  private UserService userService;

  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public List<UserDTO> getUsers() {
    return userService.getUsers();
  }

  @POST
  @Consumes(MediaType.APPLICATION_JSON)
  public Response createUser(@Valid UserCreateDTO userCreate) {
    userService.addUser(userCreate);
    return Response.status(Status.CREATED).build();
  }

}
