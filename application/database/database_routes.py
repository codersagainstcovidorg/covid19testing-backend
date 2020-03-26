from flask import Blueprint, jsonify, make_response
from .models import Entities, db
import json

# Create blueprint
database_bp = Blueprint('database', __name__)

"""
crudLocationRouter.Handle("/location", mwHandler.Handle([]rye.Handler{entityService.ListLocation})).Methods("GET")
crudLocationRouter.Handle("/location", mwHandler.Handle([]rye.Handler{entityService.CreateLocation})).Methods("POST")
crudLocationRouter.Handle("/location/{id}", mwHandler.Handle([]rye.Handler{entityService.GetLocation})).Methods("GET")
crudLocationRouter.Handle("/location/{id}", mwHandler.Handle([]rye.Handler{entityService.UpdateLocation})).Methods("PUT")
"""

@database_bp.route('/api/v1/location', methods=['GET'])
def list_location():
  pass

@database_bp.route('/api/v1/location', methods=['POST'])
def create_location():
  pass

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
      created_on=
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
      created_on=
    )
    db.session.add(test_data)
    db.session.commit()
    return jsonify(result="ok")
  except Exception as e:
    print(e)
    return make_response(string(e))