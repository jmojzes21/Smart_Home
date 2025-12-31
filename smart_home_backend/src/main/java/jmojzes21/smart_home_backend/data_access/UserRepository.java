package jmojzes21.smart_home_backend.data_access;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IUserRepository;
import jmojzes21.smart_home_backend.models.User;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository implements IUserRepository {

  @PersistenceContext
  private EntityManager em;

  @Override
  public List<User> getUsers() {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(User.class);
    cq.select(cq.from(User.class));
    return em
        .createQuery(cq)
        .getResultList();
  }

  public User getUser(String username) {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(User.class);
    var user = cq.from(User.class);
    cq.select(user)
        .where(cb.equal(user.get("username"), username));
    return em
        .createQuery(cq)
        .getSingleResultOrNull();
  }

  @Override
  @Transactional
  public void addUser(User user) {
    em.persist(user);
  }

}
