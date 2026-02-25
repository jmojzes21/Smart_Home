package jmojzes21.smart_home_backend.data_access;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IUserRepository;
import jmojzes21.smart_home_backend.models.User;

@ApplicationScoped
public class UserRepository implements IUserRepository {

  @Inject
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

  @Override
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
  public void addUser(User user) {
    em.persist(user);
  }

  public void flush() {
    em.flush();
  }
  
}
