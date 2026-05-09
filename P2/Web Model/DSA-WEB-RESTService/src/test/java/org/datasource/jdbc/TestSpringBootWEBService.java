package org.j4di;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;
import java.util.logging.Logger;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestSpringBootWEBService {
	private static Logger logger = Logger.getLogger(TestSpringBootWEBService.class.getName());
	private static String serviceURL = "http://localhost:8096/DSA-WEB-RESTService/rest/OLAP";
	private RestTemplate restTemplate = new RestTemplate();

	private HttpHeaders getHeaders(String mediaType) {
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.ACCEPT, mediaType);
		headers.setBasicAuth("developer", "iis");
		return headers;
	}

	private void callAndLog(String endpoint, String description, String mediaType) {
		logger.info(">>> TEST: " + description + " [" + serviceURL + endpoint + "]");
		try {
			ResponseEntity<String> response = this.restTemplate.exchange(
					serviceURL + endpoint,
					HttpMethod.GET,
					new HttpEntity<>(null, getHeaders(mediaType)),
					String.class
			);
			logger.info("REZULTAT: " + response.getBody());
		} catch (Exception e) {
			logger.severe("EROARE la " + endpoint + ": " + e.getMessage());
		}
	}

	@Test
	public void test1_PING() {
		callAndLog("/ping", "Verificare stare", MediaType.TEXT_PLAIN_VALUE);
	}

	@Test
	public void test2_DIM_MOVIES_ACTORS() {
		callAndLog("/DIM_MOVIES_ACTORS", "Dimensiune Filme (Oracle) + Actori (Mongo)", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test3_DIM_CREW_VOTES() {
		callAndLog("/DIM_CREW_VOTES", "Dimensiune Echipaj (CSV) + Rating (Postgres)", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test4_CUBE_ANALYSIS() {
		callAndLog("/ANALYTICS_CUBE", "Analiza Multidimensionala CUBE", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test5_ROLLUP_ANALYSIS() {
		callAndLog("/ANALYTICS_ROLLUP", "Analiza Ierarhica ROLLUP", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test6_RAW_ORACLE() {
		callAndLog("/RAW_ORACLE_REPORT", "Date Brute Oracle", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test7_RAW_POSTGRES() {
		callAndLog("/RAW_POSTGRES_RATINGS", "Date Brute Postgres", MediaType.APPLICATION_JSON_VALUE);
	}
}