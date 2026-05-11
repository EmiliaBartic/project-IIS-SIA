package org.datasource.jdbc;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

import static org.junit.Assert.*;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestSpringBootWEBService {
	private static final Logger logger = Logger.getLogger(TestSpringBootWEBService.class.getName());
	private static final String serviceURL = "http://localhost:8096/DSA-WEB-RESTService/rest/OLAP";

	private final RestTemplate restTemplate = new RestTemplate();
	private final ObjectMapper objectMapper = new ObjectMapper();

	private HttpHeaders getHeaders(String mediaType, String username, String password) {
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.ACCEPT, mediaType);
		headers.setBasicAuth(username, password);
		return headers;
	}

	private void executeAndValidate(String endpoint, String description, String mediaType) {
		logger.info("\n================================================================================");
		logger.info(">>> TEST: " + description + " | URL: " + serviceURL + endpoint);

		long startTime = System.currentTimeMillis();

		try {
			ResponseEntity<String> response = this.restTemplate.exchange(
					serviceURL + endpoint,
					HttpMethod.GET,
					new HttpEntity<>(null, getHeaders(mediaType, "developer", "iis")),
					String.class
			);

			long duration = System.currentTimeMillis() - startTime;

			// 1. ASERTIUNE: Verificam daca serverul a raspuns cu 200 OK
			assertEquals("Eroare! Statusul HTTP nu este 200 OK", HttpStatus.OK, response.getStatusCode());
			assertNotNull("Raspunsul (body) este NULL!", response.getBody());

			logger.info("STATUS HTTP: " + response.getStatusCode() + " (Timp executie: " + duration + " ms)");

			// 2. VALIDARE JSON SI AFISARE
			if (mediaType.equals(MediaType.APPLICATION_JSON_VALUE)) {
				JsonNode jsonNode = objectMapper.readTree(response.getBody());

				assertTrue("Raspunsul nu este un array JSON valid!", jsonNode.isArray());
				assertTrue("Array-ul JSON este gol! Nu s-au gasit date.", jsonNode.size() > 0);

				logger.info("NUMAR INREGISTRARI RETURNATE: " + jsonNode.size());

				// Extragem primele 2 randuri intr-un mini-array pentru o afisare curata
				ArrayNode sampleArray = objectMapper.createArrayNode();
				sampleArray.add(jsonNode.get(0));
				if (jsonNode.size() > 1) {
					sampleArray.add(jsonNode.get(1));
				}

				// Folosim System.out pentru a forta printarea corecta multiline
				System.out.println("ESANTION DATE (primele rezultate):");
				System.out.println(objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(sampleArray));
				System.out.println("... (restul datelor omise) ...\n");

			} else {
				logger.info("REZULTAT TEXT: " + response.getBody());
				assertTrue("Raspunsul Ping e invalid", response.getBody().contains("Activ") || response.getBody().contains("Ping"));
			}

		} catch (Exception e) {
			logger.severe("TEST ESUAT la " + endpoint + ": " + e.getMessage());
			fail("Eroare neasteptata in timpul testului: " + e.getMessage());
		}
	}

	// ==========================================
	// SUITA DE TESTE
	// ==========================================

	@Test
	public void test1_PING() {
		executeAndValidate("/ping", "Verificare stare sistem", MediaType.TEXT_PLAIN_VALUE);
	}

	@Test
	public void test2_DIM_MOVIES_ACTORS() {
		executeAndValidate("/DIM_MOVIES_ACTORS", "Dimensiune Federata: Filme + Actori", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test3_DIM_CREW_VOTES() {
		executeAndValidate("/DIM_CREW_VOTES", "Dimensiune Federata: Echipaj + Rating", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test4_CUBE_ANALYSIS() {
		executeAndValidate("/ANALYTICS_CUBE", "Cub OLAP Multidimensional", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test5_ROLLUP_ANALYSIS() {
		executeAndValidate("/ANALYTICS_ROLLUP", "Ierarhie OLAP ROLLUP", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test6_RAW_ORACLE() {
		executeAndValidate("/RAW_ORACLE_REPORT", "Date Brute Oracle", MediaType.APPLICATION_JSON_VALUE);
	}

	@Test
	public void test7_RAW_POSTGRES() {
		executeAndValidate("/RAW_POSTGRES_RATINGS", "Date Brute Postgres", MediaType.APPLICATION_JSON_VALUE);
	}

	// ==========================================
	// TESTE NEGATIVE (SECURITATE)
	// ==========================================

	@Test
	public void test8_SECURITY_UNAUTHORIZED() {
		logger.info("\n================================================================================");
		logger.info(">>> TEST SECURITATE: Verificare respingere credentiale gresite");
		try {
			this.restTemplate.exchange(
					serviceURL + "/ANALYTICS_CUBE",
					HttpMethod.GET,
					new HttpEntity<>(null, getHeaders(MediaType.APPLICATION_JSON_VALUE, "hacker", "parolagresita")),
					String.class
			);
			fail("Testul trebuia sa pice! Securitatea este compromisa, a permis accesul.");
		} catch (HttpClientErrorException e) {
			assertEquals(HttpStatus.UNAUTHORIZED, e.getStatusCode());
			logger.info("SUCCES: Sistemul a blocat atacatorul cu eroarea: " + e.getStatusCode());
		}
	}
}