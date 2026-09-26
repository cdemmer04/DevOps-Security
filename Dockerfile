FROM python:3.14-slim-bookworm

WORKDIR /app

RUN useradd -u 10001 appuser

RUN pip install --no-cache-dir poetry

RUN poetry config virtualenvs.create false

# Kopieer de Poetry-bestanden vanuit content
COPY content/pyproject.toml content/poetry.lock ./

# Installeer dependencies
RUN poetry lock
RUN poetry install --no-interaction --no-ansi --no-root

# Kopieer de daadwerkelijke applicatie naar /app
COPY content/ .

RUN chown -R appuser:appuser /app

USER 10001

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]