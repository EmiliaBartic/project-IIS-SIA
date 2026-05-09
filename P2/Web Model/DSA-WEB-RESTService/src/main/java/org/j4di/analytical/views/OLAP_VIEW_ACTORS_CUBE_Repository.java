package org.j4di.analytical.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface OLAP_VIEW_ACTORS_CUBE_Repository extends JpaRepository<OLAP_VIEW_ACTORS_CUBE, String> {
    @Query("SELECT o FROM OLAP_VIEW_ACTORS_CUBE o")
    List<OLAP_VIEW_ACTORS_CUBE> get_OLAP_VIEW_ACTORS_CUBE();
}