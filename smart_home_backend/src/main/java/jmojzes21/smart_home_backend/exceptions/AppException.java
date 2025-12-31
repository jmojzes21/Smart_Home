package jmojzes21.smart_home_backend.exceptions;

import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

public class AppException extends ResponseStatusException {

  public AppException(String message) {
    super(HttpStatus.BAD_REQUEST, message);
  }

}
