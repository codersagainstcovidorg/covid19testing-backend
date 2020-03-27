from config import Config
from os import getenv
import application 
from boto3 import client

APP_NAME = "backend"

ssm_client = client('ssm', region_name=getenv("AWS_REGION", 'us-east-1'))


app = application.create_app()

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

with app.app_context():
  from application.database import models
  models.db.create_all()
