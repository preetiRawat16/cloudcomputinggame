# Use the official Python image from the Docker Hub as a base image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt file into the container
COPY requirements.txt /app/

# Install the required Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . /app/

# Expose port 5000, which is where Flask will run
EXPOSE 5000

# Set the default command to run when the container starts
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
