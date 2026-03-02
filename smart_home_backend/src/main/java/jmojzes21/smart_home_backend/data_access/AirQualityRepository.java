package jmojzes21.smart_home_backend.data_access;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.Predicate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import jmojzes21.smart_home_backend.data_access.interfaces.IAirQualityRepository;
import jmojzes21.smart_home_backend.models.AirQuality;

@ApplicationScoped
public class AirQualityRepository implements IAirQualityRepository {

  @Inject
  private EntityManager em;

  @Override
  public List<AirQuality> getByDevice(UUID deviceUuid, LocalDateTime startTime, LocalDateTime endTime, int limit) {
    var cb = em.getCriteriaBuilder();
    var cq = cb.createQuery(AirQuality.class);

    var aq = cq.from(AirQuality.class);

    var filters = new ArrayList<Predicate>(3);
    filters.add(cb.equal(aq.get("deviceUuid"), deviceUuid));

    if (startTime != null) {
      filters.add(cb.greaterThanOrEqualTo(aq.get("time"), startTime));
    }

    if (endTime != null) {
      filters.add(cb.lessThanOrEqualTo(aq.get("time"), endTime));
    }

    cq.select(aq)
        .where(cb.and(filters));

    return em
        .createQuery(cq)
        .setMaxResults(limit)
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
