package org.datasource;

import org.datasource.jdbc.JDBCDataSourceConnector;
import org.datasource.jdbc.views.ratings.RatingView;
import org.datasource.jdbc.views.ratings.RatingViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Logger;

/*	REST Service URLs disponibile:
 	http://localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/ping
 	http://localhost:8090/DSA-SQL-JDBCService/rest/ratings-data/RatingView
*/
@RestController
@RequestMapping("/ratings-data")
public class RESTViewServiceJDBC {
	private static Logger logger = Logger.getLogger(RESTViewServiceJDBC.class.getName());

	@Autowired
	private JDBCDataSourceConnector jdbcConnector;

	@Autowired
	private RatingViewBuilder ratingViewBuilder;

	@RequestMapping(value = "/ping", method = RequestMethod.GET,
			produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String ping() {
		logger.info(">>>> DSA-SQL-JDBCService:: RESTViewService is Up!");
		return "Ping response from PostgreSQL Ratings Service!";
	}

	@RequestMapping(value = "/RatingView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<RatingView> get_RatingView() {
		// Returnam lista generata prin JDBC direct din PostgreSQL
		return this.ratingViewBuilder.build().getViewList();
	}
}