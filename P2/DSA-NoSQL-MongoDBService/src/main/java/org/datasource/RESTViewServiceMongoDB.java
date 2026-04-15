package org.datasource;

import org.datasource.mongodb.views.actors.ActorView;
import org.datasource.mongodb.views.actors.ActorViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.logging.Logger;

/*	REST Service URLs
	http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data/ping
	http://localhost:8093/DSA-NoSQL-MongoDBService/rest/actors-data/ActorView
*/
@RestController
@RequestMapping("/actors-data") // Am schimbat din /locations in /actors-data
public class RESTViewServiceMongoDB {
	private static Logger logger = Logger.getLogger(RESTViewServiceMongoDB.class.getName());

	@Autowired
	private ActorViewBuilder viewBuilder;

	@RequestMapping(value = "/ping", method = RequestMethod.GET,
			produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String pingDataSource() {
		logger.info(">>>> MongoDB Actor Service is Up!");
		return "Ping response from RESTViewServiceMongoDB!";
	}

	@RequestMapping(value = "/ActorView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<ActorView> get_ActorView() throws Exception {
		// Returneaza lista de actori mapata din documentele BSON
		return this.viewBuilder.build().getActorsViewList();
	}
}