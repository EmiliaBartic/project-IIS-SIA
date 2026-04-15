package org.spark.service;

import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.hive.thriftserver.HiveThriftServer2;
import org.springframework.stereotype.Service;

import java.util.logging.Logger;

@Service
public class SparkSQLService {
    private static Logger logger = Logger.getLogger(SparkSQLService.class.getName());

    private SparkSession spark;

    public SparkSession getSpark() {
        return spark;
    }

    public SparkSQLService() {
        startThriftServer2();
    }
    /*
    * https://spark.apache.org/docs/latest/sql-distributed-sql-engine.html
    *
     */
    private void startThriftServer2(){
        // Create a SparkSession with Hive support
        this.spark = SparkSession.builder()
                .master("local[*]")
                .appName("SparkThriftServer")
                .enableHiveSupport()
                //.config("spark.sql.hive.thriftServer.singleSession", true)
                .config("hive.server2.thrift.port", "10000")
                //.config("spark.hadoop.hadoop.native.lib","false")
                //ENV: HADOOP_PATH=C:\hadoop
                .getOrCreate();

        // Start the Thrift server
        HiveThriftServer2.startWithContext(spark.sqlContext());

        logger.info(">>> HiveThriftServer2 started successfully!");
    }
}

/* -- SparkSQL Hive Driver Config
<!-- https://mvnrepository.com/artifact/org.apache.hive/hive-jdbc -->
<dependency>
    <groupId>org.apache.hive</groupId>
    <artifactId>hive-jdbc</artifactId>
    <version>3.1.2</version>
</dependency>
*/