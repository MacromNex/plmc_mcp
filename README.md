# PLMC MCP

**Evolutionary coupling model training using PLMC via Docker**

An MCP (Model Context Protocol) server for evolutionary coupling analysis with 2 core tools:
- Convert protein sequence alignments from A3M to A2M format
- Train PLMC evolutionary coupling models from sequence alignments

## Quick Start with Docker

### Approach 1: Pull Pre-built Image from GitHub

The fastest way to get started. A pre-built Docker image is automatically published to GitHub Container Registry on every release.

```bash
# Pull the latest image
docker pull ghcr.io/macromnex/plmc_mcp:latest

# Register with Claude Code (runs as current user to avoid permission issues)
claude mcp add plmc -- docker run -i --rm --user `id -u`:`id -g` -v `pwd`:`pwd` ghcr.io/macromnex/plmc_mcp:latest
```

**Note:** Run from your project directory. `` `pwd` `` expands to the current working directory.

**Requirements:**
- Docker
- Claude Code installed

That's it! The PLMC MCP server is now available in Claude Code.

---

### Approach 2: Build Docker Image Locally

Build the image yourself and install it into Claude Code. Useful for customization or offline environments.

```bash
# Clone the repository
git clone https://github.com/MacromNex/plmc_mcp.git
cd plmc_mcp

# Build the Docker image
docker build -t plmc_mcp:latest .

# Register with Claude Code (runs as current user to avoid permission issues)
claude mcp add plmc -- docker run -i --rm --user `id -u`:`id -g` -v `pwd`:`pwd` plmc_mcp:latest
```

**Note:** Run from your project directory. `` `pwd` `` expands to the current working directory.

**Requirements:**
- Docker
- Claude Code installed
- Git (to clone the repository)

**About the Docker Flags:**
- `-i` — Interactive mode for Claude Code
- `--rm` — Automatically remove container after exit
- `` --user `id -u`:`id -g` `` — Runs the container as your current user, so output files are owned by you (not root)
- `-v` — Mounts your project directory so the container can access your data

---

## Verify Installation

After adding the MCP server, you can verify it's working:

```bash
# List registered MCP servers
claude mcp list

# You should see 'plmc' in the output
```

In Claude Code, you can now use all 2 PLMC tools:
- `plmc_convert_a3m_to_a2m`
- `plmc_generate_model`

---

## Next Steps

- **Detailed documentation**: See [detail.md](detail.md) for comprehensive guides on:
  - Available MCP tools and parameters
  - Local Python environment setup (alternative to Docker)
  - Example workflows and use cases
  - Troubleshooting

---

## Usage Examples

Once registered, you can use the PLMC tools directly in Claude Code. Here are some common workflows:

### Example 1: Build an Evolutionary Coupling Model

```
I have created an A3M file for subtilisin BPN' at /path/to/subtilisin.a3m. Can you help build an EV model using the plmc MCP and create it in /path/to/plmc/ directory? The wild-type sequence is at /path/to/wt.fasta.
```

### Example 2: Convert A3M to A2M Format

```
I have an A3M alignment file at /path/to/protein.a3m from MMseqs2. Can you convert it to A2M format and remove query gaps using plmc_convert_a3m_to_a2m, saving to /path/to/protein.a2m?
```

### Example 3: Full EV Model Workflow

```
I have an MSA in A3M format at /path/to/protein.a3m and wild-type sequence at /path/to/wt.fasta.
1. First convert the A3M to A2M format using plmc_convert_a3m_to_a2m
2. Then train a PLMC model using plmc_generate_model, saving parameters to /path/to/plmc/
```

---

## Troubleshooting

**Docker not found?**
```bash
docker --version  # Install Docker if missing
```

**Claude Code not found?**
```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code
```

**Model training failed?**
- Ensure the A2M alignment file has the correct format (no query gaps)
- Verify the wild-type sequence matches the alignment focus sequence
- Check that the alignment has sufficient sequence diversity

---

## License

MIT — Based on [PLMC](https://github.com/debbiemarkslab/plmc) by Debbie Marks Lab.
