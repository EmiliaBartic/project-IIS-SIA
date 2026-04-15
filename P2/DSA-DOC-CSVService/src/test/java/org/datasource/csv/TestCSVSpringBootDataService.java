package org.datasource.csv;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;
import org.springframework.http.*;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestCSVSpringBootDataService {
    private static Logger logger = Logger.getLogger(TestCSVSpringBootDataService.class.getName());

    // URL-ul de baza pe care l-am setat pentru CSV (pe portul 8097)
    private static String serviceURL = "http://localhost:8097/DSA-DOC-CSVService/rest/crew-data";
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
        logger.info(">>> Testam Endpoint-ul de Ping (CSV): " + restDataEndpoint);

        // Pentru ping, acceptam TEXT_PLAIN
        HttpHeaders textHeaders = new HttpHeaders();
        textHeaders.add(HttpHeaders.ACCEPT, MediaType.TEXT_PLAIN_VALUE);
        textHeaders.setBasicAuth("developer", "iis");

        ResponseEntity<String> responseEntity = this.restTemplate.exchange(
                restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, textHeaders), String.class);

        logger.info("Raspuns Ping: " + responseEntity.getBody());
    }

    @Test
    public void test2_get_CrewView() {
        String restDataEndpoint = serviceURL + "/CrewView";
        logger.info(">>> Testam Endpoint-ul de Date CSV (CrewView): " + restDataEndpoint);

        ResponseEntity<String> responseEntity = this.restTemplate.exchange(
                restDataEndpoint, HttpMethod.GET, new HttpEntity<>(null, getAuthHeaders()), String.class);

        logger.info("ResultSet JSON (/CrewView) primele 500: " + responseEntity.getBody());
    }
}