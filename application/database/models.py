from flask_sqlalchemy import SQLAlchemy
from flask import current_app as app
from flask_migrate import Migrate

# Create client
db = SQLAlchemy()

# Init DB client
db.init_app(app)
migrate = Migrate(app, db)

"""
Type reference
["ARRAY","BIGINT","BINARY","BLOB","BOOLEAN","BigInteger","Binary","Boolean","CHAR","CLOB","Concatenable","DATE","DATETIME","DECIMAL","Date","DateTime","Enum","FLOAT","Float","INT","INTEGER","Indexable","Integer","Interval","JSON",
"LargeBinary","MatchType","NCHAR","NULLTYPE","NUMERIC","NVARCHAR","NullType","Numeric","PickleType","REAL","SMALLINT","STRINGTYPE","SchemaType","SmallInteger","String","TEXT","TIME","TIMESTAMP","Text","Time","TypeDecorator","TypeEngine",
"Unicode","UnicodeText","UserDefinedType","VARBINARY","VARCHAR","Variant"]
"""

class Entities(db.Model):
  __table_name__ = 'entities'

  # "record_id" SERIAL NOT NULL UNIQUE,
  record_id = db.Column(db.Integer, 
                  primary_key=True)
  # "location_id" TEXT NOT NULL,
  location_id = db.Column(db.Text,
                  index=True,
                  unique=False,
                  nullable=False)
  # "is_hidden" VARCHAR(255) DEFAULT NULL,
  is_hidden = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_verified" VARCHAR(255) DEFAULT NULL,
  is_verified = db.Column(db.Boolean(255),
                  nullable=True)
  # "location_name" VARCHAR(255) DEFAULT NULL,
  location_name = db.Column(db.String(255),
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
  location_latitude = db.Column(db.Numeric(precision=64),
                  nullable=True)
  # "location_longitude" double precision DEFAULT NULL,
  location_longitude = db.Column(db.Numeric(precision=64),
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
  # "location_contact_url_main" VARCHAR(255) DEFAULT NULL,
  location_contact_url_main = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_covid_info" VARCHAR(255) DEFAULT NULL,
  location_contact_url_covid_info = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_covid_screening_tool" VARCHAR(255) DEFAULT NULL,
  location_contact_url_covid_screening_tool = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_covid_virtual_visit" VARCHAR(255) DEFAULT NULL,
  location_contact_url_covid_virtual_visit = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_covid_appointments" VARCHAR(255) DEFAULT NULL,
  location_contact_url_covid_appointments = db.Column(db.String(255),
                  nullable=True)
  # "location_place_of_service_type" VARCHAR(255) DEFAULT NULL,
  location_place_of_service_type = db.Column(db.String(255),
                  nullable=True)
  # "location_hours_of_operation" VARCHAR(255) DEFAULT NULL,
  location_hours_of_operation = db.Column(db.String(255),
                  nullable=True)
  # "is_evaluating_symptoms" VARCHAR(255) DEFAULT NULL,
  is_evaluating_symptoms = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_evaluating_symptoms_by_appointment_only" VARCHAR(255) DEFAULT NULL,
  is_evaluating_symptoms_by_appointment_only = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_ordering_tests" VARCHAR(255) DEFAULT NULL,
  is_ordering_tests = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_ordering_tests_only_for_those_who_meeting_criteria" VARCHAR(255) DEFAULT NULL,
  is_ordering_tests_only_for_those_who_meeting_criteria = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_collecting_samples" VARCHAR(255) DEFAULT NULL,
  is_collecting_samples = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_collecting_samples_onsite" VARCHAR(255) DEFAULT NULL,
  is_collecting_samples_onsite = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_collecting_samples_for_others" VARCHAR(255) DEFAULT NULL,
  is_collecting_samples_for_others = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_collecting_samples_by_appointment_only" VARCHAR(255) DEFAULT NULL,
  is_collecting_samples_by_appointment_only = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_processing_samples" VARCHAR(255) DEFAULT NULL,
  is_processing_samples = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_processing_samples_onsite" VARCHAR(255) DEFAULT NULL,
  is_processing_samples_onsite = db.Column(db.Boolean(255),
                  nullable=True)
  # "is_processing_samples_for_others" VARCHAR(255) DEFAULT NULL,
  is_processing_samples_for_others = db.Column(db.Boolean(255),
                  nullable=True)
  # "location_specific_testing_criteria" VARCHAR(255) DEFAULT NULL,
  location_specific_testing_criteria = db.Column(db.String(255),
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
  geojson = db.Column(db.JSON,
                  nullable=True)
  # "created_on" TIMESTAMPTZ,
  created_on = db.Column(db.DateTime(timezone=True), 
                  nullable=False)
  # "updated_on" TIMESTAMPTZ,
  updated_on = db.Column(db.DateTime(timezone=True), 
                  nullable=False)
  # "deleted_on" TIMESTAMPTZ,
  deleted_on = db.Column(db.DateTime(timezone=True), 
                  nullable=False)
