# Use an official Python image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy requirements first (for caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY . .

# Expose the port (Flask runs on 5000)
EXPOSE 5000

# Start the Flask app using gunicorn
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
