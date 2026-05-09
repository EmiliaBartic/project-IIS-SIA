package org.j4di.integration.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "ratings_view_rest")
public class RATINGS_VIEW {
    @Id
    private String tconst;
    private Double averageRating;
    private Integer numVotes;
}