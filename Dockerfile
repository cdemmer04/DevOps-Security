# Use Python 3.11 because the project requires ^3.11
FROM python:3.11-slim-bookworm

# Set work directory
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry

# Configure Poetry not to create a virtual environment
RUN poetry config virtualenvs.create false

# Copy dependency files first for Docker caching
COPY content/pyproject.toml content/poetry.lock ./

# Install dependencies
RUN poetry install --no-interaction --no-ansi --no-root

# Copy project files
COPY . .

# Expose Flask port
EXPOSE 5000

# Run Flask
CMD ["flask", "run", "-h", "0.0.0.0", "-p", "5000"]