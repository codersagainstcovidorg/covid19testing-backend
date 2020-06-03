  -- Takes raw data from `data_ingest` and runs it through ETL process
  -- ENVIRONMENTS --
  --   staging
  -- DEPENDENCIES --
  --   Objects: entities, data_ingest
  --   Functions: update_entities
  -- DEFAULTS --
  --   data_source_name: 'giscorps'
  CREATE OR REPLACE FUNCTION ingest_data(
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
        ---- Extract and translate into temp schema ----------------------
        ------------------------------------------------------------------
        
        ---- Create temporary table to hold ingested data while we work
        CREATE TEMP TABLE IF NOT EXISTS ingest_giscorps (
            "OBJECTID" text PRIMARY KEY,
            "location_id" text,
            -- "facilityid" text,
            -- "GlobalID" text,
            "name" text,
            "address" text,
            "phone" text,
            "period_start" date,
            "period_end" date,
            "hours_of_operation" text,
            "managing_organization" text,
            "managing_organization_kind" text,
            "managing_organization_url" text,
            "health_dept_url" text,
            "status" text,
            "services_offered_onsite" text,
            "test_kind" text,
            "test_processing" text,
            "is_flagged" boolean,
            "is_appt_only" boolean,
            "is_call_first" boolean,
            "is_referral_required" boolean,
            "is_screening_onsite" boolean,
            "is_collecting_onsite" boolean,
            "is_virtual_screening_offered" boolean,
            "is_virtual_screening_required" boolean,
            "is_drive_through" boolean,
            "data_source" text,
            "EditDate" TIMESTAMP,
            "CreationDate" TIMESTAMP,
            "testcapacity" numeric,
            "numvehicles" numeric,
            "municipality" text,
            "county" text,
            "state" text,
            "lat" double precision,
            "long" double precision,
            "vol_note" text,
            "fine_print" text,
            "instructions" text,
            "comments" text,
            "raw_data" jsonb
        );
        TRUNCATE TABLE "ingest_giscorps" RESTART IDENTITY; -- Truncate existing table (if already existed for whatever reason)

        ---- Extract and translate
        WITH source AS (
          SELECT
          "data"#>>'{attributes,OBJECTID}' AS "OBJECTID"
          ,"data"#>'{geometry}' AS "geometry"
          ,"data"#>'{attributes}' AS "attr"
          ,"data" AS "raw_data"
          FROM 
            data_ingest
        )
        INSERT INTO ingest_giscorps (
          "OBJECTID",
          -- "facilityid",
          -- "GlobalID",
          "location_id",
          "name",
          "address",
          "phone",
          "period_start",
          "period_end",
          "hours_of_operation",
          "managing_organization",
          "managing_organization_kind",
          "managing_organization_url",
          "health_dept_url",  
          "status",
          "services_offered_onsite",
          "test_kind",
          "test_processing",
          "is_flagged",
          "is_appt_only",
          "is_call_first",
          "is_referral_required",
          "is_screening_onsite",
          "is_collecting_onsite",
          "is_virtual_screening_offered",
          "is_virtual_screening_required",
          "is_drive_through",
          "data_source",
          "EditDate",
          "CreationDate",
          "testcapacity",
          "numvehicles",
          "municipality",
          "county",
          "state",
          "lat",
          "long",
          "vol_note",
          "fine_print",
          "instructions",
          "comments",
          "raw_data"
        )
        SELECT 
          "OBJECTID",
          -- "facilityid",
          -- "GlobalID",
          CASE
            WHEN (NULLIF(TRIM("OBJECTID"::TEXT), '') IS NOT NULL)
              THEN uuid_in(md5((TRIM("OBJECTID"::TEXT)))::cstring)
            WHEN ((COALESCE(("geometry" #>> '{Latitude}'),("geometry" #>> '{y}'))::double precision IS NOT NULL) AND (COALESCE(("geometry" #>> '{Longitude}'),("geometry" #>> '{x}'))::double precision IS NOT NULL))
              THEN uuid_in(
                md5(
                  (
                    "OBJECTID" ||
                    round((COALESCE(("geometry" #>> '{Latitude}'),("geometry" #>> '{y}'))::numeric), 6)::text || 
                    round((COALESCE(("geometry" #>> '{Longitude}'),("geometry" #>> '{x}'))::numeric), 6)::text
                  )
                  )::cstring
                )
            ELSE NULL
          END AS "location_id",
          
          COALESCE(TRIM("attr"#>>'{name}'), '') AS "name",
          COALESCE(TRIM("attr"#>>'{fulladdr}'), '') AS "address",
          COALESCE(TRIM("attr"#>>'{phone}'), '') AS "phone",
          COALESCE(to_timestamp((("attr"#>>'{start_date}')::double precision) / 1000)::date,
                    to_timestamp((("attr"#>>'{CreationDate}')::double precision) / 1000)::date) AS "period_start",
          COALESCE((to_timestamp((("attr"#>>'{end_date}')::double precision) / 1000)::date), '9999-12-31'::DATE) AS "period_end",
          COALESCE(TRIM("attr"#>>'{operhours}'), '') AS "hours_of_operation",
          COALESCE(TRIM("attr"#>>'{agency}'), '') AS "managing_organization",
          COALESCE(TRIM("attr"#>>'{agencytype}'), '') AS "managing_organization_kind",
          COALESCE(TRIM("attr"#>>'{agencyurl}'), '') AS "managing_organization_url",
          COALESCE(TRIM("attr"#>>'{health_dept_url}'), '') AS "health_dept_url",
          COALESCE(TRIM("attr"#>>'{status}'), '') AS "status",
          COALESCE(TRIM("attr"#>>'{services_offered_onsite}'), '') AS "services_offered_onsite",
          COALESCE(NULLIF(TRIM("attr"#>>'{type_of_test}'), ''),NULLIF(TRIM("attr"#>>'{test_type}'), ''), '') AS "test_kind",
          COALESCE(TRIM("attr"#>>'{test_processing}'), '') AS "test_processing",
          COALESCE(TRIM("attr"#>>'{red_flag}'), '') = 'Yes' AS "is_flagged",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{appt_only}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{appt_only}') = 'Yes' 
            ELSE TRUE -- Default value
          END AS "is_appt_only",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{call_first}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{call_first}') = 'Yes' 
            ELSE TRUE -- Default value
          END AS "is_call_first",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{referral_required}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{referral_required}') = 'Yes' 
            WHEN (NULLIF(TRIM("attr"#>>'{services_offered_onsite}'), '') IS NOT NULL) THEN ("attr"#>>'{services_offered_onsite}') NOT LIKE ('%creen%')
            ELSE FALSE -- Default value
          END AS "is_referral_required",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{services_offered_onsite}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{services_offered_onsite}') LIKE ('%creen%')
            ELSE FALSE -- Default value
          END AS "is_screening_onsite",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{services_offered_onsite}'), '') IS NOT NULL) THEN LOWER(TRIM("attr"#>>'{services_offered_onsite}')) LIKE ('%test%')
            ELSE FALSE -- Default value
          END AS "is_collecting_onsite",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{virtual_screening}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{virtual_screening}') IN ('Available','Required')
            ELSE TRUE -- Default value
          END AS "is_virtual_screening_offered",
          
          CASE 
            WHEN (NULLIF(TRIM("attr"#>>'{virtual_screening}'), '') IS NOT NULL) THEN TRIM("attr"#>>'{virtual_screening}') IN ('Required')
            ELSE TRUE -- Default value
          END AS "is_virtual_screening_required",
          
          ("attr"#>>'{drive_through}') = 'Yes' AS "is_drive_through",
          
          COALESCE(TRIM("attr"#>>'{data_source}'), '') AS "data_source",
          
          COALESCE(to_timestamp(("attr"#>>'{EditDate}')::double precision / 1000), CURRENT_TIMESTAMP) AS "EditDate",
          
          COALESCE(to_timestamp(("attr"#>>'{CreationDate}')::double precision / 1000), CURRENT_TIMESTAMP) AS "CreationDate",
          
          TRIM("attr"#>>'{testcapacity}')::integer AS "testcapacity",
          
          TRIM("attr"#>>'{numvehicles}')::integer AS "numvehicles",
          
          TRIM("attr"#>>'{municipality}') AS "municipality",
          
          TRIM("attr"#>>'{county}') AS "county",
          
          TRIM("attr"#>>'{State}') AS "State",
          
          round((COALESCE(("geometry" #>> '{Latitude}'),("geometry" #>> '{y}'))::numeric), 6) AS "lat",
          
          round((COALESCE(("geometry" #>> '{Longitude}'),("geometry" #>> '{x}'))::numeric), 6) AS "long",
          
          TRIM("attr"#>>'{vol_note}') AS "vol_note",
          
          TRIM("attr"#>>'{fine_print}') AS "fine_print",
          
          TRIM("attr"#>>'{Instructions}') AS "instructions",
          
          TRIM("attr"#>>'{comments}') AS "comments",
          
          jsonb_strip_nulls("attr" - '{OBJECTID,facilityid,GlobalID,name,fulladdr,operhours,phone,agency,agencytype,agencyurl,health_dept_url,status,EditDate,CreationDate,appt_only,call_first,referral_required,data_source,municipality,State}'::text[]) 
            || jsonb_build_object(
              'is_opened_on_date_adjusted', (TRIM("attr"#>>'{start_date}') IS NOT NULL)
              ,'is_closed_on_date_adjusted', (TRIM("attr"#>>'{end_date}') IS NOT NULL)
            )
          AS "raw_data"
        FROM
          source
        ;
        
        ---- Transform `instructions` and `comments`
        UPDATE ingest_giscorps SET 
          "instructions" = CONCAT(
            CASE WHEN NULLIF(TRIM("managing_organization"), '') IS NOT NULL THEN CONCAT('The day-to-day operations at this location are overseen by ', TRIM("managing_organization"), '. ') ELSE NULL END 
            ,CASE WHEN (("hours_of_operation" NOT LIKE ('%all %')) AND NULLIF(TRIM("hours_of_operation"), '') IS NOT NULL) THEN CONCAT('Hours of operation are ', TRIM("hours_of_operation"),' but are subject to change without notice. ') ELSE NULL END 
            ,CASE 
              WHEN "is_appt_only" THEN 'Appointments are required at this location. ' 
            ELSE NULL END
            ,CASE 
              WHEN (TRIM("services_offered_onsite") = 'both') THEN 'The staff onsite are able to conduct screening assessments and collect samples for testing. ' 
              WHEN NULLIF(TRIM("services_offered_onsite"), '') IS NOT NULL THEN CONCAT('Onsite staff is able to offer ', TRIM("services_offered_onsite"), '. ')
            ELSE NULL END
            
            ,CASE WHEN "is_referral_required" THEN 'Testing is only performed for individuals who meet testing criteria. ' ELSE NULL END
            
            ,CASE 
              WHEN "test_kind" IN ('molecular') THEN 'This location offers molecular-based testing options, which are authorized by the FDA to diagnose or to rule out COVID-19. To our knowledge, antibody testing is not offered at this location.'
              WHEN "test_kind" IN ('both') THEN 'Although multiple testing options are offered at this location, please note that antibody tests are NOT authorized by the FDA to rule out COVID-19. This location also offers molecular-based options, which ARE authorized by the FDA for this purpose. '
              WHEN "test_kind" IN ('antibody','antibody-poc') THEN 'WARNING: This location DOES NOT appear to offer FDA-authorized tests for persons looking to definitely rule out COVID-19 infection. NO ANTIBODY TEST IS AUTHORIZED by the FDA to rule out COVID-19, a separate molecular-based test must be performed. '
              WHEN "test_kind" IN ('not specified', 'needs more research') THEN 'There is insufficient information to determine which testing options are offered at this location. '
            ELSE NULL END

            ,CASE WHEN (TRIM("status") IN ('Scheduled to Close', 'status')) THEN 
                CONCAT('ATTENTION: This location was ', LOWER(TRIM("status")),' as of our last check-in. If you believe this is no longer the case please let us know by submitting an error report. ')
              WHEN (TRIM("status") IN ('Closed','Temporarily Closed')) THEN 
                CONCAT('ATTENTION: This location is ', LOWER(TRIM("status")),' as of our last check-in. If you believe this is no longer the case please let us know by submitting an error report. ')
              WHEN (TRIM("status") IN ('Scheduled to Open')) THEN 
                CONCAT('ATTENTION: As of our last check-in, this location was closed, but ', LOWER(TRIM("status")),'. If you believe this is no longer the case please let us know by submitting an error report. ')
              WHEN (TRIM("status") IN ('Testing Restricted')) THEN 
                'ATTENTION: To our knowledge, this location only serves healthcare professionals, first responders, and others who are at the highest-risk of exposure to COVID-19. '
              ELSE 
                'This location was operating normally as of our last check-in. '
            END
            ,CONCAT('(Last verified: ', "EditDate"::DATE,')')
          )
          ,"comments" = 'As details are changing frequently, please verify this information by contacting the testing center. If you are experiencing extreme or dangerous symptoms (including trouble breathing), seek medical attention immediately.'
        ;

        ------------------------------------------------------------------
        ---- Transform and load into entities_proc -----------------------
        ------------------------------------------------------------------
        
        ---- Create temporary table to hold ingested data while we work
        DROP TABLE IF EXISTS entities_proc;
        CREATE TABLE IF NOT EXISTS entities_proc (
          record_id SERIAL PRIMARY KEY,
          location_id text NOT NULL DEFAULT uuid_in(md5(random()::text || now()::text)::cstring),
          is_hidden boolean NOT NULL DEFAULT true,
          is_verified boolean NOT NULL DEFAULT false,
          location_name text,
          location_address_street text,
          location_address_locality text,
          location_address_region text,
          location_address_postal_code text,
          location_latitude numeric,
          location_longitude numeric,
          location_contact_phone_main text,
          location_contact_phone_appointments text,
          location_contact_phone_covid text,
          location_contact_url_main text,
          location_contact_url_covid_info text,
          location_contact_url_covid_screening_tool text,
          location_contact_url_covid_virtual_visit text,
          location_contact_url_covid_appointments text,
          location_place_of_service_type text,
          location_hours_of_operation text,
          is_evaluating_symptoms boolean,
          is_evaluating_symptoms_by_appointment_only boolean,
          is_ordering_tests boolean,
          is_ordering_tests_only_for_those_who_meeting_criteria boolean,
          is_collecting_samples boolean,
          is_collecting_samples_onsite boolean,
          is_collecting_samples_for_others boolean,
          is_collecting_samples_by_appointment_only boolean,
          is_processing_samples boolean,
          is_processing_samples_onsite boolean,
          is_processing_samples_for_others boolean,
          location_specific_testing_criteria text,
          additional_information_for_patients text,
          reference_publisher_of_criteria text,
          data_source text,
          raw_data text,
          geojson json,
          created_on timestamp with time zone NOT NULL DEFAULT now(),
          updated_on timestamp with time zone NOT NULL DEFAULT now(),
          deleted_on timestamp with time zone,
          location_status text DEFAULT 'Active'::text,
          external_location_id text
        );
        TRUNCATE TABLE "entities_proc" RESTART IDENTITY; -- Truncate existing table
        CREATE UNIQUE INDEX entities_proc_location_id_idx ON entities_proc(location_id text_ops);
        CREATE UNIQUE INDEX entities_proc_location_id_external_location_id_idx ON entities_proc(location_id text_ops, external_location_id text_ops);
        
        WITH upd AS (
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
            ,"raw_data"
            ,"geojson"
            ,"created_on"
            ,"updated_on"
            ,"deleted_on"
            ,"location_status"
            ,"external_location_id"
          FROM (
            SELECT
              "location_id",
              
              CASE
                WHEN (
                  ("lat" IS NULL) OR ("long" IS NULL)
                  OR ("status" IN ('Not Publicly Shared', 'Invalid', '', 'Missing Data', ''))
                  OR ("status" IS NULL)
                ) THEN TRUE
                ELSE FALSE
              END AS "is_hidden"
              
              ,CASE
                WHEN (
                  ("lat" IS NULL) OR ("long" IS NULL)
                  OR ("status" IN ('Pending Review', 'Invalid', '', 'Missing Data', ''))
                  OR ("status" IS NULL)
                ) THEN FALSE
                ELSE TRUE
              END AS "is_verified"
              
              ,"name" AS "location_name"
              ,"address" AS "location_address_street"
              ,COALESCE("municipality", '') AS "location_address_locality"
              ,COALESCE("state", '') AS "location_address_region"
              ,'' AS "location_address_postal_code"
              ,"lat" AS "location_latitude"
              ,"long" AS "location_longitude"
              ,"phone" AS "location_contact_phone_main"
              ,"phone" AS "location_contact_phone_appointments"
              ,"phone" AS "location_contact_phone_covid"
              ,"managing_organization_url" AS "location_contact_url_main"
              ,"managing_organization_url" AS "location_contact_url_covid_info"
              ,'' AS "location_contact_url_covid_screening_tool"
              
              ,CASE 
                WHEN ("is_virtual_screening_offered" OR "is_virtual_screening_required") THEN TRIM("managing_organization_url") 
              END AS "location_contact_url_covid_virtual_visit"
              
              ,'' AS "location_contact_url_covid_appointments"
              ,"managing_organization_kind" AS "location_place_of_service_type"
              ,"hours_of_operation" AS "location_hours_of_operation"
              ,"period_start" AS "period_start"
              ,"period_end" AS "period_end"
              ,("is_screening_onsite" OR "is_virtual_screening_offered") AS "is_evaluating_symptoms"
              
              ,("is_screening_onsite" AND NOT("is_virtual_screening_offered") AND ("is_appt_only" OR "is_call_first")) AS "is_evaluating_symptoms_by_appointment_only"
              
              ,(NOT("is_collecting_onsite") AND ("is_screening_onsite" OR "is_virtual_screening_offered")) AS "is_ordering_tests"
              
              ,NULL::boolean AS "is_ordering_tests_only_for_those_who_meeting_criteria"
              
              ,"is_collecting_onsite" AS "is_collecting_samples"
              ,"is_collecting_onsite" AS "is_collecting_samples_onsite"
              
              ,("is_collecting_onsite" AND NOT("is_screening_onsite" OR "is_virtual_screening_offered")) AS "is_collecting_samples_for_others"
              
              ,("is_collecting_onsite" AND ("is_appt_only" OR "is_call_first")) AS "is_collecting_samples_by_appointment_only"
              
              ,"test_processing" IN ('point-of-care','onsite lab','offsite lab','lab') AS "is_processing_samples"
              
              ,"test_processing" IN ('point-of-care','onsite lab') AS "is_processing_samples_onsite"
              
              ,(NOT("is_collecting_onsite" OR "is_screening_onsite" OR "is_virtual_screening_offered") AND ("test_processing" IN ('point-of-care','onsite lab','lab'))) AS "is_processing_samples_for_others"
              
              ,"comments" AS "location_specific_testing_criteria"
              ,"instructions" AS "additional_information_for_patients"
              ,"health_dept_url" AS "reference_publisher_of_criteria"
              ,CONCAT('[GISCorps] ', TRIM("data_source")) AS "data_source"
              ,(jsonb_build_object(
                  'is_drive_through', "is_drive_through"
                  ,'is_flagged', "is_flagged"
                  -- ,'test_kind', (COALESCE(LOWER(TRIM("test_kind")), ''))
                  ,'is_same_day_result', (COALESCE(LOWER(TRIM("test_processing")), '') IN ('point-of-care'))
                  ,'is_temporary', ((("period_end"::DATE - CURRENT_DATE) - ("period_start"::DATE - CURRENT_DATE)) = 0)
                  ,'is_scheduled_to_open', ("period_start"::DATE > CURRENT_DATE)
                  ,'is_scheduled_to_close', ("period_end"::text) NOT LIKE ('9999%')
                  ,'days_remaining_until_open', GREATEST(("period_start"::DATE - CURRENT_DATE), 0)
                  ,'days_remaining_until_close', ("period_end"::DATE - CURRENT_DATE)
                  ,'period_start', "period_start"
                  ,'period_end', "period_end"
                  ,'does_offer_antibody_test', (COALESCE(LOWER(TRIM("test_kind")), '') IN ('antibody', 'antibody-poc', 'both', 'molecular and antibody'))
                  ,'does_offer_molecular_test', (COALESCE(LOWER(TRIM("test_kind")), '') IN ('molecular', 'both', 'molecular and antibody'))
                  ,'is_opened_on_date_adjusted', (ingest_giscorps."raw_data"#>>'{is_opened_on_date_adjusted}')::BOOLEAN
                  ,'is_opened_on_date_adjusted', (ingest_giscorps."raw_data"#>>'{is_opened_on_date_adjusted}')::BOOLEAN
                  ,'vol_note', COALESCE(TRIM("vol_note"), '')
                  ,'fine_print', COALESCE(TRIM("fine_print"), '')
                ) -- || "raw_data"::jsonb
              ) AS "raw_data"
              ,NULL::jsonb AS "geojson"
              ,"CreationDate" AS "created_on"
              ,"EditDate" AS "updated_on"
              ,CASE WHEN "status" = 'Closed' THEN "EditDate" ELSE NULL END AS "deleted_on"
              ,"status" AS "location_status"
              ,"OBJECTID" AS "external_location_id"
            FROM
              ingest_giscorps
            WHERE
              "status" NOT IN ('Not Publicly Shared', 'Invalid', 'Missing Data', 'Pending Review', 'NULL', '<Null>','') 
              AND "status" IS NOT NULL
            GROUP BY
              "OBJECTID",
              -- "facilityid",
              -- "GlobalID",
              "location_id",
              "name",
              "address",
              "phone",
              "period_start",
              "period_end",
              "hours_of_operation",
              "managing_organization",
              "managing_organization_kind",
              "managing_organization_url",
              "health_dept_url",  
              "status",
              "services_offered_onsite",
              "test_kind",
              "test_processing",
              "is_flagged",
              "is_appt_only",
              "is_call_first",
              "is_referral_required",
              "is_screening_onsite",
              "is_collecting_onsite",
              "is_virtual_screening_offered",
              "is_virtual_screening_required",
              "is_drive_through",
              "data_source",
              "EditDate",
              "CreationDate",
              "testcapacity",
              "numvehicles",
              "municipality",
              "county",
              "state",
              "lat",
              "long"
          )a
        )
        INSERT INTO "entities_proc" AS entities (
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
        SELECT DISTINCT
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
          upd
        WHERE
          ("location_latitude" IS NOT NULL) AND
          ("location_longitude" IS NOT NULL)
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
          ON CONFLICT ("location_id") DO UPDATE
            SET
              "location_id" = md5(CONCAT('DUPLICATE|',entities."location_latitude",'|',entities."location_longitude"))::uuid
              ,"is_hidden" = TRUE
              ,"is_verified" = FALSE
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
              ,"updated_on" = EXCLUDED."updated_on"
              ,"deleted_on" = EXCLUDED."deleted_on"
              ,"location_status" = EXCLUDED."location_status"
              ,"external_location_id" = EXCLUDED."external_location_id"
        ;
        
        ---- Clean up location URLs
        UPDATE entities_proc
        SET "location_contact_url_main" =  REGEXP_REPLACE(TRIM(location_contact_url_main), '^(\S+(?:[\.](?:org|com|edu|gov|net|us))\S*)','https://\1', 'i')
        WHERE
          location_contact_url_main NOT ILIKE 'http%'
        ;

        UPDATE entities_proc
        SET "location_contact_url_main" = ''
        WHERE
          location_contact_url_main NOT ILIKE 'http%'
        ;
        
        ---- Clean up health department URLs
        UPDATE entities_proc
        SET "reference_publisher_of_criteria" =  REGEXP_REPLACE(TRIM(reference_publisher_of_criteria), '^(\S+(?:[\.](?:org|com|edu|gov|net|us))\S*)','https://\1', 'i')
        WHERE
          reference_publisher_of_criteria NOT ILIKE 'http%'
        ;

        UPDATE entities_proc
        SET "reference_publisher_of_criteria" = ''
        WHERE
          reference_publisher_of_criteria NOT ILIKE 'http%'
        ;
        
        ---- Clean up dates of service
        UPDATE entities_proc -- Should be 'Scheduled to Open'
        SET "location_status" = 'Scheduled to Open'
        WHERE
          "location_status" NOT IN ('Scheduled to Open', 'Testing Restricted', 'Temporarily Closed', 'Closed', 'Impacted')
          AND "location_name" NOT ILIKE '%quest%'
          AND ("raw_data"::jsonb ->> 'period_start')::DATE > CURRENT_DATE
          AND ("raw_data"::jsonb ->> 'period_end')::DATE <> '9999-12-31'
          AND ("raw_data"::jsonb ->> 'period_end')::DATE >= CURRENT_DATE
        ;

        UPDATE entities_proc -- Should be 'Scheduled to Close'
        SET "location_status" = 'Scheduled to Close'
        WHERE
          location_status NOT IN ('Scheduled to Close', 'Scheduled to Open','Testing Restricted', 'Temporarily Closed', 'Closed', 'Impacted')
          AND "location_name" NOT ILIKE '%quest%'
          AND ("raw_data"::jsonb ->> 'period_start')::DATE >= CURRENT_DATE
          AND ("raw_data"::jsonb ->> 'period_end')::DATE <> '9999-12-31'
          AND ("raw_data"::jsonb ->> 'days_remaining_until_close')::INT <= 7
          AND ("raw_data"::jsonb ->> 'days_remaining_until_open')::INT <> ("raw_data"::jsonb ->> 'days_remaining_until_close')::INT
          AND ("raw_data"::jsonb ->> 'period_end')::DATE >= CURRENT_DATE
        ;

        UPDATE entities_proc -- Should be 'Open'
        SET location_status = 'Open'
        WHERE
          location_status NOT IN ('Open','Scheduled to Close','Testing Restricted', 'Temporarily Closed', 'Closed', 'Impacted')
          AND "location_name" NOT ILIKE '%quest%'
          AND (CURRENT_DATE - ("raw_data"::jsonb ->> 'period_start')::DATE) <= 7
          AND ("raw_data"::jsonb ->> 'days_remaining_until_open')::INT <= 0
        ;

        UPDATE entities_proc -- Should be 'Closed'
        SET location_status = 'Scheduled to Open'
        WHERE
          location_status NOT IN ('Closed','Temporarily Closed')
          AND "location_name" NOT ILIKE '%quest%'
          AND ("raw_data"::jsonb ->> 'period_end')::DATE <> '9999-12-31'
          AND (("raw_data"::jsonb ->> 'period_end')::DATE - CURRENT_DATE) < 0
        ;

        ---- Clean up phone numbers
        WITH upd_phone AS (
          SELECT DISTINCT
            location_id
            ,main_6 AS "main"
          FROM
            entities_proc
            ,regexp_replace(location_contact_phone_main, '[\+\s\-\.\(\)‐]', '', 'gim') AS "main_0"
            ,regexp_replace(main_0, '^([a-zA-Z]+.+)', '', 'gim') AS "main_1"
            ,regexp_replace(main_1, '^1?(\w{3,10})', '\1', 'gim') AS "main_2"
            ,regexp_replace(main_2, '^[a-zA-Z ]+', '', 'gim') AS "main_3"
            ,regexp_replace(main_3, '^(\d{3})(\d{3})(\d{4})', '\1-\2-\3', 'gim') AS "main_4"
            ,regexp_replace(main_4, '^(\d+(?=\D+))(\D+)$', '\1-\2', 'gim') AS "main_5"
            ,regexp_replace(main_5, '^(\d+\D+\d\D+)$', '', 'gim') AS "main_6"
        )
        UPDATE entities_proc
        SET location_contact_phone_main = main
        FROM upd_phone
        WHERE entities_proc.location_id = upd_phone.location_id
        ;
        
        ------------------------------------------------------------------
        ---- Propagate changes and clean up          ---------------------
        ------------------------------------------------------------------
        
        ---- Insert into `entities`
        PERFORM update_entities(data_source_name) ;
        
        ---- Clean up 
        DROP TABLE IF EXISTS ingest_giscorps;
        
        -- Remove processed values
        DELETE FROM data_ingest WHERE "data_source" = data_source_name OR "data_source" IS NULL; 

        ---- Communicate completion
        RAISE NOTICE E'Completed ETL process for `data_source` == %', data_source_name;

      END;
  $$
  LANGUAGE plpgsql
  RETURNS NULL ON NULL INPUT -- the function is NOT executed when there are null arguments
  PARALLEL UNSAFE
;
