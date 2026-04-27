package org.datasource;

import org.datasource.csv.crew.CrewView;
import org.datasource.csv.crew.CrewCSVViewBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController @RequestMapping("/crew-data")
public class RESTViewServiceCSV {

	@Autowired private CrewCSVViewBuilder crewCSVViewBuilder;

	@RequestMapping(value = "/ping", method = RequestMethod.GET, produces = {MediaType.TEXT_PLAIN_VALUE})
	@ResponseBody
	public String ping() { return "Ping OK from CSV!"; }

	@RequestMapping(value = "/CrewView", method = RequestMethod.GET, produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public List<CrewView> get_CrewView() throws Exception {
		if (this.crewCSVViewBuilder.getViewList().isEmpty()) {
			return this.crewCSVViewBuilder.build().getViewList();
		}
		return this.crewCSVViewBuilder.getViewList();
	}
}