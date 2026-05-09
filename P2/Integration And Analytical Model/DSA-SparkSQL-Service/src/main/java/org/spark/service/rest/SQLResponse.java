package org.spark.service.rest;

public record SQLResponse(
        String query,
        String response
) {}
