package org.datasource.springdata.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface MovieViewRepository extends JpaRepository<MovieView, String> {

    // 1. Interogare automata bazata pe numele metodei
    List<MovieView> findByStartYear(Integer startYear);

    // 2. Interogare custom folosind JPQL
    @Query("SELECT m FROM MovieView m WHERE m.genres LIKE %:genre%")
    List<MovieView> findMoviesByGenre(@Param("genre") String genre);

    @Query(nativeQuery = true,
            value = "SELECT primaryTitle, genres, average_rating as averageRating, " +
                    "directors, actor_name as actorName " +
                    "FROM FDBO. V_ULTIMATE_MOVIE_REPORT WHERE ROWNUM <= 100")
    List<MovieFullReportView> getUltimateReport();

    // 3. Interogare complexa pentru Analitica (Top filme)
    @Query("SELECT m FROM MovieView m WHERE m.runtimeMinutes > :minDuration ORDER BY m.tconst DESC")
    List<MovieView> getLongMovies(@Param("minDuration") Integer minDuration);
}