package jmojzes21.smart_home_backend.logic;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import jmojzes21.smart_home_backend.data_access.interfaces.IUserRepository;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.dto.UserLogin;
import jmojzes21.smart_home_backend.models.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

  private final IUserRepository userRepository;

  public AuthService(IUserRepository userRepository) {
    this.userRepository = userRepository;
  }

  public UserDTO authenticateUser(UserLogin userLogin) {

    String username = userLogin.getUsername().trim();
    String password = userLogin.getPassword().trim();

    User user = userRepository.getUser(username);
    if (user == null) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
    }

    var cryptoService = new CryptoService();

    byte[] passwordRaw = password.getBytes(StandardCharsets.UTF_8);
    byte[] saltBytes = Base64.getDecoder().decode(user.getSalt());
    byte[] passwordHashBytes = cryptoService.getSha256Hmac(saltBytes, passwordRaw);

    String passwordHash = Base64.getEncoder().encodeToString(passwordHashBytes);

    if (!passwordHash.equals(user.getPassword())) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
    }

    return new UserDTO(user);
  }

}
