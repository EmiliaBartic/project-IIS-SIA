package org.j4di.integration.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "OLAP_DIM_CREW_VOTES")
public class OLAP_DIM_CREW_VOTES {
    @Id
    private String movieId;
    private String jobCategory;
    private Double averageRating;
    private Long numVotes;
    private String ratingCategory;
}