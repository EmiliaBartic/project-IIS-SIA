package org.datasource;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.MediaType;

@RestController
@RequestMapping("/locations")
public class RESTViewServiceLocations {

	// 1. Endpoint pentru Departamente (cu date de test care includ o lista de orase)
	@RequestMapping(value = "/DepartamentView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public String get_DepartamentView() {
		// Returnam un departament care are si o lista de orase inauntru (necesar pentru "inline" si "explode" din Spark)
		return "[{" +
				"\"idDepartament\":\"1\"," +
				"\"departamentName\":\"IT\"," +
				"\"departamentCode\":\"IT-01\"," +
				"\"countryName\":\"Romania\"," +
				"\"cities\": [{\"idCity\":\"101\", \"cityName\":\"Iasi\"}]" +
				"}]";
	}

	// 2. Endpoint pentru Orase (necesar pentru cities_view din SQL)
	@RequestMapping(value = "/CityView", method = RequestMethod.GET,
			produces = {MediaType.APPLICATION_JSON_VALUE})
	@ResponseBody
	public String get_CityView() {
		return "[{\"idCity\":\"101\", \"cityName\":\"Iasi\", \"countryName\":\"Romania\"}]";
	}
}