package org.j4di.analytical.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface OLAP_VIEW_VOTES_ROLLUP_Repository extends JpaRepository<OLAP_VIEW_VOTES_ROLLUP, String> {
    @Query("SELECT o FROM OLAP_VIEW_VOTES_ROLLUP o")
    List<OLAP_VIEW_VOTES_ROLLUP> get_OLAP_VIEW_VOTES_ROLLUP();
}