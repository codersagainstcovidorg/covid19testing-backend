from config import Config
from os import getenv
import application 
from boto3 import client
from sqlalchemy import text

APP_NAME = "backend"

ssm_client = client('ssm', region_name=getenv("AWS_REGION", 'us-east-1'))


app = application.create_app()

print("Starting DB creation")
def get_param(param_name, decrypt=True):
  try:
    response = ssm_client.get_parameter(
      Name=f'/{getenv("ENVIRONMENT", "dev")}/{APP_NAME}/{param_name}',
      WithDecryption=decrypt
    )
    return response.get("Parameter").get("Value")
  except ssm_client.exceptions.ParameterNotFound:
    return ""

app.config["SQLALCHEMY_DATABASE_URI"] = get_param("SQLALCHEMY_DATABASE_URI") if getenv("ENVIRONMENT") is not None else getenv("SQLALCHEMY_DATABASE_URI")

extensions_query = text('CREATE EXTENSION if not EXISTS cube; CREATE EXTENSION if not EXISTS earthdistance;')

with app.app_context():
  from application.database import models
  models.db.create_all()

  # add extensions for GIS data
  # Only done in local, RDS requires superuser to do this
  if getenv("ENVIRONMENT") is None:
    models.db.engine.execute(extensions_query)

print("Finished")