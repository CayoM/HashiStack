FROM python:3.9
WORKDIR /app
COPY app.py /app
COPY secrets.env /app
RUN pip install flask psycopg2 python-dotenv
CMD ["python", "app.py"]
