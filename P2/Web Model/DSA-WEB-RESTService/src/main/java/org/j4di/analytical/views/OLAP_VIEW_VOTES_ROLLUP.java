package org.j4di.analytical.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "OLAP_VIEW_VOTES_ROLLUP")
public class OLAP_VIEW_VOTES_ROLLUP {
    @Id
    private String jobCategory;
    private String ratingCategory;
    private Long totalVotes;
}