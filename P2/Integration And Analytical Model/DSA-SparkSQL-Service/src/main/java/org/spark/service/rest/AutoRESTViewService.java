package org.spark.service.rest;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.spark.service.SparkSQLService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import java.util.logging.Logger;

/*	REST Service URL:
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/{VIEW_NAME}
	http://localhost:9990/DSA-SparkSQL-Service/rest/STRUCT/{VIEW_NAME}
	http://localhost:9990/DSA-SparkSQL-Service/rest/ping
 */
@RestController @RequestMapping("/rest")
public class AutoRESTViewService {
    private static Logger logger = Logger.getLogger(AutoRESTViewService.class.getName());
    //
    private final SparkSQLService sparkSQLService;
    //
    @RequestMapping(value = "/ping", method = RequestMethod.GET,
            produces = {MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String pingDataSource() {
        logger.info(">>>> SparkSQLRESTService is Up!");
        return "PING response from SparkSQLRESTService!";
    }
    //
    @RequestMapping(value = "/view/{VIEW_NAME}", method = RequestMethod.GET,
            produces = {MediaType.APPLICATION_JSON_VALUE, MediaType.TEXT_PLAIN_VALUE})
    @ResponseBody
    public String get_ViewDataSet(@PathVariable("VIEW_NAME") String viewName) throws Exception {
        logger.info("DEBUG: get_ViewDataSet: Querying View: " + viewName);
        Dataset<Row> viewDataSet =  this.sparkSQLService.getSpark().sql("SELECT * FROM " + viewName);
        // DEBUG: View Data Set
        logger.info("DEBUG: get_ViewDataSet: View Schema: ");
        viewDataSet.printSchema();
        logger.info("DEBUG: get_ViewDataSet: View Data: ");
        viewDataSet.show();
        //
        String jsonList = viewDataSet.toJSON().collectAsList().toString();
        //logger.info("DEBUG: get_ViewDataSet to return: " + jsonList);
        return jsonList;
    }

    //
    @RequestMapping(value = "/STRUCT/{VIEW_NAME}", method = RequestMethod.GET,
            produces = {MediaType.TEXT_PLAIN_VALUE, MediaType.APPLICATION_JSON_VALUE})
    @ResponseBody
    public String get_ViewDataSTRUCT(@PathVariable("VIEW_NAME") String viewName) throws Exception {
        logger.info("DEBUG: get_ViewDataSTRUCT: Querying View: " + viewName);
        Dataset<Row> viewDataSet =  this.sparkSQLService.getSpark().sql(
                "SELECT * FROM " + viewName + " WHERE 1=0");
        // DEBUG: View Data Set
        logger.info("DEBUG: get_ViewDataSTRUCT: View Schema: ");
        viewDataSet.printSchema();
        logger.info("DEBUG: get_ViewDataSTRUCT: View Data: ");
        viewDataSet.show();
        //
        String viewSchema = viewDataSet.schema().sql();
        //logger.info("DEBUG: get_ViewDataSTRUCT to return: " + viewSchema);
        return viewSchema;
    }
    // Auto-Autowired
    public AutoRESTViewService(SparkSQLService sparkSQLService) {
        this.sparkSQLService = sparkSQLService;
    }
}

/*	REST Service URL
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/{VIEW_NAME}

	* Data Source: SQL JDBC PostgreSQL
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/customers_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/customers_details_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/customers_addresses_view
	* Data Source: SQ: JPA Oracle
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/sales_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/products_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/invoices_view
    * Data Source: XML.DOC
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/departaments_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/cities_view
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/departaments_cities_view_all
    * Data Source: XLS.DOC
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/CTG_CUST_EMP_VIEW
	http://localhost:9990/DSA-SparkSQL-Service/rest/STRUCT/CTG_CUST_EMP_VIEW
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/CTG_CUST_TO_VIEW
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/Periods_VIEW
	http://localhost:9990/DSA-SparkSQL-Service/rest/view/CTG_PROD_VIEW
 */