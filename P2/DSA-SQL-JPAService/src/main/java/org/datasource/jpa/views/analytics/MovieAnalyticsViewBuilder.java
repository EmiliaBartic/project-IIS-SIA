package org.datasource.jpa.views.analytics;

import org.datasource.jpa.JPADataSourceConnector;
import org.springframework.stereotype.Service;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Service
public class MovieAnalyticsViewBuilder {

    protected String JPQL_SELECT = "SELECT NEW org.datasource.jpa.views.analytics.MovieAnalyticsView(" +
            "a.genres, a.actorProf, a.volumProductii, a.ratingMediuPiata, a.varfDeSucces) " +
            "FROM MovieAnalyticsView a";

    protected List<MovieAnalyticsView> analyticsList = new ArrayList<>();
    protected JPADataSourceConnector dataSourceConnector;

    public MovieAnalyticsViewBuilder(JPADataSourceConnector dataSourceConnector) {
        this.dataSourceConnector = dataSourceConnector;
    }

    public List<MovieAnalyticsView> getAnalyticsList() {
        return analyticsList;
    }

    public MovieAnalyticsViewBuilder build() {
        EntityManager em = dataSourceConnector.getEntityManager();
        this.analyticsList = em.createQuery(JPQL_SELECT, MovieAnalyticsView.class).getResultList();
        return this;
    }
}