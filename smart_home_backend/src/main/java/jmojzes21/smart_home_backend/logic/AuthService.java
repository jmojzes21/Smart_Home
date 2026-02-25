package jmojzes21.smart_home_backend.logic;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import jmojzes21.smart_home_backend.data_access.UserRepository;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.dto.UserLogin;
import jmojzes21.smart_home_backend.exceptions.UnauthorizedException;
import jmojzes21.smart_home_backend.models.User;

@ApplicationScoped
public class AuthService {

  @Inject
  private UserRepository userRepository;

  public UserDTO authenticateUser(UserLogin userLogin) {

    String username = userLogin.getUsername().trim();
    String password = userLogin.getPassword().trim();

    User user = userRepository.getUser(username);
    if (user == null) {
      throw new UnauthorizedException("Podaci za prijavu nisu točni!");
    }

    var cryptoService = new CryptoService();

    byte[] passwordRaw = password.getBytes(StandardCharsets.UTF_8);
    byte[] saltBytes = Base64.getDecoder().decode(user.getSalt());
    byte[] passwordHashBytes = cryptoService.getSha256Hmac(saltBytes, passwordRaw);

    String passwordHash = Base64.getEncoder().encodeToString(passwordHashBytes);

    if (!passwordHash.equals(user.getPassword())) {
      throw new UnauthorizedException("Podaci za prijavu nisu točni!");
    }

    return new UserDTO(user);
  }

}
