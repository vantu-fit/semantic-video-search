FROM python:3.9-slim

RUN apt-get update && \
    apt-get install -y ffmpeg && \
    pip install boto3

COPY extract_keyframes.py /app/extract_keyframes.py

WORKDIR /app

ENTRYPOINT ["python", "extract_keyframes.py"]
