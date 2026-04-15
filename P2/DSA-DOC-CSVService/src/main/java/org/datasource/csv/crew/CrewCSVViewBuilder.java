package org.datasource.csv.crew;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.datasource.csv.CSVResourceFileDataSourceConnector;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Service
public class CrewCSVViewBuilder {
    private static Logger logger = Logger.getLogger(CrewCSVViewBuilder.class.getName());
    private List<CrewView> viewList = new ArrayList<>();
    private CSVResourceFileDataSourceConnector dataSourceConnector;
    private File csvFile;

    public CrewCSVViewBuilder(CSVResourceFileDataSourceConnector dataSourceConnector) throws Exception {
        this.dataSourceConnector = dataSourceConnector;
        csvFile = dataSourceConnector.getCSVFile();
    }

    public List<CrewView> getViewList() {
        return viewList;
    }

    // Builder Workflow
    public CrewCSVViewBuilder build() throws Exception {
        logger.info("Incepem parsarea fisierului CSV (Limita: 500 inregistrari)...");
        Reader in = new FileReader(this.csvFile);

        // Folosim formatul standard cu header
        CSVFormat format = CSVFormat.DEFAULT.withFirstRecordAsHeader().withDelimiter(',');
        Iterable<CSVRecord> records = format.parse(in);

        this.viewList = new ArrayList<>();
        int limitCounter = 0;

        for (CSVRecord record : records) {
            // Extragem datele pe baza numelui coloanei din CSV
            this.viewList.add(new CrewView(
                    record.get("tconst"),
                    record.get("category"),
                    record.get("job"),
                    record.get("characters")
            ));

            limitCounter++;
            // PROTECTIE ANTI-CRASH (3.45 GB file)
            if (limitCounter >= 500) {
                break;
            }
        }
        logger.info("Parsare completa. Am extras " + this.viewList.size() + " inregistrari.");
        return this;
    }
}