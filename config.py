from os import getenv
from boto3 import client

APP_NAME = "backend"

ssm_client = client('ssm')

def get_param(param_name, decrypt=True):
  response = ssm_client.get_parameters_by_path(
    Path=f'{getenv("ENVIRONMENT", "DEV")}/{APP_NAME}/{param_name}',
    WithDecryption=decrypt
  )
  return response.get("Parameters")[0].get("Value")

class Config:
    """
    Set Flask configuration vars from AWS param store
    """

    # General
    FLASK_DEBUG = True if "DEV" in getenv("ENVIRONMENT") else False
    SECRET_KEY = get_param("SECRET_KEY")

    # Database
    SQLALCHEMY_DATABASE_URI = get_param("SQLALCHEMY_DATABASE_URI")
    SQLALCHEMY_TRACK_MODIFICATIONS = False