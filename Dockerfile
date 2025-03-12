# Note that this is a fairly stock-standard build. For bigger projects, it's recommended to learn
# how to use the buildkit

# Specify python version for building. This is a big package, and used for building dependencies
FROM python:3.11-buster as builder

# Install the poetry version you're currently running on PC, to ensure compatibility
RUN pip install poetry==1.8.3

# Poetry arguments to create a virtual environment and ensure it doesn't interact
# With the outside container
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# Change to the desired working environment (/app by convention)
WORKDIR /app

# Copy the contents from poetry files
COPY pyproject.toml poetry.lock ./

# In case there is no README.md. Remove this command if you make one
RUN touch README.md

# Install the contents of the poetry install, then uninstall after download
# --mount=type=cache,target=$POETRY_CACHE_DIR caches the installs, allowing for faster subsequent builds
# --without dev installs only the main dependencies, and ignores development dependencies
# --no-root installs only the dependencies and not the project itself
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

# The runtime slim-buster is lighter weight, less dependencies and better for final runtime
# Essentially, this rebuilds with minimal components. 
# Poetry isn't even installed; only the venv remains
FROM python:3.11-slim-buster as runtime

# If you needed poetry (For larger applications), you could install and uninstall at runtime using
# RUN pip install poetry && poetry install --without dev && pip uninstall poetry

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Copy the contents from the src folder to run from the parent directory
COPY src ./src

# Run command
ENTRYPOINT ["python", "-m", "main.py"]