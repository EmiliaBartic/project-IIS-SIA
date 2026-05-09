package org.spark.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

import java.util.logging.Logger;

// --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED
// java --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED -jar DSA-SparkSQL-Service-2025.1.jar
@SpringBootApplication(exclude={DataSourceAutoConfiguration.class} )
public class SprinBootSparkSQLStarter extends SpringBootServletInitializer
    {
        private static Logger logger = Logger.getLogger(SprinBootSparkSQLStarter.class.getName());

        public static void main(String[] args) {
            logger.info("Loading ... SparkStarterService with Spark Default Settings ... DSA");
            SpringApplication.run(SprinBootSparkSQLStarter.class, args);
        }

}

// java --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED