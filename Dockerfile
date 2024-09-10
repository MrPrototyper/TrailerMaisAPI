    # Use the official Python image as the base image
FROM python:3.11-slim
# FROM python:3.12.2-slim-bullseye
# ENV PYTHONBUFFERED=1

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    libjpeg-dev \
    zlib1g-dev \
    gcc \
    libc-dev \
    bash \
    git \
    postgresql-client

# Upgrade pip
RUN pip3 install --upgrade pip

# Set environment variables
ENV LIBRARY_PATH=/lib:/usr/lib
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV DJANGO_DEBUG=True
ENV DJANGO_ALLOWED_HOSTS=0.0.0.0,localhost,127.0.0.1

# Set the working directory
WORKDIR /tmapi

# Copy the application code into the container
COPY . /tmapi

# FIX - Install Cython, wheel, and PyYAML before installing the Python dependencies)
RUN pip install "cython<3.0.0" wheel && pip3 install pyyaml==5.4.1 --no-build-isolation

# Install Python dependencies
RUN pip --no-cache-dir install -r requirements.txt

# CMD to start the Django development server
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
RUN echo "Starting Gunicorn"
CMD gunicorn tm.wsgi:application --bind 0.0.0.0:8000
