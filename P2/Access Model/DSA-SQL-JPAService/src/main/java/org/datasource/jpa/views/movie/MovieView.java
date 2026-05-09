package org.datasource.jpa.views.movie;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Data;
import jakarta.persistence.*;
import java.io.Serializable;

/**
 * The persistent class for the MOVIES_V database table/view.
 * Mapare realizată conform structurii DS_1 (Oracle).
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name="MOVIES_V")
@NamedQuery(name="MovieView.findAll", query="SELECT m FROM MovieView m")
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