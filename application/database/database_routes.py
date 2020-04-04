from flask import Blueprint, jsonify, make_response, request, abort, current_app as app
from .models import Entities, db, gen_tz
import json
from flask_basicauth import BasicAuth
from sqlalchemy import func, funcfilter

# Create blueprint
database_bp = Blueprint('database', __name__)

basic_auth = BasicAuth(app)

def str_to_bool(s):
  """
  If s is none it will pass so the default value in the model is used, otherwise will return true 
  if one of those strings matches
  """
  if s is None:
    pass
  else:
    return s.lower() in ['true', 'TRUE', 'True', '1', 'yes', 'y', 't']

@database_bp.route('/api/v1/recentLocation', methods=['GET'])
def get_recent_location():
  """
  Returns the UTC timestamp of the most recently updated verified location
  """
  query = funcfilter(func.max(Entities.updated_on), Entities.is_verified == True)
  data = db.session.query(query).scalar()
  
  response = jsonify(data)
  response.headers.add('Access-Control-Allow-Origin', '*')
  return response

@database_bp.route('/api/v1/location', methods=['GET'])
def list_location():
  """
  list all locations
  """
  table_data = Entities.query.order_by(Entities.record_id).all()
  data_list = []
  for data in table_data:
    if data.is_hidden is False and data.is_verified is True:
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
          'external_location_id': data.external_location_id,
          'location_latitude': data.location_latitude,
          'location_longitude': data.location_longitude,
          'location_name': data.location_name,
          'location_place_of_service_type': data.location_place_of_service_type,
          'location_specific_testing_criteria': data.location_specific_testing_criteria,
          'location_status': data.location_status,
          'raw_data': data.raw_data,
          'reference_publisher_of_criteria': data.reference_publisher_of_criteria,
          'updated_on': data.updated_on,
          'record_id': data.record_id
        }
      )
    else:
      continue
  
  response = jsonify(data_list)
  response.headers.add('Access-Control-Allow-Origin', '*')
  return response

