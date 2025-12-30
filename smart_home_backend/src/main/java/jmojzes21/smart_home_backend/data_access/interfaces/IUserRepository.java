package jmojzes21.smart_home_backend.data_access.interfaces;

import java.util.List;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.models.User;

public interface IUserRepository {

  List<UserDTO> getUsers();

  void addUser(User user);

}
