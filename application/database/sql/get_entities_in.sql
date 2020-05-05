-- Returns records in `entities` table within specified geom
-- ENVIRONMENTS --
--   staging
--   production
-- DEPENDENCIES --
--   Objects: entities
--   Functions: None
-- DEFAULTS --
--   radius: 10.0
--   max_radius: NULL (defaults to value `radius`)
--   increment_radius: 5.0
CREATE OR REPLACE FUNCTION get_entities_in(
    IN center_longitude                                 double precision
    ,IN center_latitude                                 double precision
    ,IN radius                                          double precision DEFAULT 10.0 -- Start search using this radius
    ,IN max_radius                                      double precision DEFAULT -1.0 -- Repeat search if no results until this value is reached
    ,IN increment_radius                                double precision DEFAULT 5.0 -- Expand radius by this value per iteration

  )
  RETURNS SETOF "entities"
  AS $$
    DECLARE
      current_radius double precision := radius ;
      done boolean := false ;
    BEGIN
      RAISE NOTICE E'`max_radius` == %', max_radius;
      IF (max_radius <= 0.0) THEN 
        max_radius := current_radius; 
      END IF;
      
      WHILE (current_radius <= max_radius) AND NOT done LOOP
        RAISE NOTICE E'`current_radius` == %', current_radius;
        RETURN QUERY SELECT 
                        entities.*
                      FROM 
                        entities
                        ,point("location_longitude","location_latitude") AS "location_point"
                      WHERE (point(center_longitude,center_latitude) <@> "location_point") <= current_radius;

        -- Since execution is not finished, we can check whether rows were returned
        -- and expand our search radius if not
        IF NOT FOUND THEN
            current_radius := current_radius + increment_radius;
        ELSE done := true;
        END IF;
      END LOOP;
      
      RETURN;
    END;
  $$
  LANGUAGE plpgsql
  RETURNS NULL ON NULL INPUT -- the function is NOT executed when there are null arguments
  PARALLEL SAFE
;
