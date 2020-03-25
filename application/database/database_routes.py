from flask import Blueprint, jsonify, make_response
from .models import Entities, db
import json

# Create blueprint
database_bp = Blueprint('database', __name__)


# Insert data
@database_bp.route('/api/v1/insert', methods=['POST'])
def insert():
  """
  Insert data into DB
  Method: Post
  Path: /api/v1/insert
  """
  try:
    test_data = Entities(location_id="test", location_name="test center", geojson=json.dumps({"test": "test1"}))
    db.session.add(test_data)
    db.session.commit()
    return jsonify(result="ok")
  except Exception as e:
    print(e)
    return make_response(e)