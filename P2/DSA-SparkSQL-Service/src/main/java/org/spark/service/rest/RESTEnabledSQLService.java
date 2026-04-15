package org.spark.service.rest;

import org.spark.service.exception.RESTSQLWorkflowException;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.logging.Logger;

/* REST Enabled SQL API:
    http://localhost:9990/DSA-SparkSQL-Service/_sqlrest/query
    http://localhost:9990/DSA-SparkSQL-Service/_sqlrest/create-json-view-from-rest?view_name={view_name}
 */

@RestController
@RequestMapping("/_sqlrest")
public class RESTEnabledSQLService {
    //
    private static Logger logger = Logger.getLogger(RESTEnabledSQLService.class.getName());
    //
    private SQLViewWorkflow sqlViewWorkflow;
    //
    @PostMapping(value = "/query",
            produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public SQLResponse executeQuery(@RequestBody String SQLQuery){
        if (SQLQuery == null || SQLQuery.isEmpty())
            throw new RuntimeException("STEP_0: Call REST Endpoint Error: query is NULL or EMPTY");
        logger.info("DEBUG: Start execute: " + SQLQuery);
        //
        return sqlViewWorkflow.executeSQLQuery(SQLQuery);
    }

    //
    /* SQLViewWorkflow Processing Logic:
    * CREATE SQL JSON VIEW from JSON Resource with REST Endpoint URL
    * */
    @PostMapping(value = "/create-json-view-from-rest",
            produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public SQLViewDefinition createJsonViewFromREST(@RequestParam("view_name") String viewName,
                                                    @RequestBody String restDataServiceHttpURL){
        if (viewName == null || viewName.isEmpty())
            throw new RuntimeException("STEP_0: Call REST Endpoint Error: VIEW NAME is NULL or EMPTY");
        if (restDataServiceHttpURL == null || restDataServiceHttpURL.isEmpty())
            throw new RuntimeException("STEP_0: Call REST Endpoint Error: VIEW HTTP.URL is NULL or EMPTY");
        //
        logger.info("DEBUG: Start CREATE: " + viewName + " from: " + restDataServiceHttpURL);
        //
        return sqlViewWorkflow.createJsonViewFromREST(viewName, restDataServiceHttpURL);
    }

    /* To call REST-based createJSONView() from SparkSQL clients using java_method() function:
    SELECT java_method(
               'org.spark.service.rest.RESTEnabledSQLService',
               'createJSONViewFromREST',
               'CUSTOMERS_JSON_VIEW',
               'http://localhost:8090/DSA-SQL-JDBCService/rest/customers/CustomerView');
     */
    public static String createJSONViewFromREST(String viewName, String restDataServiceHttpURL){
        // 1. Call REST Endpoint
        String restData = null;
        try {
            RestTemplate restTemplate = new RestTemplate();
            //
            logger.info("DEBUG: create JSON View From REST endpoint...");
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE);
            // Put json-view-name in the URL
            String restDataEndpoint = String.format(
                            "http://localhost:9990/DSA-SparkSQL-Service/_sqlrest/create-json-view-from-rest?view_name=%s",
                            viewName);
            ResponseEntity<String> responseEntity = restTemplate.exchange(
                    restDataEndpoint,
                    HttpMethod.POST,
                    // Put REST Endpoint URL in the body
                    new HttpEntity<>(restDataServiceHttpURL, headers),
                    String.class
            );
            restData = responseEntity.getBody();
            logger.info("DEBUG: generateJSONView REST Data: " + restData);
        } catch (Exception e) {
            throw new RESTSQLWorkflowException("REST Error: " + e.getMessage());
        }
        return restData;
    }
    // Auto Autowired
    public RESTEnabledSQLService(SQLViewWorkflow workflow) {
        this.sqlViewWorkflow = workflow;
    }
}

/*
 ## CREATE VIEW Query
 curl -i -X POST \
  --user spark:sql \
  --data "http://localhost:8090/DSA-SQL-JDBCService/rest/customers/CustomerView" \
  -H "Content-Type: text/plain" \
  -k http://localhost:9990/DSA-SparkSQL-Service/_sqlrest/create-json-view-from-rest?view_name=CUSTOMER_VIEW_DATA

curl -i -X POST --user spark:sql --data "http://localhost:8090/DSA-SQL-JDBCService/rest/customers/CustomerView" -H "Content-Type: text/plain"  -k http://localhost:9990/DSA-SparkSQL-Service/_sqlrest/create-json-view-from-rest?view_name=CUSTOMER_VIEW_DATA

 */