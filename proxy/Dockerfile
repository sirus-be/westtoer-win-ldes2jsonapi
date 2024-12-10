# Use the official Python image as the base
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements and application code to the container
COPY requirements.txt /app/
COPY *.py /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port Flask will run on
EXPOSE 80

# Run the application
CMD ["python", "proxy.py"]
