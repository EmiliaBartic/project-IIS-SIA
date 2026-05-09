package org.datasource.jpa.views.movie;

import org.datasource.jpa.JPADataSourceConnector;
import org.springframework.stereotype.Service;
import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class MovieViewBuilder {
	private static Logger logger = Logger.getLogger(MovieViewBuilder.class.getName());

	// Interogarea JPQL utilizeaza operatorul NEW pentru a mapa direct rezultatele in obiectul MovieView
	protected String JPQL_MOVIES_SELECT =
			"SELECT NEW org.datasource.jpa.views.movie.MovieView("
					+ "m.tconst, m.primaryTitle, m.startYear, m.runtimeMinutes, m.genres) "
					+ "FROM MovieView m";

	protected List<MovieView> movieViewList = new ArrayList<>();

	// Metoda pentru returnarea listei de filme procesate
	public List<MovieView> getMovieViewList() {
		return movieViewList;
	}

	// Procesul de construire a vederii (Build stage) conform arhitecturii J4DI
	public MovieViewBuilder build(){
		return this.select();
	}

	protected MovieViewBuilder select(){
		logger.info("Executare interogare JPQL pentru integrarea sursei Oracle Movies...");

		EntityManager em = dataSourceConnector.getEntityManager(); // Obtinerea managerului de entitati

		// Crearea si executarea interogarii bazate pe modelul OO Java
		Query viewQuery = em.createQuery(JPQL_MOVIES_SELECT);

		// Maparea automata a setului de rezultate (ResultSet) in instante de MovieView
		this.movieViewList = viewQuery.getResultList();

		logger.info("S-au extras " + movieViewList.size() + " inregistrari din Oracle.");
		return this;
	}

	protected JPADataSourceConnector dataSourceConnector;

	// Injectarea conectorului prin constructor pentru accesul la canalul de date
	public MovieViewBuilder(JPADataSourceConnector dataSourceConnector) {
		super();
		this.dataSourceConnector = dataSourceConnector;
	}
}