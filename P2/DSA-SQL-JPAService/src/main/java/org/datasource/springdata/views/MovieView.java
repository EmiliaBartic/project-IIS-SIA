package org.datasource.springdata.views;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import java.io.Serializable;

@Entity(name = "SpringDataMovieView")
@Table(name="MOVIES_V", schema="FDBO")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class MovieView implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name="TCONST")
    private String tconst;

    @Column(name="PRIMARYTITLE")
    private String primaryTitle;

    @Column(name="STARTYEAR")
    private Integer startYear;

    @Column(name="RUNTIMEMINUTES")
    private Integer runtimeMinutes;

    @Column(name="GENRES")
    private String genres;
}