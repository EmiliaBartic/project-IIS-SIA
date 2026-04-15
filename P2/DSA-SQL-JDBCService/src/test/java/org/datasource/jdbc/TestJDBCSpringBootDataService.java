package org.datasource.jdbc;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestJDBCSpringBootDataService {
	private static Logger logger = Logger.getLogger(TestJDBCSpringBootDataService.class.getName());

	// 1. Am actualizat URL-ul sa caute noul tau serviciu de ratings
	private static String serviceURL = "http://localhost:8090/DSA-SQL-JDBCService/rest/ratings-data";
	private RestTemplate restTemplate = new RestTemplate();

	@Test
	public void test1_get_RatingView() {
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);

		// Autentificarea ramane aceeasi (cea din application.properties)
		headers.setBasicAuth("developer", "iis");

		// 2. Apelam endpoint-ul creat de noi
		String restDataEndpoint = serviceURL + "/RatingView";
		logger.info(">>> Testam Endpoint-ul: " + restDataEndpoint);

		try {
			ResponseEntity<String> responseEntity = this.restTemplate.exchange(
					restDataEndpoint,
					HttpMethod.GET,
					new HttpEntity<>(null, headers),
					String.class
			);

			logger.info("Succes! JSON-ul returnat este: " + responseEntity.getBody());
		} catch (Exception e) {
			logger.severe("Eroare la apelarea serviciului: " + e.getMessage());
		}
	}
}