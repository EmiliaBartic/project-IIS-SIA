package org.datasource.jdbc.views.ratings;

import org.datasource.jdbc.JDBCDataSourceConnector;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class RatingViewBuilder {
	private static Logger logger = Logger.getLogger(RatingViewBuilder.class.getName());

	// 1. Definim interogarea SQL exact cum ai rula-o in pgAdmin
	private String SQL_RATINGS_SELECT =
			"SELECT tconst, average_rating, num_votes FROM movies_pg.ratings LIMIT 100";

	// 2. Cache-ul in care vom stoca rezultatele
	private List<RatingView> ratingsViewList = new ArrayList<>();
	private JDBCDataSourceConnector jdbcConnector;

	public RatingViewBuilder(JDBCDataSourceConnector jdbcConnector) {
		this.jdbcConnector = jdbcConnector;
	}

	public List<RatingView> getViewList() {
		return this.ratingsViewList;
	}

	// 3. Logica efectiva de extragere si construire
	public RatingViewBuilder build() {
		// Folosim try-with-resources pentru a inchide automat conexiunea la final
		try (Connection jdbcConnection = jdbcConnector.getConnection()) {

			logger.info("Executing JDBC Query on PostgreSQL: " + SQL_RATINGS_SELECT);
			Statement selectStmt = jdbcConnection.createStatement();

			// rs (ResultSet) contine raspunsul brut de la Postgres
			ResultSet rs = selectStmt.executeQuery(SQL_RATINGS_SELECT);

			this.ratingsViewList = new ArrayList<>();

			// Iteram prin fiecare rand returnat
			while (rs.next()) {
				// Extragem coloanele conform numelui lor din baza de date
				String tconst = rs.getString("tconst");
				Double avgRating = rs.getDouble("average_rating");
				Integer numVotes = rs.getInt("num_votes");

				// Construim obiectul Java si il adaugam in lista finala
				this.ratingsViewList.add(new RatingView(tconst, avgRating, numVotes));
			}

		} catch (Exception ex) {
			logger.severe("Eroare la executia interogarii JDBC: " + ex.getMessage());
			ex.printStackTrace();
		}

		return this;
	}
}