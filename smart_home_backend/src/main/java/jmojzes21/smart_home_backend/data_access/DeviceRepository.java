package jmojzes21.smart_home_backend.data_access;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IDeviceRepository;
import jmojzes21.smart_home_backend.models.Device;
import org.springframework.stereotype.Repository;

@Repository
public class DeviceRepository implements IDeviceRepository {

  @PersistenceContext
  private EntityManager em;

  @Override
  public List<Device> getUserDevices(String username) {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(Device.class);

    var device = cq.from(Device.class);
    var user = device.join("user");

    cq.select(device)
        .where(cb.equal(user.get("username"), username));
    return em
        .createQuery(cq)
        .getResultList()
        .stream()
        .toList();
  }

}
