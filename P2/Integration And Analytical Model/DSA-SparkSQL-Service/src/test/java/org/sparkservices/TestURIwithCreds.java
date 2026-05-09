package org.sparkservices;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.spark.service.rest.QueryRESTDataService;

public class TestURIwithCreds {

    @Test
    public void testValidUrlWithCredentials() {
        String urlString = "http://developer:iis@localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/RatingView";

        // 1. Extragem datele folosind metoda din service
        String[] credentials = QueryRESTDataService.parseCredentials(urlString);

        // 2. Verificam exactitatea datelor extrase
        Assertions.assertNotNull(credentials, "Credentialele nu ar trebui sa fie null pentru acest URL");
        Assertions.assertEquals(2, credentials.length, "Trebuie extrase exact 2 elemente (user si parola)");
        Assertions.assertEquals("developer", credentials[0], "Userul extras este incorect");
        Assertions.assertEquals("iis", credentials[1], "Parola extrasa este incorecta");

        // 3. Verificam ca URL-ul este curatat corect pentru a nu da eroare la conectare
        String cleanUrl = urlString.replace(credentials[0] + ":" + credentials[1] + "@", "");
        String expectedUrl = "http://localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/RatingView";

        Assertions.assertEquals(expectedUrl, cleanUrl, "URL-ul curatat nu corespunde cu structura asteptata");
    }

    @Test
    public void testUrlWithoutCredentials() {
        // Un URL obisnuit, asa cum ai la MongoDB
        String urlString = "http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data/ActorView";

        String[] credentials = QueryRESTDataService.parseCredentials(urlString);

        // Metoda trebuie sa recunoasca lipsa parolei si sa returneze null in mod controlat
        Assertions.assertNull(credentials, "Pentru un URL fara date de logare, metoda trebuie sa returneze null");
    }

    @Test
    public void testInvalidUrlThrowsException() {
        // Un URL nu are voie sa contina spatii necodate (ca %20) in interiorul lui.
        // Asta va forta clasa java.net.URI sa arunce o exceptie de sintaxa (URISyntaxException).
        String urlInvalid = "http://developer:iis@local host:8090/API";

        // Aici verificam arhitectura defensiva: aplicatia trebuie sa opreasca executia cand primeste date gresite
        RuntimeException exception = Assertions.assertThrows(
                RuntimeException.class,
                () -> QueryRESTDataService.parseCredentials(urlInvalid),
                "Sistemul trebuia sa arunce RuntimeException pentru un URL invalid"
        );

        // Ne asiguram ca eroarea aruncata contine explicatia corecta
        Assertions.assertTrue(exception.getMessage().contains("Invalid URL format"),
                "Mesajul de eroare trebuie sa specifice ca formatul este invalid");
    }
}