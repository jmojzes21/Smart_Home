package jmojzes21.smart_home_backend.controllers;

import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;
import java.util.List;
import jmojzes21.smart_home_backend.logic.AirQualityService;
import jmojzes21.smart_home_backend.models.AirQuality;

@Path("/api/air_quality")
public class AirQualityController {

  @Inject
  private AirQualityService airQualityService;

  @GET
  @Path("/device/{device_id}")
  @Produces(MediaType.APPLICATION_JSON)
  public List<AirQuality> getByDevice(@PathParam("device_id") int deviceId) {
    return airQualityService.getAirQualityByDevice(deviceId);
  }

  @POST
  @Path("/device/{device_id}")
  @Consumes(MediaType.APPLICATION_JSON)
  public Response add(@PathParam("device_id") int deviceId, @Valid AirQuality aq) {
    airQualityService.saveAirQuality(deviceId, aq);
    return Response.status(Status.CREATED).build();
  }

}
