package org.j4di.analytical.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "OLAP_VIEW_ACTORS_CUBE")
public class OLAP_VIEW_ACTORS_CUBE {
    @Id
    private String movieGenres;
    private String actorProfession;
    private Double ratingMediu;
    private Long numarFilme;
}