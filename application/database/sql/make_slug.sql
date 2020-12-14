-- Returns that is generated from the string that is passed as a parameter
-- ENVIRONMENTS --
--   staging
-- DEPENDENCIES --
--   Objects: None
--   Functions: None
--   Extensions: unaccent
-- DEFAULTS --
--   None

CREATE OR REPLACE FUNCTION make_slug(
    IN fromString         text
    ,IN prefix            text DEFAULT ''
  )
  RETURNS TEXT
  AS $$
    DECLARE
      slug TEXT := CONCAT(prefix, ' ', fromString);
    BEGIN
      -- SELECT unaccent(fromString) INTO slug; -- Removes accents (diacritic signs)
      SELECT lower(TRIM(slug)) INTO slug; -- Make lowercase and trim leading and trailing spaces
      SELECT regexp_replace(slug, '[''"]+', '', 'gi') INTO slug; -- Remove single and double quotes
      SELECT regexp_replace(slug, '&', '-and-', 'g') INTO slug; -- Replace & with 'and'
      SELECT regexp_replace(slug, '[^a-z0-9\\-_]+', '-', 'gi') INTO slug; -- Replace anything that's not a letter, number, hyphen('-'), or underscore('_') with a hyphen('-')
      SELECT regexp_replace(slug, '[\-]+', '-') INTO slug; -- Replace multiple - with single -
      SELECT regexp_replace(regexp_replace(slug, '\-+$', ''), '^\-', '') INTO slug; -- Trim hyphens('-') if they exist on the head or tail of the string
      RETURN slug;
    END;
  $$
  LANGUAGE plpgsql
  RETURNS NULL ON NULL INPUT -- the function is NOT executed when there are null arguments
  IMMUTABLE
  PARALLEL SAFE
;

