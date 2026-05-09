package org.datasource.jdbc;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestMongoSpringBootDataService {
	private static Logger logger = Logger.getLogger(TestMongoSpringBootDataService.class.getName());

	// URL-ul de baza pe care l-am setat pentru MongoDB (pe portul 8093)
	private static String serviceURL = "http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data";
	private RestTemplate restTemplate = new RestTemplate();

	// Setam header-ele pentru a accepta JSON si adaugam autentificarea
	private HttpHeaders getAuthHeaders() {
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);
		headers.setBasicAuth("developer", "iis");
		return headers;
	}

	@Test
	public void test1_ping() {
		String restDataEndpoint = serviceURL + "/ping";
		logger.info(">>> Testam Endpoint-ul de Ping (MongoDB): " + restDataEndpoint);

		// Cream headere specifice care accepta TEXT simplu, nu JSON
		HttpHeaders textHeaders = new HttpHeaders();
		textHeaders.add(HttpHeaders.ACCEPT, MediaType.TEXT_PLAIN_VALUE);
		textHeaders.setBasicAuth("developer", "iis");

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, textHeaders), String.class);

		logger.info("Raspuns Ping: " + responseEntity.getBody());
	}

	@Test
	public void test2_get_ActorView() {
		String restDataEndpoint = serviceURL + "/ActorView";
		logger.info(">>> Testam Endpoint-ul de Date (ActorView): " + restDataEndpoint);

		ResponseEntity<String> responseEntity = this.restTemplate.exchange(
				restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

		// ATENTIE: Daca ai 10.000 de actori, acest log va fi urias in consola!
		logger.info("ResultSet JSON (/ActorView): " + responseEntity.getBody());
	}
}