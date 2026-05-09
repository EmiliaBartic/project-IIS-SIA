package org.j4di.integration.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface RATINGS_VIEW_Repository extends JpaRepository<RATINGS_VIEW, String> {
    @Query("SELECT o FROM RATINGS_VIEW o")
    List<RATINGS_VIEW> get_RATINGS_VIEW();
}