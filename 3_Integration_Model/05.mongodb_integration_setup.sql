/* 
   STEP 1: Security Configuration
   Granting the database user permission to access the local network (localhost).
   This is required because Oracle blocks outbound HTTP requests by default.
*/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace (
    host       => 'localhost',
    lower_port => 8080,
    upper_port => 8085,
    ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                              principal_name => 'FDBO_USER', 
                              principal_type => xs_acl.ptype_db));
END;
/

/* 
   STEP 2: Data Fetcher Function
   This function acts as a client that calls the RESTHeart API.
   It retrieves the JSON documents from MongoDB and returns them as a CLOB.
*/
CREATE OR REPLACE FUNCTION get_mongo_actors RETURN CLOB IS
    req   utl_http.req;
    res   utl_http.resp;
    buffer VARCHAR2(32767);
    data  CLOB;
BEGIN
    -- Enable error checking for HTTP responses
    utl_http.set_response_error_check(true);
    
    -- Initialize the GET request to the RESTHeart endpoint
    -- We use pagesize=1000 to fetch a significant batch of records
    req := utl_http.begin_request('http://localhost:8080/mds/actors?pagesize=1000', 'GET');
    
    -- Set Basic Authentication credentials (default RESTHeart security)
    utl_http.set_authentication(req, 'admin', 'secret');
    
    -- Execute the request and get the response
    res := utl_http.get_response(req);
    
    -- Prepare a temporary LOB to store the JSON content
    dbms_lob.createtemporary(data, FALSE);

    BEGIN
        LOOP
            -- Read the response body in chunks and append it to the CLOB
            utl_http.read_text(res, buffer);
            dbms_lob.writeappend(data, length(buffer), buffer);
        END LOOP;
    EXCEPTION
        WHEN utl_http.end_of_body THEN
            -- Close the response once the end of the data stream is reached
            utl_http.end_response(res);
    END;
    
    RETURN data;
END;
/

/* 
   STEP 3: Relational Projection (The View)
   Maps the NoSQL JSON structure into a standard SQL table format.
   This allows you to query MongoDB data using standard SQL syntax.
*/
CREATE OR REPLACE VIEW v_actors_mongodb_flat AS
SELECT 
    jt.nconst,
    jt.nume,
    jt.profesie,
    -- Această parte "sparge" lista tt1,tt2 în rânduri separate
    trim(column_value) as movie_id
FROM (
    SELECT nconst, nume, profesie, known_for 
    FROM v_actors_mongodb -- View-ul tău existent
) jt,
xmltable(('"' || replace(jt.known_for, ',', '","') || '"')) ;

-- Final check to verify the data is correctly projected
SELECT * FROM v_actors_mongodb_flat;
