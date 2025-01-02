import asyncio
from datetime import datetime, timedelta

from mta_service import MTAService

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi import status

import firebase_admin
from firebase_admin import app_check

firebase_admin.initialize_app()
app = FastAPI()


@app.middleware("http")
async def verify_app_check_token(request: Request, call_next):
    app_check_token = request.headers.get("X-Firebase-App-Check")
    if not app_check_token:
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={"detail": "App Check token missing"}
        )
    
    try:
        app_check.verify_token(app_check_token)
    except Exception as e:
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={"detail": f"App Check token verification unsuccessful", "error_string": str(e)}
        )

    response = await call_next(request)
    return response


station_jsons = None
last_update = None

mta_service = MTAService()

DATA_REFRESH_INTERVAL = timedelta(seconds=10)
data_fetch_lock = asyncio.Lock()

async def refresh_cache_if_needed():
    global station_jsons, last_update, data_fetch_lock
    async with data_fetch_lock:
        if not last_update or datetime.now() - last_update > DATA_REFRESH_INTERVAL:
            last_update, station_jsons = await mta_service.fetch_arrivals()


@app.get("/arrivals/{station_id}")
async def get_station_arrivals(station_id: str):
    global station_jsons, last_update
    await refresh_cache_if_needed()

    if station_id in station_jsons:
        return station_jsons[station_id]
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": "Station not found"}
    )
