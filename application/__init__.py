from flask import Flask
from flask_sqlalchemy import SQLAlchemy


# Create reusable clients
db = SQLAlchemy()

# App factory
def create_app():
  """
  Initialize app 
  """
  app=Flask(__name__, instance_relative_config=False)
  app.config.from_object('config.Config')

  # Init DB
  db.init_app(app)
  
  with app.app_context():
    # Import routes
    from . import routes
    from .database import database_routes

    app.register_blueprint(database_routes.database_bp)
    return app
