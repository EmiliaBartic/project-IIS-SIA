package org.datasource.jpa.views.analytics;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "V_IOANA_ROLLUP", schema = "FDBO")
@NamedQuery(name = "MovieAnalyticsView.findAll", query = "SELECT a FROM MovieAnalyticsView a")
public class MovieAnalyticsView implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "GENRES")
    private String genres;

    @Column(name = "ACTOR_PROF")
    private String actorProf;

    @Column(name = "VOLUM_PRODUCTII")
    private Long volumProductii;

    @Column(name = "RATING_MEDIU_PIATA")
    private Double ratingMediuPiata;

    @Column(name = "VARF_DE_SUCCES")
    private Double varfDeSucces;
}