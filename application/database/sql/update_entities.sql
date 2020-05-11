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
    BEGIN
      -- Make sure that we don't inadvertently wipe the DB
      IF (data_source_name NOT ILIKE '%giscorps%') THEN 
        RAISE EXCEPTION E'`Unrecognized data source: `%`', data_source_name;
      END IF;
      
      ------------------------------------------------------------------
      ---- Backup existing data first            -----------------------
      ------------------------------------------------------------------
      
      ---- Create table `entities_backup` and index
      DROP TABLE IF EXISTS entities_backup;
      CREATE TABLE IF NOT EXISTS entities_backup AS TABLE entities;
      CREATE UNIQUE INDEX entities_backup_pkey ON entities_backup(record_id int4_ops);
      CREATE UNIQUE INDEX entities_backup_location_id_idx ON entities_backup(location_id text_ops);
      CREATE UNIQUE INDEX entities_backup_location_id_external_location_id_idx ON entities_backup(location_id text_ops, external_location_id text_ops);

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
      -- TRUNCATE TABLE "entities" RESTART IDENTITY; -- First, remove all existing values
      WITH updated_entities AS (
        SELECT
          "location_id"
          ,"is_hidden"
          ,"is_verified"
          ,"location_name"
          ,"location_address_street"
          ,"location_address_locality"
          ,"location_address_region"
          ,"location_address_postal_code"
          ,"location_latitude"
          ,"location_longitude"
          ,"location_contact_phone_main"
          ,"location_contact_phone_appointments"
          ,"location_contact_phone_covid"
          ,"location_contact_url_main"
          ,"location_contact_url_covid_info"
          ,"location_contact_url_covid_screening_tool"
          ,"location_contact_url_covid_virtual_visit"
          ,"location_contact_url_covid_appointments"
          ,"location_place_of_service_type"
          ,"location_hours_of_operation"
          ,"is_evaluating_symptoms"
          ,"is_evaluating_symptoms_by_appointment_only"
          ,"is_ordering_tests"
          ,"is_ordering_tests_only_for_those_who_meeting_criteria"
          ,"is_collecting_samples"
          ,"is_collecting_samples_onsite"
          ,"is_collecting_samples_for_others"
          ,"is_collecting_samples_by_appointment_only"
          ,"is_processing_samples"
          ,"is_processing_samples_onsite"
          ,"is_processing_samples_for_others"
          ,"location_specific_testing_criteria"
          ,"additional_information_for_patients"
          ,"reference_publisher_of_criteria"
          ,"data_source"
          ,"created_on"
          ,"updated_on"
          ,"deleted_on"
          ,"raw_data"
          ,"location_status"
          ,"external_location_id"
        FROM 
          "entities_proc"
        WHERE
          ("is_hidden" = FALSE) 
          AND ("is_verified" = TRUE)
        GROUP BY
          "location_id"
          ,"is_hidden"
          ,"is_verified"
          ,"location_name"
          ,"location_address_street"
          ,"location_address_locality"
          ,"location_address_region"
          ,"location_address_postal_code"
          ,"location_latitude"
          ,"location_longitude"
          ,"location_contact_phone_main"
          ,"location_contact_phone_appointments"
          ,"location_contact_phone_covid"
          ,"location_contact_url_main"
          ,"location_contact_url_covid_info"
          ,"location_contact_url_covid_screening_tool"
          ,"location_contact_url_covid_virtual_visit"
          ,"location_contact_url_covid_appointments"
          ,"location_place_of_service_type"
          ,"location_hours_of_operation"
          ,"is_evaluating_symptoms"
          ,"is_evaluating_symptoms_by_appointment_only"
          ,"is_ordering_tests"
          ,"is_ordering_tests_only_for_those_who_meeting_criteria"
          ,"is_collecting_samples"
          ,"is_collecting_samples_onsite"
          ,"is_collecting_samples_for_others"
          ,"is_collecting_samples_by_appointment_only"
          ,"is_processing_samples"
          ,"is_processing_samples_onsite"
          ,"is_processing_samples_for_others"
          ,"location_specific_testing_criteria"
          ,"additional_information_for_patients"
          ,"reference_publisher_of_criteria"
          ,"data_source"
          ,"created_on"
          ,"updated_on"
          ,"deleted_on"
          ,"raw_data"
          ,"location_status"
          ,"external_location_id"
      )
      INSERT INTO "entities" AS "entities" (
        "location_id"
        ,"is_hidden"
        ,"is_verified"
        ,"location_name"
        ,"location_address_street"
        ,"location_address_locality"
        ,"location_address_region"
        ,"location_address_postal_code"
        ,"location_latitude"
        ,"location_longitude"
        ,"location_contact_phone_main"
        ,"location_contact_phone_appointments"
        ,"location_contact_phone_covid"
        ,"location_contact_url_main"
        ,"location_contact_url_covid_info"
        ,"location_contact_url_covid_screening_tool"
        ,"location_contact_url_covid_virtual_visit"
        ,"location_contact_url_covid_appointments"
        ,"location_place_of_service_type"
        ,"location_hours_of_operation"
        ,"is_evaluating_symptoms"
        ,"is_evaluating_symptoms_by_appointment_only"
        ,"is_ordering_tests"
        ,"is_ordering_tests_only_for_those_who_meeting_criteria"
        ,"is_collecting_samples"
        ,"is_collecting_samples_onsite"
        ,"is_collecting_samples_for_others"
        ,"is_collecting_samples_by_appointment_only"
        ,"is_processing_samples"
        ,"is_processing_samples_onsite"
        ,"is_processing_samples_for_others"
        ,"location_specific_testing_criteria"
        ,"additional_information_for_patients"
        ,"reference_publisher_of_criteria"
        ,"data_source"
        ,"created_on"
        ,"updated_on"
        ,"deleted_on"
        ,"raw_data"
        ,"location_status"
        ,"external_location_id"
      )
      SELECT 
        "location_id"
        ,"is_hidden"
        ,"is_verified"
        ,"location_name"
        ,"location_address_street"
        ,"location_address_locality"
        ,"location_address_region"
        ,"location_address_postal_code"
        ,"location_latitude"
        ,"location_longitude"
        ,"location_contact_phone_main"
        ,"location_contact_phone_appointments"
        ,"location_contact_phone_covid"
        ,"location_contact_url_main"
        ,"location_contact_url_covid_info"
        ,"location_contact_url_covid_screening_tool"
        ,"location_contact_url_covid_virtual_visit"
        ,"location_contact_url_covid_appointments"
        ,"location_place_of_service_type"
        ,"location_hours_of_operation"
        ,"is_evaluating_symptoms"
        ,"is_evaluating_symptoms_by_appointment_only"
        ,"is_ordering_tests"
        ,"is_ordering_tests_only_for_those_who_meeting_criteria"
        ,"is_collecting_samples"
        ,"is_collecting_samples_onsite"
        ,"is_collecting_samples_for_others"
        ,"is_collecting_samples_by_appointment_only"
        ,"is_processing_samples"
        ,"is_processing_samples_onsite"
        ,"is_processing_samples_for_others"
        ,"location_specific_testing_criteria"
        ,"additional_information_for_patients"
        ,"reference_publisher_of_criteria"
        ,"data_source"
        ,"created_on"
        ,"updated_on"
        ,"deleted_on"
        ,"raw_data"
        ,"location_status"
        ,"external_location_id"
      FROM "updated_entities"
      ON CONFLICT ("location_id") DO UPDATE
        SET
          "location_id" = EXCLUDED."location_id"
          ,"is_hidden" = EXCLUDED."is_hidden"
          ,"is_verified" = EXCLUDED."is_verified"
          ,"location_name" = EXCLUDED."location_name"
          ,"location_address_street" = EXCLUDED."location_address_street"
          ,"location_address_locality" = EXCLUDED."location_address_locality"
          ,"location_address_region" = EXCLUDED."location_address_region"
          ,"location_address_postal_code" = EXCLUDED."location_address_postal_code"
          ,"location_latitude" = EXCLUDED."location_latitude"
          ,"location_longitude" = EXCLUDED."location_longitude"
          ,"location_contact_phone_main" = EXCLUDED."location_contact_phone_main"
          ,"location_contact_phone_appointments" = EXCLUDED."location_contact_phone_appointments"
          ,"location_contact_phone_covid" = EXCLUDED."location_contact_phone_covid"
          ,"location_contact_url_main" = EXCLUDED."location_contact_url_main"
          ,"location_contact_url_covid_info" = EXCLUDED."location_contact_url_covid_info"
          ,"location_contact_url_covid_screening_tool" = EXCLUDED."location_contact_url_covid_screening_tool"
          ,"location_contact_url_covid_virtual_visit" = EXCLUDED."location_contact_url_covid_virtual_visit"
          ,"location_contact_url_covid_appointments" = EXCLUDED."location_contact_url_covid_appointments"
          ,"location_place_of_service_type" = EXCLUDED."location_place_of_service_type"
          ,"location_hours_of_operation" = EXCLUDED."location_hours_of_operation"
          ,"is_evaluating_symptoms" = EXCLUDED."is_evaluating_symptoms"
          ,"is_evaluating_symptoms_by_appointment_only" = EXCLUDED."is_evaluating_symptoms_by_appointment_only"
          ,"is_ordering_tests" = EXCLUDED."is_ordering_tests"
          ,"is_ordering_tests_only_for_those_who_meeting_criteria" = EXCLUDED."is_ordering_tests_only_for_those_who_meeting_criteria"
          ,"is_collecting_samples" = EXCLUDED."is_collecting_samples"
          ,"is_collecting_samples_onsite" = EXCLUDED."is_collecting_samples_onsite"
          ,"is_collecting_samples_for_others" = EXCLUDED."is_collecting_samples_for_others"
          ,"is_collecting_samples_by_appointment_only" = EXCLUDED."is_collecting_samples_by_appointment_only"
          ,"is_processing_samples" = EXCLUDED."is_processing_samples"
          ,"is_processing_samples_onsite" = EXCLUDED."is_processing_samples_onsite"
          ,"is_processing_samples_for_others" = EXCLUDED."is_processing_samples_for_others"
          ,"location_specific_testing_criteria" = EXCLUDED."location_specific_testing_criteria"
          ,"additional_information_for_patients" = EXCLUDED."additional_information_for_patients"
          ,"reference_publisher_of_criteria" = EXCLUDED."reference_publisher_of_criteria"
          ,"data_source" = EXCLUDED."data_source"
          ,"raw_data" = EXCLUDED."raw_data"
          ,"geojson" = EXCLUDED."geojson"
          ,"created_on" = EXCLUDED."created_on"
          ,"updated_on" = CURRENT_TIMESTAMP
          ,"deleted_on" = EXCLUDED."deleted_on"
          ,"location_status" = EXCLUDED."location_status"
          ,"external_location_id" = EXCLUDED."external_location_id"
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
      
      UPDATE entities SET "is_hidden" = TRUE WHERE "location_name" = '';

      -- UPDATE entities SET "external_location_id" = '' ;
      
      ---- Clean up 
      TRUNCATE TABLE entities_proc;
    END;
$$
  LANGUAGE plpgsql
  RETURNS NULL ON NULL INPUT -- the function is NOT executed when there are null arguments
  PARALLEL UNSAFE
;
