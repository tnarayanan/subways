from dataclasses import dataclass
from datetime import datetime

@dataclass
class TrainArrival:
    id: str
    rt: str
    dir: str
    time: int

    def __lt__(self, other):
        # inverted since heapq is a min heap
        return self.time > other.time
    
    def __str__(self):
        return f"TrainArrival({self.dir} {self.rt} @ {datetime.fromtimestamp(self.time)})"
    
    def __repr__(self):
        return self.__str__()