package org.j4di.integration.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface OLAP_DIM_MOVIES_ACTORS_Repository extends JpaRepository<OLAP_DIM_MOVIES_ACTORS, String> {

    @Query("SELECT o FROM OLAP_DIM_MOVIES_ACTORS o")
    List<OLAP_DIM_MOVIES_ACTORS> get_OLAP_DIM_MOVIES_ACTORS();
}