# django-simple-app

## Project Overview

`django-simple-app` is a Django-based web application that integrates with a MySQL database using Docker and Docker Compose for containerization. This setup ensures easy deployment and scalability.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Git**: For cloning the repository.
- **Docker**: To containerize the application.
- **Docker Compose**: To manage multi-container Docker applications.

## Installation Steps

### 1. Clone the Repository

```
git clone https://github.com/shefeekar/django-simple-app.git
cd django-simple-app
```

### 2. Configure Database Settings

Modify the `settings.py` file to match your environment. The database settings should use environment variables for security:

```
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('DB_NAME', 'world'),
        'USER': os.getenv('DB_USER', 'django'),
        'PASSWORD': os.getenv('DB_PASSWORD', 'django123'),
        'HOST': os.getenv('DB_HOST', 'db'),
        'PORT': os.getenv('DB_PORT', '3306'),
    }
}
```

### 3. Create a `.env` File

Create a `.env` file in the root directory to store sensitive credentials securely:

```
DB_NAME=world
DB_USER=django
DB_PASSWORD=django123
DB_ROOT_PASSWORD=root123
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-gmail-password
EMAIL_USE_TLS=True
EMAIL_PORT=587
```

> Security Note: Avoid committing .env files to Git. Use .gitignore to exclude them. Or creating.envfile outside of root directory
> 

### 4. Create a Dockerfile for Django

Create a `Dockerfile` to containerize the Django application:

```
FROM python:3.8
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY . .
RUN pip install --no-cache-dir virtualenv
RUN virtualenv -p python3.8 /env
ENV VIRTUAL_ENV=/env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8001
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]
```

### 5. Create a `docker-compose.yml` File

This `docker-compose.yml` file defines services for MySQL and the Django application:

```
version: '3.8'

services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: ${DB_NAME:-world}
      MYSQL_USER: ${DB_USER:-django}
      MYSQL_PASSWORD: ${DB_PASSWORD:-django123}
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD:-root123}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./world.sql:/docker-entrypoint-initdb.d/world.sql
    networks:
      - django-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 10s
      retries: 5

  web:
    build: .
    environment:
      DB_NAME: ${DB_NAME:-world}
      DB_USER: ${DB_USER:-django}
      DB_PASSWORD: ${DB_PASSWORD:-django123}
      DB_HOST: db
      DB_PORT: 3306
      EMAIL_USE_TLS: ${EMAIL_USE_TLS:-True}
      EMAIL_HOST: ${EMAIL_HOST:-smtp.gmail.com}
      EMAIL_HOST_USER: ${EMAIL_HOST_USER}
      EMAIL_HOST_PASSWORD: ${EMAIL_HOST_PASSWORD}
      EMAIL_PORT: ${EMAIL_PORT:-587}
    ports:
      - "8001:8001"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - django-network
    command: >
      sh -c "python manage.py makemigrations && \
            python manage.py migrate && \
            python manage.py collectstatic --noinput && \
            python manage.py runserver 0.0.0.0:8001"

volumes:
  mysql_data:

networks:
  django-network:
    driver: bridge
```

## Running the Application

With the configurations in place, start the application using Docker Compose:

```
docker-compose build
docker-compose up -d
```

This will build the Docker images and start the services defined in the `docker-compose.yml` file.

### **Ensure AWS Security Group Rules Are Configured**

- **Port 3306**: Allow MySQL connections (only if needed for external access).
- **Port 8001**: Allow HTTP access to the Django application.

## Accessing the Application

Once the application is running, access it in your browser using:

```
http://<PUBLIC-IP-OF-INSTANCE>:8001
```

Replace `<PUBLIC-IP-OF-INSTANCE>` with your EC2 instance's public IP address.
