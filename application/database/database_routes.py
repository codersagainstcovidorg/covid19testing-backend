from flask import Blueprint, jsonify, make_response
from .models import Entities, db
import json
from datetime import datetime
from pprint import pprint

# Create blueprint
database_bp = Blueprint('database', __name__)

@database_bp.route('/api/v1/location', methods=['GET'])
def list_location():
  """
  list all locations
  """
  table_data = Entities.query.order_by(Entities.record_id).all()
  data_list = []
  # TODO: create a serializer function 
  for data in table_data:
    data_list.append(
      {
        'additional_information_for_patients': data.additional_information_for_patients,
        'created_on': data.created_on,
        'data_source': data.data_source,
        'deleted_on': data.deleted_on,
        'geojson': data.geojson,
        'is_collecting_samples': data.is_collecting_samples,
        'is_collecting_samples_by_appointment_only': data.is_collecting_samples_by_appointment_only,
        'is_collecting_samples_for_others': data.is_collecting_samples_for_others,
        'is_collecting_samples_onsite': data.is_collecting_samples_onsite,
        'is_evaluating_symptoms': data.is_evaluating_symptoms,
        'is_evaluating_symptoms_by_appointment_only': data.is_evaluating_symptoms_by_appointment_only,
        'is_hidden': data.is_hidden,
        'is_ordering_tests': data.is_ordering_tests,
        'is_ordering_tests_only_for_those_who_meeting_criteria': data.is_ordering_tests_only_for_those_who_meeting_criteria,
        'is_processing_samples': data.is_processing_samples ,
        'is_processing_samples_for_others': data.is_processing_samples_for_others,
        'is_processing_samples_onsite': data.is_processing_samples_onsite,
        'is_verified': data.is_verified,
        'location_address_locality': data.location_address_locality,
        'location_address_postal_code': data.location_address_postal_code,
        'location_address_region': data.location_address_region,
        'location_address_street': data.location_address_street,
        'location_contact_phone_appointments': data.location_contact_phone_appointments,
        'location_contact_phone_covid': data.location_contact_phone_covid,
        'location_contact_phone_main': data.location_contact_phone_main,
        'location_contact_url_covid_appointments': data.location_contact_url_covid_appointments,
        'location_contact_url_covid_info': data.location_contact_url_covid_info,
        'location_contact_url_covid_screening_tool': data.location_contact_url_covid_screening_tool,
        'location_contact_url_covid_virtual_visit': data.location_contact_url_covid_virtual_visit,
        'location_contact_url_main': data.location_contact_url_main,
        'location_hours_of_operation': data.location_hours_of_operation,
        'location_id': data.location_id,
        'location_latitude': data.location_latitude,
        'location_longitude': data.location_longitude,
        'location_name': data.location_name,
        'location_place_of_service_type': data.location_place_of_service_type,
        'location_specific_testing_criteria': data.location_specific_testing_criteria,
        'raw_data': data.raw_data,
        'reference_publisher_of_criteria': data.reference_publisher_of_criteria,
        'updated_on': data.updated_on,
        'record_id': data.record_id
      }
    )
  

  return jsonify(data_list)

@database_bp.route('/api/v1/location', methods=['POST'])
def create_location():
  """
  create new location
  """
  try:
    data = Entities(
      location_id="test", 
      location_name="test center", 
      geojson=json.dumps({"test": "test1"}),
      created_on=datetime.datetime.utcnow(),
      updated_on=datetime.datetime.utcnow(),
      is_hidden=True,
      is_verified=False

    )
    db.session.add(data)
    db.session.commit()
    return jsonify(result="ok")
  except Exception as e:
    print(e)
    # todo: return response codes
    return jsonify(result="failed")
  

@database_bp.route('/api/v1/location/<id>', methods=['GET'])
def get_location(id):
  pass

@database_bp.route('/api/v1/location/<id>', methods=['POST'])
def update_location(id):
  pass


# Insert data
@database_bp.route('/api/v1/insert', methods=['POST'])
def insert():
  """
  Insert data into DB
  Method: Post
  Path: /api/v1/insert
  """
  try:
    test_data = Entities(
      location_id="test", 
      location_name="test center", 
      geojson=json.dumps({"test": "test1"}),
      created_on=""
    )
    db.session.add(test_data)
    db.session.commit()
    return jsonify(result="ok")
  except Exception as e:
    print(e)
    return make_response(string(e))

# Update
@database_bp.route('/api/v1/update', methods=['POST'])
def update():
  """
  Update data
  Method: Post
  Path: /api/v1/update
  """
  try:
    test_data = Entities(
      location_id="test", 
      location_name="test center", 
      geojson=json.dumps({"test": "test1"}),
      created_on=""
    )
    db.session.add(test_data)
    db.session.commit()
    return jsonify(result="ok")
  except Exception as e:
    print(e)
    return make_response(string(e))