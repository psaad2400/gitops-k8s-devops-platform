# 1. Using a more recent, smaller base image
FROM python:3.12-slim

# 2. Fix OS-level vulnerabilities (OpenSSL, glibc, etc.)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 3. Security Best Practice: Run as non-root user
RUN useradd -m appuser
USER appuser

# Install dependencies
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code with correct ownership
COPY --chown=appuser:appuser . .

EXPOSE 5000

CMD ["python", "app.py"]