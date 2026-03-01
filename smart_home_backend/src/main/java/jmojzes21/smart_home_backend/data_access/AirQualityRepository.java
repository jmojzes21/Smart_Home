package jmojzes21.smart_home_backend.data_access;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;
import jmojzes21.smart_home_backend.data_access.interfaces.IAirQualityRepository;
import jmojzes21.smart_home_backend.models.AirQuality;

@ApplicationScoped
public class AirQualityRepository implements IAirQualityRepository {

  @Inject
  private EntityManager em;

  @Override
  public List<AirQuality> getByDevice(int deviceId) {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(AirQuality.class);

    var aq = cq.from(AirQuality.class);

    cq.select(cq.from(AirQuality.class))
        .where(cb.equal(aq.get("deviceId"), deviceId));

    return em
        .createQuery(cq)
        .getResultList();
  }

  @Override
  public void add(AirQuality airQuality) {
    em.persist(airQuality);
  }

  @Override
  public void flush() {
    em.flush();
  }
}
