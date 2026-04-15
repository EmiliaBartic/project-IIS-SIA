package org.datasource.csv.crew;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor(force = true)
public class CrewView {
	private String tconst;
	private String category;
	private String job;
	private String characters;
}