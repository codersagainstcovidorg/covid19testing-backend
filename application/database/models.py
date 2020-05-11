from flask_sqlalchemy import SQLAlchemy
from flask import current_app as app
from sqlalchemy.dialects.postgresql import DOUBLE_PRECISION, JSONB
from datetime import datetime, timezone
import uuid
from flask_migrate import Migrate, MigrateCommand


# DB client
db = SQLAlchemy(app)
migrate = Migrate(app, db)

"""
Type reference
["ARRAY","BIGINT","BINARY","BLOB","BOOLEAN","BigInteger","Binary","Boolean","CHAR","CLOB","Concatenable","DATE","DATETIME","DECIMAL","Date","DateTime","Enum","FLOAT","Float","INT","INTEGER","Indexable","Integer","Interval","JSON",
"LargeBinary","MatchType","NCHAR","NULLTYPE","NUMERIC","NVARCHAR","NullType","Numeric","PickleType","REAL","SMALLINT","STRINGTYPE","SchemaType","SmallInteger","String","TEXT","TIME","TIMESTAMP","Text","Time","TypeDecorator","TypeEngine",
"Unicode","UnicodeText","UserDefinedType","VARBINARY","VARCHAR","Variant"]
"""

# Generate values for default values
def gen_uuid():
  return str(uuid.uuid4())

def gen_tz():
  return datetime.now(timezone.utc)


class Entities(db.Model):
  __table_name__ = 'entities'

  # "record_id" SERIAL NOT NULL UNIQUE,
  record_id = db.Column(db.Integer, 
                  primary_key=True)
  # "location_id" TEXT NOT NULL DEFAULT uuid_in(md5(random()::text || now()::text)::cstring),
  location_id = db.Column(db.Text,
                  index=True,
                  unique=False,
                  nullable=False,
                  default=gen_uuid)
  # "external_location_id" TEXT DEFAULT NULL
  external_location_id = db.Column(db.Text,
                  index=False,
                  unique=False,
                  nullable=True)
  # "is_hidden" BOOLEAN NOT NULL DEFAULT true,
  is_hidden = db.Column(db.Boolean,
                  nullable=False,
                  default=True)
  # "is_verified" BOOLEAN NOT NULL DEFAULT false,
  is_verified = db.Column(db.Boolean,
                  nullable=False,
                  default=False)
  # "location_name" TEXT,
  location_name = db.Column(db.Text,
                  nullable=True)
  # "location_address_street" VARCHAR(255) DEFAULT NULL,
  location_address_street = db.Column(db.String(255),
                  nullable=True)
  # "location_address_locality" VARCHAR(255) DEFAULT NULL,
  location_address_locality = db.Column(db.String(255),
                  nullable=True)
  # "location_address_region" VARCHAR(255) DEFAULT NULL,
  location_address_region = db.Column(db.String(255),
                  nullable=True)
  # "location_address_postal_code" VARCHAR(255) DEFAULT NULL,
  location_address_postal_code = db.Column(db.String(255),
                  nullable=True)
  # "location_latitude" double precision DEFAULT NULL,
  location_latitude = db.Column(DOUBLE_PRECISION,
                  nullable=True)
  # "location_longitude" double precision DEFAULT NULL,
  location_longitude = db.Column(DOUBLE_PRECISION,
                  nullable=True)
  # "location_contact_phone_main" VARCHAR(255) DEFAULT NULL,
  location_contact_phone_main = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_phone_appointments" VARCHAR(255) DEFAULT NULL,
  location_contact_phone_appointments = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_phone_covid" VARCHAR(255) DEFAULT NULL,
  location_contact_phone_covid = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_main" TEXT DEFAULT NULL,
  location_contact_url_main = db.Column(db.Text,
                  nullable=True)
  # "location_contact_url_covid_info" TEXT DEFAULT NULL,
  location_contact_url_covid_info = db.Column(db.Text,
                  nullable=True)
  # "location_contact_url_covid_screening_tool" TEXT DEFAULT NULL,
  location_contact_url_covid_screening_tool = db.Column(db.Text,
                  nullable=True)
  # "location_contact_url_covid_virtual_visit" TEXT DEFAULT NULL,
  location_contact_url_covid_virtual_visit = db.Column(db.Text,
                  nullable=True)
  # "location_contact_url_covid_appointments" TEXT DEFAULT NULL,
  location_contact_url_covid_appointments = db.Column(db.Text,
                  nullable=True)
  # "location_place_of_service_type" VARCHAR(255) DEFAULT NULL,
  location_place_of_service_type = db.Column(db.String(255),
                  nullable=True)
  # "location_hours_of_operation" VARCHAR(255) DEFAULT NULL,
  location_hours_of_operation = db.Column(db.Text,
                  nullable=True)
  # "is_evaluating_symptoms" BOOLEAN,
  is_evaluating_symptoms = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_evaluating_symptoms_by_appointment_only" BOOLEAN,
  is_evaluating_symptoms_by_appointment_only = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_ordering_tests" BOOLEAN,
  is_ordering_tests = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_ordering_tests_only_for_those_who_meeting_criteria" BOOLEAN,
  is_ordering_tests_only_for_those_who_meeting_criteria = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_collecting_samples" BOOLEAN,
  is_collecting_samples = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_collecting_samples_onsite" BOOLEAN,
  is_collecting_samples_onsite = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_collecting_samples_for_others" BOOLEAN,
  is_collecting_samples_for_others = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_collecting_samples_by_appointment_only" BOOLEAN,
  is_collecting_samples_by_appointment_only = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_processing_samples" BOOLEAN,
  is_processing_samples = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_processing_samples_onsite" BOOLEAN,
  is_processing_samples_onsite = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "is_processing_samples_for_others" BOOLEAN,
  is_processing_samples_for_others = db.Column(db.Boolean,
                  nullable=True,
                  default=False)
  # "location_specific_testing_criteria" TEXT DEFAULT NULL,
  location_specific_testing_criteria = db.Column(db.Text,
                  nullable=True)
  # "additional_information_for_patients" TEXT DEFAULT NULL,
  additional_information_for_patients = db.Column(db.Text,
                  nullable=True)
  # "reference_publisher_of_criteria" TEXT DEFAULT NULL,
  reference_publisher_of_criteria = db.Column(db.Text,
                  nullable=True)
  # "data_source" TEXT DEFAULT NULL,
  data_source = db.Column(db.Text,
                  nullable=True)
  # "raw_data" TEXT DEFAULT NULL,
  raw_data = db.Column(db.Text,
                  nullable=True)
  # "geojson" JSONB DEFAULT NULL,
  geojson = db.Column(JSONB,
                  nullable=True)
  # "created_on" TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_on = db.Column(db.DateTime(timezone=True), 
                  nullable=False,
                  default=gen_tz)
  # "updated_on" TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_on = db.Column(db.DateTime(timezone=True), 
                  nullable=False,
                  default=gen_tz)
  # "deleted_on" TIMESTAMPTZ,
  deleted_on = db.Column(db.DateTime(timezone=True), 
                  nullable=True)
  # "location_status" TEXT DEFAULT 'Active'::text,
  location_status = db.Column(db.Text,
                  nullable=True)
  # "external_location_id" TEXT
  external_location_id = db.Column(db.Text,
                              nullable=True)