@database_bp.route('/api/v1/location', methods=['POST'])
@basic_auth.required
def create_location():
  """
  create new location
  """

  # Error if json is not present
  if not request.json:
    abort(400)
  
  # Get data from json 
  content = request.get_json()

  # Map json data to Entities model
  if isinstance(content, list):
    for data in content:
      data = Entities(
        additional_information_for_patients=data.get("additional_information_for_patients"),
        created_on=data.get("created_on"),
        data_source=data.get("data_source"),
        deleted_on=data.get("deleted_on"),
        geojson=data.get("geojson"),
        is_collecting_samples=str_to_bool(data.get("is_collecting_samples")),
        is_collecting_samples_by_appointment_only=str_to_bool(data.get("is_collecting_samples_by_appointment_only")),
        is_collecting_samples_for_others=str_to_bool(data.get("is_collecting_samples_for_others")),
        is_collecting_samples_onsite=str_to_bool(data.get("is_collecting_samples_onsite")),
        is_evaluating_symptoms=str_to_bool(data.get("is_evaluating_symptoms")),
        is_evaluating_symptoms_by_appointment_only=str_to_bool(data.get("is_evaluating_symptoms_by_appointment_only")),
        is_hidden=str_to_bool(data.get("is_hidden")),
        is_ordering_tests=str_to_bool(data.get("is_ordering_tests")),
        is_ordering_tests_only_for_those_who_meeting_criteria=str_to_bool(data.get("is_ordering_tests_only_for_those_who_meeting_criteria")),
        is_processing_samples=str_to_bool(data.get("is_processing_samples")),
        is_processing_samples_for_others=str_to_bool(data.get("is_processing_samples_for_others")),
        is_processing_samples_onsite=str_to_bool(data.get("is_processing_samples_onsite")),
        is_verified=str_to_bool(data.get("is_verified")),
        location_address_locality=data.get("location_address_locality"),
        location_address_postal_code=data.get("location_address_postal_code"),
        location_address_region=data.get("location_address_region"),
        location_address_street=data.get("location_address_street"),
        location_contact_phone_appointments=data.get("location_contact_phone_appointments"),
        location_contact_phone_covid=data.get("location_contact_phone_covid"),
        location_contact_phone_main=data.get("location_contact_phone_main"),
        location_contact_url_covid_appointments=data.get("location_contact_url_covid_appointments"),
        location_contact_url_covid_info=data.get("location_contact_url_covid_info"),
        location_contact_url_covid_screening_tool=data.get("location_contact_url_covid_screening_tool"),
        location_contact_url_covid_virtual_visit=data.get("location_contact_url_covid_virtual_visit"),
        location_contact_url_main=data.get("location_contact_url_main"),
        location_hours_of_operation=data.get("location_hours_of_operation"),
        location_id=data.get("location_id"),
        external_location_id=data.get("external_location_id"),
        location_latitude=data.get("location_latitude"),
        location_longitude=data.get("location_longitude"),
        location_name=data.get("location_name"),
        location_place_of_service_type=data.get("location_place_of_service_type"),
        location_specific_testing_criteria=data.get("location_specific_testing_criteria"),
        location_status=data.get("location_status"),
        raw_data=data.get("raw_data"),
        reference_publisher_of_criteria=data.get("reference_publisher_of_criteria"),
        updated_on=data.get("updated_on"),
        record_id=data.get("record_id")
      )
      # Commit to DB
      db.session.add(data)
      db.session.commit()

  else:
    data = Entities(
        additional_information_for_patients=content.get("additional_information_for_patients"),
        created_on=content.get("created_on"),
        data_source=content.get("data_source"),
        deleted_on=content.get("deleted_on"),
        geojson=content.get("geojson"),
        is_collecting_samples=str_to_bool(content.get("is_collecting_samples")),
        is_collecting_samples_by_appointment_only=str_to_bool(content.get("is_collecting_samples_by_appointment_only")),
        is_collecting_samples_for_others=str_to_bool(content.get("is_collecting_samples_for_others")),
        is_collecting_samples_onsite=str_to_bool(content.get("is_collecting_samples_onsite")),
        is_evaluating_symptoms=str_to_bool(content.get("is_evaluating_symptoms")),
        is_evaluating_symptoms_by_appointment_only=str_to_bool(content.get("is_evaluating_symptoms_by_appointment_only")),
        is_hidden=str_to_bool(content.get("is_hidden")),
        is_ordering_tests=str_to_bool(content.get("is_ordering_tests")),
        is_ordering_tests_only_for_those_who_meeting_criteria=str_to_bool(content.get("is_ordering_tests_only_for_those_who_meeting_criteria")),
        is_processing_samples=str_to_bool(content.get("is_processing_samples")),
        is_processing_samples_for_others=str_to_bool(content.get("is_processing_samples_for_others")),
        is_processing_samples_onsite=str_to_bool(content.get("is_processing_samples_onsite")),
        is_verified=str_to_bool(content.get("is_verified")),
        location_address_locality=content.get("location_address_locality"),
        location_address_postal_code=content.get("location_address_postal_code"),
        location_address_region=content.get("location_address_region"),
        location_address_street=content.get("location_address_street"),
        location_contact_phone_appointments=content.get("location_contact_phone_appointments"),
        location_contact_phone_covid=content.get("location_contact_phone_covid"),
        location_contact_phone_main=content.get("location_contact_phone_main"),
        location_contact_url_covid_appointments=content.get("location_contact_url_covid_appointments"),
        location_contact_url_covid_info=content.get("location_contact_url_covid_info"),
        location_contact_url_covid_screening_tool=content.get("location_contact_url_covid_screening_tool"),
        location_contact_url_covid_virtual_visit=content.get("location_contact_url_covid_virtual_visit"),
        location_contact_url_main=content.get("location_contact_url_main"),
        location_hours_of_operation=content.get("location_hours_of_operation"),
        location_id=content.get("location_id"),
        external_location_id=content.get("external_location_id"),
        location_latitude=content.get("location_latitude"),
        location_longitude=content.get("location_longitude"),
        location_name=content.get("location_name"),
        location_place_of_service_type=content.get("location_place_of_service_type"),
        location_specific_testing_criteria=content.get("location_specific_testing_criteria"),
        location_status=content.get("location_status"),
        raw_data=content.get("raw_data"),
        reference_publisher_of_criteria=content.get("reference_publisher_of_criteria"),
        updated_on=content.get("updated_on"),
        record_id=content.get("record_id")
      )
    # Commit to DB
    db.session.add(data)
    db.session.commit()
  response = make_response(jsonify(result="accepted"), 201)
  response.headers.add('Access-Control-Allow-Origin', app.config['SITE_ENDPOINT'])
  response.headers.add('Access-Control-Allow-Headers', 'Authorization, Content-Type')

  return response
  

