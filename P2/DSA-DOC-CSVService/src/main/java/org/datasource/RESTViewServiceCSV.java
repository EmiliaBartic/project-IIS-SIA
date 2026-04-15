package org.datasource;

import org.datasource.csv.crew.CrewView;
import org.datasource.csv.crew.CrewCSVViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.logging.Logger;

/*	REST Service URL:
	http://localhost:8097/DSA-DOC-CSVService/rest/crew-data/CrewView
*/
@RestController
@RequestMapping("/crew-data")
public class RESTViewServiceCSV {
	private static Logger logger = Logger.getLogger(RESTViewServiceCSV.class.getName());

	@Autowired
	private CrewCSVViewBuilder crewCSVViewBuilder;

	@RequestMapping(value = "/ping", method = RequestMethod.GET, produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String ping() {
		return "Ping response from CSV Crew Service!";
	}

	@RequestMapping(value = "/CrewView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<CrewView> get_CrewView() throws Exception {
		// Daca lista e goala, o construim (citim CSV-ul)
		if (this.crewCSVViewBuilder.getViewList().isEmpty()) {
			return this.crewCSVViewBuilder.build().getViewList();
		}
		// Daca am citit deja, o returnam direct din memorie (Cache)
		return this.crewCSVViewBuilder.getViewList();
	}
}