package org.j4di.integration.views;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

@Getter
@Entity
@Immutable
@Table(name = "ultimate_report_view_rest")
public class ULTIMATE_REPORT_VIEW {
    @Id
    private String primaryTitle; // Folosim titlul ca ID pentru JPA
    private String genres;
    private Double averageRating;
    private String directors;
    private String actorName;
}