FROM continuumio/miniconda3:24.7.1-0

# Install build tools for compiling PLMC (needs gcc + OpenMP)
RUN apt-get update && apt-get install -y \
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
    git clone --depth 1 https://github.com/debbiemarkslab/plmc.git repo/plmc && \
    cd repo/plmc && make -j$(nproc) all-openmp

# ── Copy application source ─────────────────────────────────────────────────
COPY src/ ./src/
RUN mkdir -p tmp/inputs tmp/outputs

ENV PYTHONPATH=/app

CMD ["python", "src/server.py"]