@database_bp.route('/api/v1/location/<location_id>', methods=['GET'])
def get_location(location_id):
  """
  Returns details of a single location by id
  """
  data = Entities.query.filter(Entities.location_id == location_id).first()
  if data.is_hidden is False and data.is_verified is True:
    result = {
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
          'external_location_id': data.external_location_id,
          'location_latitude': data.location_latitude,
          'location_longitude': data.location_longitude,
          'location_name': data.location_name,
          'location_place_of_service_type': data.location_place_of_service_type,
          'location_specific_testing_criteria': data.location_specific_testing_criteria,
          'location_status': data.location_status,
          'raw_data': data.raw_data,
          'reference_publisher_of_criteria': data.reference_publisher_of_criteria,
          'updated_on': data.updated_on,
          'record_id': data.record_id
        }
  else:
    result = {}
  
  response = jsonify(result)
  response.headers.add('Access-Control-Allow-Origin', '*')
  return response

@database_bp.route('/api/v1/location/<location_id>', methods=['PUT'])
@basic_auth.required
def update_location(location_id):
  """
  Update a location
  /api/v1/location/<id>?field=<fieldname>&value=<value>

  """

  # Get the location
  location = Entities.query.filter(Entities.location_id == location_id).first()
  if location is None:
    response = make_response(jsonify(result="Not found"), 404)
    response.headers.add('Access-Control-Allow-Origin', app.config['SITE_ENDPOINT'])
    response.headers.add('Access-Control-Allow-Headers', 'Authorization, Content-Type')
    return response
  
  # field and values from request params
  new_field = request.args.get('field')
  new_value = request.args.get('value')

  # dont allow update created_on record_id location_id
  if new_field in ["created_on", "record_id", "location_id", "is_hidden", "is_verified", "deleted_on", "external_location_id"]:
    response = make_response(jsonify(result="You are not allowed to update this field"), 403)
    response.headers.add('Access-Control-Allow-Origin', app.config['SITE_ENDPOINT'])
    response.headers.add('Access-Control-Allow-Headers', 'Authorization, Content-Type')
    return response
  # TODO: "is_hidden", "is_verified", "deleted_on", "external_location_id" will require another mechanism to authenticate verified users
  # elif (user is not authorized) and new_field in ["is_hidden", "is_verified", "deleted_on", "external_location_id"]:
  #   response = make_response(jsonify(result="You are not allowed to update this field"), 401)
  #   response.headers.add('Access-Control-Allow-Origin', app.config['SITE_ENDPOINT'])
  #   response.headers.add('Access-Control-Allow-Headers', 'Authorization, Content-Type')
  #   return response
  else:
    new_fields = {}
    new_fields[new_field] = new_value

    # Set the value of location.fieldname = value dynamically 
    for key, value in new_fields.items():
      setattr(location, key, value)

    db.session.commit()
    
    response = make_response(jsonify(result="updated"), 204)
    response.headers.add('Access-Control-Allow-Origin', app.config['SITE_ENDPOINT'])
    response.headers.add('Access-Control-Allow-Headers', 'Authorization, Content-Type')

    return response
