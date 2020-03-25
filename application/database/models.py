from flask_sqlalchemy import SQLAlchemy
from flask import current_app as app
from flask_migrate import Migrate

# Create client
db = SQLAlchemy()

# Init DB client
db.init_app(app)
migrate = Migrate(app, db)

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
  is_hidden = db.Column(db.String(255),
                  nullable=True)
  # "is_verified" VARCHAR(255) DEFAULT NULL,
  is_verified = db.Column(db.String(255),
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
  # "location_longitude" double precision DEFAULT NULL,
  location_longitude = db.Column(db.Numeric(precision=64),
                  nullable=True)
  # "location_latitude" double precision DEFAULT NULL,
  location_latitude = db.Column(db.Numeric(precision=64),
                  nullable=True)
  # "location_contact_phone_main" VARCHAR(255) DEFAULT NULL,
  location_contact_phone_main = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_phone_appointments" VARCHAR(255) DEFAULT NULL,
  location_contact_phone_appointments = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_main" VARCHAR(255) DEFAULT NULL,
  location_contact_url_main = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_appointments" VARCHAR(255) DEFAULT NULL,
  location_contact_url_appointments = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_self_screening" VARCHAR(255) DEFAULT NULL,
  location_contact_url_self_screening = db.Column(db.String(255),
                  nullable=True)
  # "location_contact_url_telemedicine" VARCHAR(255) DEFAULT NULL,
  location_contact_url_telemedicine = db.Column(db.String(255),
                  nullable=True)
  # "location_place_of_service_type" VARCHAR(255) DEFAULT NULL,
  location_place_of_service_type = db.Column(db.String(255),
                  nullable=True)
  # "location_hours_of_operation" VARCHAR(255) DEFAULT NULL,
  location_hours_of_operation = db.Column(db.String(255),
                  nullable=True)
  # "is_location_authorized_to_request_testing" VARCHAR(255) DEFAULT NULL,
  is_location_authorized_to_request_testing = db.Column(db.String(255),
                  nullable=True)
  # "is_location_accepting_third_party_orders_for_testing" VARCHAR(255) DEFAULT NULL,
  is_location_accepting_third_party_orders_for_testing = db.Column(db.String(255),
                  nullable=True)
  # "is_location_collecting_specimens" VARCHAR(255) DEFAULT NULL,
  is_location_collecting_specimens = db.Column(db.String(255),
                  nullable=True)
  # "is_location_only_testing_patients_that_meet_criteria" VARCHAR(255) DEFAULT NULL,
  is_location_only_testing_patients_that_meet_criteria = db.Column(db.String(255),
                  nullable=True)
  # "is_location_by_appointment_only" VARCHAR(255) DEFAULT NULL,
  is_location_by_appointment_only = db.Column(db.String(255),
                  nullable=True)
  # "location_specific_testing_criteria" TEXT DEFAULT NULL,
  location_specific_testing_criteria = db.Column(db.Text,
                  nullable=True)
  # "additional_information_for_patients" TEXT DEFAULT NULL,
  additional_information_for_patients = db.Column(db.Text,
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
