set windows-shell := ["nu.exe", "-c"]
set shell := ["nu", "-c"]

root := absolute_path('')

default:
    @just --choose

orchestration:
    concurrently \
      --names composition,orchestration \
      `nu -c "cd '{{ root }}/src/composition'; exec tsup --watch"` \
      `glacial-orchestration '{{ root }}/src/composition/dist/index.js'`

format:
    cd '{{ root }}'; just --unstable --fmt
    nixfmt ...(fd '.*.nix$' '{{ root }}' | lines)
    prettier --write '{{ root }}'
    ruff check --fix '{{ root }}'
    ruff format '{{ root }}'
    biome check --write '{{ root }}'

lint:
    cd '{{ root }}'; just --unstable --fmt --check
    nixfmt --check ...(fd '.*.nix$' '{{ root }}' | lines)
    prettier --check '{{ root }}'
    cspell lint '{{ root }}' --no-progress
    markdownlint --ignore-path .gitignore '{{ root }}'
    if (markdown-link-check \
      --config '{{ root }}/.markdown-link-check.json' \
      ...(fd '^.*.md$' '{{ root }}' | lines) \
      | rg -q error \
      | complete \
      | get exit_code) == 0 { exit 1 }
    ruff check '{{ root }}'
    mypy '{{ root }}'
    biome lint '{{ root }}'
    cd '{{ root }}'; tsc --noEmit
