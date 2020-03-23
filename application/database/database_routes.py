from flask import Blueprint, jsonify
from flask import current_app as app

database_bp = Blueprint('database', __name__)


# Insert data
@database_bp.route('/api/v1/insert', methods=['POST'])
def insert():
  """
  Insert data into DB
  Method: Post
  Path: /api/v1/insert
  """

  return jsonify(test="ok")