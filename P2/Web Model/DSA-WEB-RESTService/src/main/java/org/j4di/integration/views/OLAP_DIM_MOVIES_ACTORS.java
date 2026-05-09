package org.j4di.integration.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "OLAP_DIM_MOVIES_ACTORS")
public class OLAP_DIM_MOVIES_ACTORS {
    @Id
    private String movieTitle;
    private String movieGenres;
    private String actorName;
    private String actorProfession;
    private Double avgRating;
}