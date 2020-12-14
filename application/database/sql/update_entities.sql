-- Makes a backup of existing data in `entities` table, then propagates updates from `entities_staging`
-- ENVIRONMENTS --
--   staging
--   production
-- DEPENDENCIES --
--   Objects: entities, entities_proc
--   Functions: None
-- DEFAULTS --
-- None
CREATE OR REPLACE FUNCTION update_entities(
    IN data_source_name                                 text DEFAULT 'giscorps'
  )
  RETURNS VOID
  AS $$
    DECLARE
      current_record_count INTEGER ;
      new_record_count INTEGER;
    BEGIN
      -- Make sure that we don't inadvertently wipe the DB
      IF (data_source_name NOT ILIKE '%giscorps%') THEN 
        RAISE EXCEPTION E'`Unrecognized data source: `%`', data_source_name;
      ELSE
        RAISE NOTICE E'Starting data update process for `data_source` == %', data_source_name;
        EXECUTE 'SELECT COUNT(1) FROM entities WHERE data_source ILIKE ' || '''%' || data_source_name || '%''' INTO current_record_count;
        EXECUTE 'SELECT COUNT(1) FROM entities_proc WHERE data_source ILIKE' || '''%' || data_source_name || '%'' OR data_source IS NULL' INTO new_record_count;
        ASSERT (new_record_count >= current_record_count), format('Number of source records (%I) must be >= number of existing records (%I).', new_record_count, current_record_count);

      END IF;
      
      ------------------------------------------------------------------
      ---- Backup existing data first            -----------------------
      ------------------------------------------------------------------
      
      ---- Create table `entities_backup` and index
      DROP TABLE IF EXISTS entities_backup;
      CREATE TABLE IF NOT EXISTS entities_backup AS TABLE entities;
      CREATE UNIQUE INDEX entities_backup_pkey ON entities_backup(record_id int4_ops);
      CREATE UNIQUE INDEX entities_backup_location_id_idx ON entities_backup(location_id text_ops);

      ---- Insert into `entities_backup`
      TRUNCATE TABLE "entities_backup" RESTART IDENTITY; -- First, remove all existing values
      INSERT INTO "entities_backup"
      SELECT 
        *
      FROM 
        "entities"
      ON CONFLICT ("location_id") DO NOTHING
      ;
      
      ------------------------------------------------------------------
      ---- Update data in `entities` using data in `entities_proc` -----
      ------------------------------------------------------------------
      
      ---- Insert into `entities`
      TRUNCATE TABLE "entities" RESTART IDENTITY; -- First, remove all existing values
      INSERT INTO "entities"
      SELECT 
        *
      FROM 
        "entities_proc"
      ON CONFLICT ("location_id") DO NOTHING
      ;
      
      ---- Set update timestamp
      UPDATE "entities" SET "updated_on" = CURRENT_TIMESTAMP;

      -- MAKE ALL NULL VALUES EMPTY STRINGS
      UPDATE entities SET "location_name" = '' WHERE "location_name" IS NULL;

      UPDATE entities SET "location_address_street" = '' WHERE "location_address_street" IS NULL;

      UPDATE entities SET "location_address_locality" = '' WHERE "location_address_locality" IS NULL;

      UPDATE entities SET "location_address_region" = '' WHERE "location_address_region" IS NULL;

      UPDATE entities SET "location_address_postal_code" = '' WHERE "location_address_postal_code" IS NULL;

      UPDATE entities SET "location_contact_phone_main" = '' WHERE "location_contact_phone_main" IS NULL;

      UPDATE entities SET "location_contact_phone_appointments" = '' WHERE "location_contact_phone_appointments" IS NULL;

      UPDATE entities SET "location_contact_phone_covid" = '' WHERE "location_contact_phone_covid" IS NULL;

      UPDATE entities SET "location_contact_url_main" = '' WHERE "location_contact_url_main" IS NULL;

      UPDATE entities SET "location_contact_url_covid_info" = '' WHERE "location_contact_url_covid_info" IS NULL;

      UPDATE entities SET "location_contact_url_covid_screening_tool" = '' WHERE "location_contact_url_covid_screening_tool" IS NULL;

      UPDATE entities SET "location_contact_url_covid_virtual_visit" = '' WHERE "location_contact_url_covid_virtual_visit" IS NULL;

      UPDATE entities SET "location_contact_url_covid_appointments" = '' WHERE "location_contact_url_covid_appointments" IS NULL;

      UPDATE entities SET "location_place_of_service_type" = 'Other' WHERE "location_place_of_service_type" IS NULL;

      UPDATE entities SET "location_hours_of_operation" = '' WHERE "location_hours_of_operation" IS NULL;

      UPDATE entities SET "is_evaluating_symptoms" = TRUE WHERE "is_evaluating_symptoms" IS NULL;

      UPDATE entities SET "is_evaluating_symptoms_by_appointment_only" = TRUE WHERE "is_evaluating_symptoms_by_appointment_only" IS NULL;

      UPDATE entities SET "is_ordering_tests" = FALSE WHERE "is_ordering_tests" IS NULL;

      UPDATE entities SET "is_ordering_tests_only_for_those_who_meeting_criteria" = TRUE WHERE "is_ordering_tests_only_for_those_who_meeting_criteria" IS NULL;

      UPDATE entities SET "is_collecting_samples" = FALSE WHERE "is_collecting_samples" IS NULL;

      UPDATE entities SET "is_collecting_samples_onsite" = TRUE WHERE "is_collecting_samples_onsite" IS NULL;

      UPDATE entities SET "is_collecting_samples_for_others" = TRUE WHERE "is_collecting_samples_for_others" IS NULL;

      UPDATE entities SET "is_collecting_samples_by_appointment_only" = TRUE WHERE "is_collecting_samples_by_appointment_only" IS NULL;

      UPDATE entities SET "is_processing_samples" = FALSE WHERE "is_processing_samples" IS NULL;

      UPDATE entities SET "is_processing_samples_onsite" = FALSE WHERE "is_processing_samples_onsite" IS NULL;

      UPDATE entities SET "is_processing_samples_for_others" = FALSE WHERE "is_processing_samples_for_others" IS NULL;

      UPDATE entities SET "location_specific_testing_criteria" = TRUE WHERE "location_specific_testing_criteria" IS NULL;

      UPDATE entities SET "additional_information_for_patients" = '' WHERE "additional_information_for_patients" IS NULL;

      UPDATE entities SET "reference_publisher_of_criteria" = '' WHERE "reference_publisher_of_criteria" IS NULL;

      UPDATE entities SET "data_source" = '' WHERE "data_source" IS NULL;

      UPDATE entities SET "raw_data" = NULL::json WHERE "raw_data" IS NULL;

      UPDATE entities SET "geojson" = NULL::json WHERE "geojson" IS NULL;

      UPDATE entities SET "location_status" = 'Invalid' WHERE "location_status" IS NULL;

      UPDATE entities SET "external_location_id" = '' ;
      
      ---- Clean up 
      TRUNCATE TABLE entities_proc;
      
      ---- Communicate completion
      RAISE NOTICE E'Done updating data in `entities` table. Final record count: %', new_record_count;
    END;
$$
  LANGUAGE plpgsql
  RETURNS NULL ON NULL INPUT -- the function is NOT executed when there are null arguments
  PARALLEL UNSAFE
;
