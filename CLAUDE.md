# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

An MCP (Model Context Protocol) server wrapping **PLMC** (Pseudolikelihood Maximization for Coevolution Analysis) for protein evolutionary coupling analysis. It provides tools for generating model parameters and evolutionary couplings used in EV+Onehot fitness prediction models.

## Setup & Run

```bash
# Automated setup (creates conda env, compiles PLMC, installs HHsuite)
bash quick_setup.sh

# Run the MCP server
./env/bin/python src/server.py

# Docker
docker build -t plmc-mcp .
docker run -it plmc-mcp

# Register with Claude Code
claude mcp add plmc -- ./env/bin/python src/server.py
```

Setup options: `--skip-env`, `--skip-plmc`, `--skip-hhsuite`.

## Architecture

**Entry point**: `src/server.py` — minimal FastMCP server that mounts tools from `src/tools/readme.py`.

**Tool module**: `src/tools/readme.py` — contains all MCP tool implementations and helper functions:
- `plmc_generate_model` — runs the PLMC binary on an A2M alignment to produce `*.model_params` (binary) and `*.EC` (evolutionary couplings) files. Default parameters are tuned for EV+Onehot (lambda_e=16.2, lambda_h=0.01, m=200, theta=0.2).
- `plmc_convert_a3m_to_a2m` — converts A3M→A2M via `reformat.pl` (from HHsuite), then strips query-gap columns. Required preprocessing before `plmc_generate_model`.

**External binary discovery** (in `readme.py`): Both `PLMC_BIN` and `REFORMAT_PL` are found by searching `repo/plmc/bin/plmc`, then `env/bin/`, then system PATH. Override PLMC location with the `PLMC_DIR` env var.

## Key Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `PLMC_DIR` | `./repo/plmc` | Path to compiled PLMC repository |
| `README_INPUT_DIR` | `./tmp/inputs` | Input directory for tool operations |
| `README_OUTPUT_DIR` | `./tmp/outputs` | Output directory for tool operations |

## Dependencies

- **Python 3.10**, `fastmcp`, `pydantic`, `EVcouplings` (from GitHub develop branch)
- **PLMC**: compiled from source with OpenMP (`repo/plmc/bin/plmc`)
- **HHsuite**: provides `reformat.pl` for alignment format conversion (installed via conda-forge/bioconda)

## Typical Workflow

1. User provides an A3M alignment → `plmc_convert_a3m_to_a2m` converts to cleaned A2M
2. Cleaned A2M + focus sequence ID → `plmc_generate_model` produces model_params + EC files
3. Output files feed into downstream EV+Onehot fitness prediction

## Docker

`Dockerfile` uses `continuumio/miniconda3` base (needed for HHsuite via bioconda). PLMC is compiled and baked into the image. CI builds via `.github/workflows/docker.yml` push to `ghcr.io` on main branch pushes and version tags.
