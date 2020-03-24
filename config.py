from os import getenv
from boto3 import client

APP_NAME = "backend"

ssm_client = client('ssm', region_name=getenv("AWS_REGION", 'us-east-1'))

def get_param(param_name, decrypt=True):
  try:
    response = ssm_client.get_parameter(
      Name=f'/{getenv("ENVIRONMENT", "dev")}/{APP_NAME}/{param_name}',
      WithDecryption=decrypt
    )
    return response.get("Parameter").get("Value")
  except ssm_client.exceptions.ParameterNotFound:
    return ""

class Config:
    """
    Set Flask configuration vars from AWS param store
    """

    # General
    FLASK_DEBUG = True if getenv("ENVIRONMENT") is None else False
    SECRET_KEY = get_param("SECRET_KEY")

    # Database
    # [DB_TYPE]+[DB_CONNECTOR]://[USERNAME]:[PASSWORD]@[HOST]:[PORT]/[DB_NAME]
    SQLALCHEMY_DATABASE_URI = get_param("SQLALCHEMY_DATABASE_URI")
    SQLALCHEMY_TRACK_MODIFICATIONS = False