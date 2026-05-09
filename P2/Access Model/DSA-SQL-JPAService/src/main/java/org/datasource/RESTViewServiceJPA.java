package org.datasource;

import org.datasource.jpa.views.movie.MovieViewBuilder;
import org.datasource.jpa.views.analytics.MovieAnalyticsViewBuilder;
import org.datasource.jpa.views.analytics.MovieAnalyticsView;
import org.datasource.springdata.views.MovieView;
import org.datasource.springdata.views.MovieViewRepository;
import org.datasource.springdata.views.MovieFullReportView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/movies")
public class RESTViewServiceJPA {
	private static Logger logger = Logger.getLogger(RESTViewServiceJPA.class.getName());

	@Autowired private MovieViewRepository movieRepository;
	@Autowired private MovieViewBuilder movieViewBuilder;
	@Autowired private MovieAnalyticsViewBuilder analyticsBuilder;

	// 1. Endpoint pentru verificarea starii serviciului
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/ping
	@RequestMapping(value = "/ping", method = RequestMethod.GET,
			produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String pingDataSource() {
		logger.info(">>>> DSA-SQL-JPAService:: RESTViewService is Up!");
		return "Ping response from Movie Data Service!";
	}

	// 2. Endpoint care foloseste Repository (Spring Data JPA) pentru toate filmele
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/all
	@RequestMapping(value = "/all", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<MovieView> getAllMovies() {
		logger.info("Servire date brute via MovieViewRepository...");
		return movieRepository.findAll();
	}

	// 3. Endpoint pentru filtrare dupa an folosind Query Methods din Repository
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/year/1994
	@RequestMapping(value = "/year/{year}", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<MovieView> getMoviesByYear(@PathVariable Integer year) {
		return movieRepository.findByStartYear(year);
	}

	// 4. Endpoint care foloseste Manual Builder pentru MovieView
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/MovieView
	@RequestMapping(value = "/MovieView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<org.datasource.jpa.views.movie.MovieView> get_MovieView() {
		return this.movieViewBuilder.build().getMovieViewList();
	}

	// 5. Endpoint pentru Analitica OLAP (V_IOANA_ROLLUP)
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/MovieAnalytics
	@RequestMapping(value = "/MovieAnalytics", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<MovieAnalyticsView> get_MovieAnalytics() {
		return this.analyticsBuilder.build().getAnalyticsList();
	}

	// 6. Endpoint pentru Raportul Integrat Final (Federated View)
	// Test URL: http://localhost:8091/DSA_SQL_JPAService/rest/movies/UltimateReport
	@RequestMapping(value = "/UltimateReport", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<MovieFullReportView> get_UltimateReport() {
		logger.info("Generare raport integrat final din multiple surse...");

		return this.movieRepository.getUltimateReport();
	}
}