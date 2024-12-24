# Use an official Python runtime as the base image
FROM python:3.10-slim-bullseye

# Set environment variables (Hardcoded values)
ENV PYTHONUNBUFFERED=1 \app-fa46de2a-fdaf-4d5c-a5cb-d1ca4ce59970-do-user-18603278-0.i.db.ondigitalocean.com 
    POSTGRES_USER=your_postgres_username \
    POSTGRES_PASSWORD=your_postgres_password \
    POSTGRES_DB=your_postgres_db_name \
    DJANGO_SETTINGS_MODULE=your_django_settings_module \
    DJANGO_SECRET_KEY=your_django_secret_key

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcairo2-dev \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the application files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Collect static files and prepare database migrations
RUN python3 manage.py collectstatic --noinput && \
    python3 manage.py makemigrations && \
    python3 manage.py migrate && \
    python3 manage.py createhorillauser \
        --first_name admin \
        --last_name admin \
        --username admin \
        --password admin \
        --email admin@example.com \
        --phone 1234567890

# Expose the application port
EXPOSE 8000

# Start the Gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]
