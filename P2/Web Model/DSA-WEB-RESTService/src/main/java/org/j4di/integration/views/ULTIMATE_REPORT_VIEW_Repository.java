package org.j4di.integration.views;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;

public interface ULTIMATE_REPORT_VIEW_Repository extends JpaRepository<ULTIMATE_REPORT_VIEW, String> {
    @Query("SELECT o FROM ULTIMATE_REPORT_VIEW o")
    List<ULTIMATE_REPORT_VIEW> get_ULTIMATE_REPORT_VIEW();
}