import heapq
import httpx

from datetime import datetime, timedelta

from proto.gtfs_realtime_pb2 import FeedMessage
from train_arrival import TrainArrival

DOWNTOWN = "D"
UPTOWN = "U"

class MTAService:
    BASE_URL = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    ENDPOINTS = ["-ace", "-bdfm", "-g", "-jz", "-nqrw", "-l", "", "-si"]

    async def _make_mta_request(self) -> list[FeedMessage]:
        messages = []
        async with httpx.AsyncClient() as client:
            for endpoint in self.ENDPOINTS:
                raw_bytes = await client.get(f"{self.BASE_URL}{endpoint}")
                message = FeedMessage()
                message.ParseFromString(raw_bytes.read())
                messages.append(message)

        return messages
    
    async def fetch_arrivals(self) -> tuple[datetime, dict[str: dict[str: TrainArrival]]]:
        start = datetime.now()
        one_minute_ago = start - timedelta(minutes=1)

        station_arrival_heaps = {}
        messages = await self._make_mta_request()

        for message in messages:
            for entity in message.entity:
                if not entity.HasField("trip_update"):
                    continue
                trip_update = entity.trip_update
                trip_id = trip_update.trip.trip_id
                route = trip_update.trip.route_id if trip_update.trip.HasField("route_id") else "X"

                for stop_time_update in trip_update.stop_time_update:
                    stop_id_with_direction = stop_time_update.stop_id if stop_time_update.HasField("stop_id") else "X"
                    direction = UPTOWN if stop_id_with_direction[-1] == "N" else DOWNTOWN
                    stop_id = stop_id_with_direction[:-1]

                    if stop_id not in station_arrival_heaps:
                        station_arrival_heaps[stop_id] = {DOWNTOWN: [], UPTOWN: [], 'asOf': int(start.timestamp())}
                    
                    timestamp = 0
                    if stop_time_update.HasField("arrival"):
                        timestamp = stop_time_update.arrival.time
                    elif stop_time_update.HasField("departure"):
                        timestamp = stop_time_update.departure.time

                    if datetime.fromtimestamp(timestamp) < one_minute_ago:
                        continue
                    
                    train_arrival = TrainArrival(trip_id + "_" + stop_id, route, direction, timestamp)

                    if len(station_arrival_heaps[stop_id][direction]) >= 7:
                        heapq.heappushpop(station_arrival_heaps[stop_id][direction], train_arrival)
                    else:
                        heapq.heappush(station_arrival_heaps[stop_id][direction], train_arrival)
        print(datetime.now() - start)
        
        return start, station_arrival_heaps

if __name__ == '__main__':
    MTAService().fetch_arrivals()
