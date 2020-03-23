from flask import current_app as app, jsonify

@app.route('/api/v1/health')
def health_check():
  return jsonify(alive=True)