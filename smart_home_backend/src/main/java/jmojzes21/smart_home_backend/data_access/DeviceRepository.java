package jmojzes21.smart_home_backend.data_access;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.UUID;
import jmojzes21.smart_home_backend.data_access.interfaces.IDeviceRepository;
import jmojzes21.smart_home_backend.models.Device;

@ApplicationScoped
public class DeviceRepository implements IDeviceRepository {

  @Inject
  private EntityManager em;

  @Override
  public Device getDeviceByUuid(UUID uuid) {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(Device.class);

    var device = cq.from(Device.class);

    cq.select(device)
        .where(cb.equal(device.get("uuid"), uuid));
    return em
        .createQuery(cq)
        .getSingleResultOrNull();
  }

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
        .getResultList();
  }

}
