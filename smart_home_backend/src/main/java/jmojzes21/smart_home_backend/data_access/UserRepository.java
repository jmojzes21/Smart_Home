package jmojzes21.smart_home_backend.data_access;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IUserRepository;
import jmojzes21.smart_home_backend.dto.UserDTO;
import jmojzes21.smart_home_backend.models.User;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository implements IUserRepository {

  @PersistenceContext
  private EntityManager em;

  @Override
  public List<UserDTO> getUsers() {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(User.class);
    cq.select(cq.from(User.class));
    return em
        .createQuery(cq)
        .getResultList()
        .stream()
        .map(UserDTO::new)
        .toList();
  }

  @Override
  @Transactional
  public void addUser(User user) {
    em.persist(user);
  }

}
