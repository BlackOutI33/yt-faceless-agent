FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/
ENV PYTHONUNBUFFERED=1

# Optional: run the collector on start; comment out to disable auto-run
CMD python scripts/find_top100.py && uvicorn app.server:app --host 0.0.0.0 --port 8000
