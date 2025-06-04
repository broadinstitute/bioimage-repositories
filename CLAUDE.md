# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository maintains a comparison of platforms for sharing biological imaging data. The data is structured as a YAML database that auto-generates a markdown table in the README.

## Data Architecture

- `data/repositories.yaml` - Single source of truth for all repository information
- Each repository entry contains structured metadata: name, URL, description, qualifications, size limits, costs, metadata requirements, and API availability
- The YAML structure includes top-level metadata (version, maintainers, license) and a repositories section

## Common Development Commands

### Update the comparison table
```bash
./scripts/update_table.sh
```

This script:
- Requires `yq` tool (install with `brew install yq` on macOS)
- Reads `data/repositories.yaml` and generates a markdown table
- Updates the README.md between the `<!-- AUTO-GENERATED TABLE START -->` and `<!-- AUTO-GENERATED TABLE END -->` markers

### Contributing workflow
1. Edit `data/repositories.yaml` to add/modify repository information
2. Run `./scripts/update_table.sh` to regenerate the table
3. Commit both files together

## Key Files

- `data/repositories.yaml` - Repository database (edit this to make changes)
- `scripts/update_table.sh` - Table generation script
- `README.md` - Contains auto-generated comparison table
- `CONTRIBUTING.md` - Simple contribution instructions

## Important Notes

- Always edit the YAML file, never edit the table in README.md directly
- The table generation script uses `yq` for YAML processing
- Repository entries follow a consistent schema with required fields