package jmojzes21.smart_home_backend.config;

import jmojzes21.smart_home_backend.exceptions.AppException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalControllerExceptionHandler {

  @ExceptionHandler({AppException.class, RuntimeException.class})
  public ResponseEntity<String> handleExceptions(Exception e) {
    return ResponseEntity.badRequest().body(e.getMessage());
  }

}
