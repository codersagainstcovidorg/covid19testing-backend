  -- Triggers data ingest process in response to new rows added to `data_ingest` table
  -- ENVIRONMENTS --
  --   staging
  -- DEPENDENCIES --
  --   Objects: entities, data_ingest, audit_data_ingest
  --   Functions: ingest_data
  -- DEFAULTS --
  --   Not applicable for triggers

CREATE OR REPLACE FUNCTION begin_data_ingest() 
RETURNS TRIGGER 
  AS $$
    --
    -- Perform the required operation on data_ingest, and create a row in audit_data_ingest to reflect the change.
    --    
    DECLARE
        data_source_name TEXT;
    BEGIN
      -- Determine which data source triggered action
      EXECUTE 'SELECT COALESCE(first_value("data_source") OVER (ORDER BY "record_id" DESC), ' || '''giscorps''' || ') FROM data_ingest LIMIT 1' INTO data_source_name;      
      
      -- Check that operation is an insert
      IF (TG_OP = 'INSERT') THEN
        RAISE NOTICE '`%` operation on `%` triggered `begin_data_ingest()` for `data_source` == `%`', TG_OP, TG_TABLE_NAME, data_source_name;
        INSERT INTO audit_data_ingest VALUES(DEFAULT, 'INSERT', 'START', data_source_name, clock_timestamp());        
        PERFORM ingest_data();
        INSERT INTO audit_data_ingest VALUES(DEFAULT, 'INSERT', 'COMPLETE', data_source_name, clock_timestamp());
        
      END IF;
      RETURN NULL; -- result is ignored since this is an AFTER trigger
    
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_data_ingest
  AFTER INSERT ON data_ingest
  FOR EACH STATEMENT 
  EXECUTE PROCEDURE begin_data_ingest();
  
