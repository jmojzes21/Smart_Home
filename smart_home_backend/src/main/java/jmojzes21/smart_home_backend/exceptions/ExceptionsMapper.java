package jmojzes21.smart_home_backend.exceptions;

import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import java.util.Map;

@Provider
@Produces(MediaType.APPLICATION_JSON)
public class ExceptionsMapper implements ExceptionMapper<RuntimeException> {

  @Override
  public Response toResponse(RuntimeException exception) {

    var body = Map.of("msg", exception.getMessage());

    return switch (exception) {
      case NotFoundException ignored -> Response.status(Status.NOT_FOUND).entity(body).build();
      case DuplicateResourceException ignored -> Response.status(Status.CONFLICT).entity(body).build();
      case UnauthorizedException ignored -> Response.status(Status.NOT_FOUND).entity(body).build();
      default -> Response.status(Status.BAD_REQUEST).entity(body).build();
    };
  }

}
