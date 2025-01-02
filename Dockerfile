FROM python:3.13-slim

ENV PYTHONUNBUFFERED True

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . ./

CMD ["sh", "-c", "exec uvicorn main:app --host 0.0.0.0 --port $PORT"]