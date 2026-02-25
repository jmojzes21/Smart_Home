package jmojzes21.smart_home_backend.data_access.interfaces;

import java.util.List;
import jmojzes21.smart_home_backend.models.User;

public interface IUserRepository {

  List<User> getUsers();

  User getUser(String username);

  void addUser(User user);

  void flush();

}
