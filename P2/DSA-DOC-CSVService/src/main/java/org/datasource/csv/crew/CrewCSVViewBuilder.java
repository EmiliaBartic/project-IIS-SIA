package org.datasource.csv.crew;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.datasource.csv.CSVResourceFileDataSourceConnector;
import org.springframework.stereotype.Service;

import java.io.FileReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;

@Service
public class CrewCSVViewBuilder {
    private List<CrewView> viewList = new ArrayList<>();
    private CSVResourceFileDataSourceConnector dataSourceConnector;

    public CrewCSVViewBuilder(CSVResourceFileDataSourceConnector dataSourceConnector) {
        this.dataSourceConnector = dataSourceConnector;
    }

    public List<CrewView> getViewList() { return viewList; }

    // Filtrul magic: transformam \N intr-un text curat pe care Spark il accepta
    private String cleanData(String data) {
        if (data == null || data.trim().isEmpty()) {
            return "N/A";
        }

        // 1. Inlocuim fantoma \N
        if (data.contains("\\N") || data.equals("N")) {
            return "N/A";
        }

        // 2. Distrugem orice simbol care poate strica JSON-ul
        // Scoatem absolut toate parantezele patrate, ghilimelele si slash-urile
        String safeText = data.replace("[", "")
                .replace("]", "")
                .replace("\"", "")
                .replace("\\", "")
                .trim();

        return safeText;
    }

    public CrewCSVViewBuilder build() throws Exception {
        Reader in = new FileReader(this.dataSourceConnector.getCSVFile());
        CSVFormat format = CSVFormat.DEFAULT.withFirstRecordAsHeader().withDelimiter(',');
        Iterable<CSVRecord> records = format.parse(in);
        this.viewList = new ArrayList<>();
        int limitCounter = 0;

        for (CSVRecord record : records) {
            this.viewList.add(new CrewView(
                    cleanData(record.get("tconst")),
                    cleanData(record.get("category")),
                    cleanData(record.get("job")),
                    cleanData(record.get("characters"))
            ));
            limitCounter++;
            if (limitCounter >= 500) break; // Protectie RAM
        }
        return this;
    }
}