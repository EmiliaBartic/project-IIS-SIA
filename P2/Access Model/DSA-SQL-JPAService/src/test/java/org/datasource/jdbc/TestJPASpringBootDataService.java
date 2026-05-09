package org.datasource.jdbc;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestJPASpringBootDataService {
	private static Logger logger = Logger.getLogger(TestJPASpringBootDataService.class.getName());

	private static String serviceURL = "http://localhost:8091/DSA_SQL_JPAService/rest/movies";
	private RestTemplate restTemplate = new RestTemplate();

	// Metoda ajutatoare pentru a nu repeta codul de autentificare la fiecare test
	private HttpHeaders getAuthHeaders() {
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);
		headers.setBasicAuth("developer", "iis");
		return headers;
	}

	@Test
	public void test1_getAllMovies() {
		String restDataEndpoint = serviceURL + "/all";
		logger.info(">>> Testam Endpoint-ul (Spring Data JPA) Toate filmele: " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		logger.info("ResultSet JSON (/all): " + responseEntity.getBody());
	}

	@Test
	public void test2_getMoviesByYear() {
		// Testam pentru anul 1994 (poti schimba cu orice an valid din baza ta de date)
		String restDataEndpoint = serviceURL + "/year/1994";
		logger.info(">>> Testam Endpoint-ul (Filtrare dupa An): " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		logger.info("ResultSet JSON (/year/1994): " + responseEntity.getBody());
	}

	@Test
	public void test3_get_MovieView() {
		String restDataEndpoint = serviceURL + "/MovieView";
		logger.info(">>> Testam Endpoint-ul (JPA Builder): " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		logger.info("ResultSet JSON (/MovieView): " + responseEntity.getBody());
	}

	@Test
	public void test4_get_MovieAnalytics() {
		String restDataEndpoint = serviceURL + "/MovieAnalytics";
		logger.info(">>> Testam Endpoint-ul Analitic (OLAP): " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		logger.info("ResultSet JSON (/MovieAnalytics): " + responseEntity.getBody());
	}

	@Test
	public void test5_get_UltimateReport() {
		String restDataEndpoint = serviceURL + "/UltimateReport";
		logger.info(">>> Testam Endpoint-ul Raportului Integrat: " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		logger.info("ResultSet JSON (/UltimateReport): " + responseEntity.getBody());
	}
}