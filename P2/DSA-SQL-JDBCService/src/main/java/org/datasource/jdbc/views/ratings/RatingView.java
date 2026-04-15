package org.datasource.jdbc.views.ratings;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;


@Data
@AllArgsConstructor
@NoArgsConstructor(force = true)
public class RatingView implements Serializable {
    private static final long serialVersionUID = 1L;

    private String tconst;
    private Double averageRating;
    private Integer numVotes;
}