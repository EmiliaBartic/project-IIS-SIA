package org.datasource.springdata.views;

/**
 * Proiectie pentru raportul integrat final (Federated View).
 * Mapare pe coloanele din MOVIES_FULL_INTEGRATION_V.
 */
public interface MovieFullReportView {
    String getPrimaryTitle();     // Din Oracle
    Integer getStartYear();       // Din Oracle
    String getGenres();
    Double getAverageRating();    // Din Postgres (via DB Link)
    String getDirectors();        // Din CSV (via External Table)
    String getActorName();        // Din MongoDB (via REST)
}