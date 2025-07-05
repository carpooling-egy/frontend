package com.example.demo.Services;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Objects;

@Service
public class RouteService {
    private final RestTemplate rest;
    private final String baseUrl;
    private final String accessToken;

    /**
     * Constructor for RouteService.
     * Injects the Mapbox API base URL and access token from application properties.
     *
     * @param baseUrl     The base URL for the Mapbox Directions API.
     * @param accessToken Your Mapbox access token.
     */
    public RouteService(
            @Value("${mapbox.api.base-url}") String baseUrl,
            @Value("${mapbox.api.access-token}") String accessToken
    ) {
        this.rest        = new RestTemplate();
        this.baseUrl     = baseUrl;
        this.accessToken = accessToken;
    }

    /**
     * Returns the travel duration in minutes between two points using the Mapbox Directions API.
     *
     * @param srcLat Latitude of the source point.
     * @param srcLon Longitude of the source point.
     * @param dstLat Latitude of the destination point.
     * @param dstLon Longitude of the destination point.
     * @return The travel time in minutes, based on typical driving conditions.
     */
    public double getTravelTimeMinutes(
            double srcLat, double srcLon,
            double dstLat, double dstLon
    ) {
        // Format the coordinates string as "longitude,latitude;longitude,latitude"
        String coordinates = String.format("%f,%f;%f,%f", srcLon, srcLat, dstLon, dstLat);

        // Build the URL using UriComponentsBuilder for proper encoding and parameter handling.
        String url = UriComponentsBuilder.fromUriString(baseUrl + "/{coordinates}")
                .queryParam("overview", "full")
                .queryParam("geometries", "geojson")
                .queryParam("steps", "true")
                .queryParam("access_token", this.accessToken)
                .buildAndExpand(coordinates)
                .toUriString();

        // Make the GET request to the Mapbox API
        ResponseEntity<JsonNode> resp = rest.getForEntity(url, JsonNode.class);

        // Parse the response to find the duration
        JsonNode body = Objects.requireNonNull(resp.getBody());
        JsonNode routes = body.path("routes");

        // Check if any routes were returned
        if (routes.isMissingNode() || !routes.isArray() || routes.isEmpty()) {
            throw new IllegalStateException("No routes found in Mapbox API response. Check your coordinates.");
        }

        // The duration is provided in seconds in the first route object.
        double durationInSeconds = routes.get(0).path("duration").asDouble();

        // Convert the duration from seconds to minutes and return it.
        return durationInSeconds / 60.0;
    }
}