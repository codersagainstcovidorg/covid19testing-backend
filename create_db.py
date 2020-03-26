from config import Config
import application 

app = application.create_app()

with app.app_context():
  from application.database import models
  models.db.create_all()
