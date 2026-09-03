FROM python:3.11-slim-bookworm

WORKDIR /app

RUN pip install --no-cache-dir poetry

RUN poetry config virtualenvs.create false

# Kopieer de Poetry-bestanden vanuit content
COPY content/pyproject.toml content/poetry.lock ./

# Installeer dependencies
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de daadwerkelijke applicatie naar /app
COPY content/ .

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]