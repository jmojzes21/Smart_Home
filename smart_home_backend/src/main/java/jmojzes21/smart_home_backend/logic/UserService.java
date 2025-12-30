package jmojzes21.smart_home_backend.logic;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IUserRepository;
import jmojzes21.smart_home_backend.dto.UserCreateDTO;
import jmojzes21.smart_home_backend.dto.UserDTO;
import org.springframework.stereotype.Service;

@Service
public class UserService {

  private final IUserRepository userRepository;

  public UserService(IUserRepository userRepository) {
    this.userRepository = userRepository;
  }

  public List<UserDTO> getUsers() {
    return userRepository.getUsers();
  }

  public void addUser(UserCreateDTO userCreate) {

    var cryptoService = new CryptoService();

    byte[] passwordRaw = userCreate.getPassword().trim().getBytes(StandardCharsets.UTF_8);

    byte[] saltBytes = cryptoService.getRandomBytes(32);
    byte[] passwordHashBytes = cryptoService.getSha256Hmac(saltBytes, passwordRaw);

    String salt = getBase64(saltBytes);
    String passwordHash = getBase64(passwordHashBytes);

    var user = userCreate.toUser(salt, passwordHash);
    userRepository.addUser(user);
  }

  private String getBase64(byte[] input) {
    return Base64.getEncoder().encodeToString(input);
  }

}
