import os
from datetime import datetime
import time
import random

from flask import Flask, request

from mta_service import MTAService

app = Flask(__name__)


station_jsons = None
last_update = None

mta_service = MTAService()

@app.route("/arrivals/<station_id>")
def get_station_arrivals(station_id):
    global station_jsons, last_update

    if last_update is None or (datetime.now() - last_update).total_seconds() > 10:
        last_update, station_jsons = mta_service.fetch_arrivals()

    if station_id in station_jsons:
        return station_jsons[station_id]
    return mta_service.DEFAULT_JSON


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))

