package jmojzes21.smart_home_backend.logic;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.PersistenceException;
import jakarta.transaction.Transactional;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.UserRepository;
import jmojzes21.smart_home_backend.dto.UserCreateDTO;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.exceptions.DuplicateResourceException;

@ApplicationScoped
public class UserService {

  @Inject
  private UserRepository userRepository;

  @Inject
  private CryptoService cryptoService;

  public List<UserDTO> getUsers() {
    return userRepository.getUsers().stream().map(UserDTO::new).toList();
  }

  @Transactional
  public void addUser(UserCreateDTO userCreate) {

    byte[] passwordRaw = userCreate.getPassword().trim().getBytes(StandardCharsets.UTF_8);

    byte[] saltBytes = cryptoService.getRandomBytes(32);
    byte[] passwordHashBytes = cryptoService.getSha256Hmac(saltBytes, passwordRaw);

    String salt = getBase64(saltBytes);
    String passwordHash = getBase64(passwordHashBytes);

    var user = userCreate.toUser(salt, passwordHash);

    try {
      userRepository.addUser(user);
      userRepository.flush();
    } catch (PersistenceException e) {
      throw new DuplicateResourceException(String.format("Korisnik %s već postoji!", user.getUsername()));
    }
  }

  private String getBase64(byte[] input) {
    return Base64.getEncoder().encodeToString(input);
  }

}
