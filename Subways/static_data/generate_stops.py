from dataclasses import dataclass
import re

@dataclass
class Stop:
    id: str
    name: str
    lat: float
    long: float
    routes: set[str]

@dataclass
class Trip:
    route_id: str
    trip_id: str
    shape_id: str


stops_file = open('stops.txt', 'r')
trips_file = open('trips.txt', 'r')
stop_times_file = open('stop_times.txt', 'r')

stops = {}

for stop in stops_file:
    sp = stop.strip().split(sep=',')
    if len(sp) != 6:
        continue
    id, name, lat, long, _, parent = sp
    if id == 'stop_id' or len(parent) > 0:
        continue
    stops[id] = Stop(id, name, float(lat), float(long), set())
    #print(stops[id])

stops_file.close()

trips = {}

for trip in trips_file:
    sp = trip.strip().split(sep=',')
    if len(sp) != 6:
        continue
    route_id, trip_id, service_id, _, _, shape_id = sp
    if route_id == 'route_id' or service_id != "Weekday":
        continue
    #dot_index = trip_id.find('.')
    und_index = [m.start() for m in re.finditer(r"_", trip_id)][-1]
    trip_time_str = trip_id[und_index-6:und_index]
    trip_time = int(trip_time_str) / 6000.0
    if trip_time < 6 or trip_time > 24:
        continue
    trips[trip_id] = Trip(route_id, trip_id, shape_id)
    #print(trips[trip_id])

trips_file.close()

for stop_time in stop_times_file:
    sp = stop_time.strip().split(sep=',')
    if len(sp) != 5:
        continue
    trip_id, stop_id, _, _, _ = sp
    if trip_id not in trips:
        continue
    route_id = trips[trip_id].route_id
    stops[stop_id[:-1]].routes.add(route_id)

    if route_id == '4' and stop_id[:-1] == '639':
        print(trip_id)

for stop_id in stops:
    stop = stops[stop_id]
    print(f'"{stop_id}": Station(id: "{stop_id}", name: "{stop.name}", lat: {stop.lat}, long: {stop.long}, routes: [{", ".join(f"Route(rawValue: \"{r}\")!" for r in stop.routes)}]),')
