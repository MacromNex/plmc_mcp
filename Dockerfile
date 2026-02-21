FROM continuumio/miniconda3:24.7.1-0

# Install build tools for compiling PLMC (needs gcc + OpenMP)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential libgomp1 perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Conda environment: Python 3.10 + HHsuite ────────────────────────────────
RUN conda install -n base -c conda-forge -c bioconda \
    python=3.10 hhsuite -y && \
    conda clean -afy

# ── Python dependencies ──────────────────────────────────────────────────────
RUN pip install --no-cache-dir \
    pydantic fastmcp \
    https://github.com/debbiemarkslab/EVcouplings/archive/develop.zip

# ── Clone and compile PLMC with OpenMP ───────────────────────────────────────
RUN mkdir -p repo && \
    for attempt in 1 2 3; do \
      echo "Clone attempt $attempt/3"; \
      git clone --depth 1 https://github.com/debbiemarkslab/plmc.git repo/plmc && break; \
      if [ $attempt -lt 3 ]; then sleep 5; fi; \
    done && \
    cd repo/plmc && make -j$(nproc) all-openmp

# ── Copy application source ─────────────────────────────────────────────────
COPY src/ ./src/
RUN chmod -R a+r /app/src/
RUN mkdir -p tmp/inputs tmp/outputs /tmp/.cache && \
    chmod -R 1777 /app/tmp /tmp/.cache

ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV HOME=/tmp
ENV XDG_CACHE_HOME=/tmp/.cache

CMD ["python", "src/server.py"]
