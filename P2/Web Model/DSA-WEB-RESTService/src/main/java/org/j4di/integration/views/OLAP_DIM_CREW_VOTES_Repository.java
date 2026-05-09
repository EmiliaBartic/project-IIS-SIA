package org.j4di.integration.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface OLAP_DIM_CREW_VOTES_Repository extends JpaRepository<OLAP_DIM_CREW_VOTES, String> {
    @Query("SELECT o FROM OLAP_DIM_CREW_VOTES o")
    List<OLAP_DIM_CREW_VOTES> get_OLAP_DIM_CREW_VOTES();
}