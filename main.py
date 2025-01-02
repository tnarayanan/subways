import asyncio
from datetime import datetime, timedelta

from mta_service import MTAService

from fastapi import FastAPI, HTTPException

app = FastAPI()


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
    return HTTPException(status_code=404, detail="Station not found")
