package org.j4di;

import org.j4di.analytical.views.*;
import org.j4di.integration.views.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/OLAP")
public class RESTViewService {

	// --- 1. DATE BRUTE SI INTEGRATE (Integration Layer) ---
	@Autowired private ULTIMATE_REPORT_VIEW_Repository ultimateReportRepository;
	@Autowired private RATINGS_VIEW_Repository ratingsRepository;
	@Autowired private OLAP_DIM_MOVIES_ACTORS_Repository dimMoviesActorsRepository;
	@Autowired private OLAP_DIM_CREW_VOTES_Repository dimCrewVotesRepository;

	@GetMapping(value = "/RAW_ORACLE_REPORT", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<ULTIMATE_REPORT_VIEW> getOracleRaw() { return ultimateReportRepository.get_ULTIMATE_REPORT_VIEW(); }

	@GetMapping(value = "/RAW_POSTGRES_RATINGS", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<RATINGS_VIEW> getPostgresRaw() { return ratingsRepository.get_RATINGS_VIEW(); }

	@GetMapping(value = "/DIM_MOVIES_ACTORS", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<OLAP_DIM_MOVIES_ACTORS> getDimMovies() { return dimMoviesActorsRepository.get_OLAP_DIM_MOVIES_ACTORS(); }

	@GetMapping(value = "/DIM_CREW_VOTES", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<OLAP_DIM_CREW_VOTES> getDimCrew() { return dimCrewVotesRepository.get_OLAP_DIM_CREW_VOTES(); }

	// --- 2. ANALITICA MULTIDIMENSIONALA (Analytical Layer) ---
	@Autowired private OLAP_VIEW_ACTORS_CUBE_Repository actorsCubeRepository;
	@Autowired private OLAP_VIEW_VOTES_ROLLUP_Repository votesRollupRepository;

	@GetMapping(value = "/ANALYTICS_CUBE", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<OLAP_VIEW_ACTORS_CUBE> getCube() { return actorsCubeRepository.get_OLAP_VIEW_ACTORS_CUBE(); }

	@GetMapping(value = "/ANALYTICS_ROLLUP", produces = MediaType.APPLICATION_JSON_VALUE)
	public List<OLAP_VIEW_VOTES_ROLLUP> getRollup() { return votesRollupRepository.get_OLAP_VIEW_VOTES_ROLLUP(); }

	@GetMapping(value = "/ping", produces = MediaType.TEXT_PLAIN_VALUE)
	public String ping() { return "Sistem Federat de Filme Activ!"; }
}