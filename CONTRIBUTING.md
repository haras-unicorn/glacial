# Contributing to Glacial

The project is a dual-language project. We are using python for AI-powered audio
synthesis and javascript for live-coding (composition).

## Structure

Generated via `^eza --tree --git-ignore` and trimmed:

```text
├── biome.json
├── CHANGELOG.md
├── CRUSH.md
├── cspell.yaml
├── flake.lock
├── flake.nix
├── justfile
├── LICENSE.md
├── package.json
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── pyproject.toml
├── README.md
├── scripts
│   └── flake
│       └── ...
├── src
│   ├── composition
│   │   ├── cspell.yaml
│   │   ├── package.json
│   │   ├── src
│   │   │   └── ...
│   │   └── tsconfig.json
│   └── synthesis
│       ├── cspell.yaml
│       ├── pyproject.toml
│       └── src
│           └── glacial_synthesis
│               └── ...
├── tsconfig.json
└── uv.lock
```

## Tooling

Important tooling that is not language-specific:

- [just](https://github.com/casey/just) is used as a command runner
- [nushell](https://github.com/nushell/nushell) is used as a shell and for
  helper scripts
- [nix](https://github.com/NixOS/nixpkgs) is used for reproducible environments
- [crush](https://github.com/charmbracelet/crush) is used for AI-assisted coding
- [prettier](https://github.com/prettier/prettier) is used for formatting
  miscellaneous files
- [cspell](https://github.com/streetsidesoftware/cspell) is used for
  spell-checking

Important tooling that is javascript-specific:

- [nodejs](https://github.com/nodejs/node) version 24 is used as the runtime
- [pnpm](https://github.com/pnpm/pnpm) version 9 is used as the package manager
- [biome](https://github.com/biomejs/biome) is used to format, lint and provide
  LSP functionality for javascript-related files
- [typescript](https://github.com/microsoft/TypeScript) is used for
  type-checking and LSP functionality
- [tsx](https://github.com/privatenumber/tsx) is used as a REPL

Important tooling that is python-specific:

- [python](https://github.com/python/cpython) version 3.11 is used as the
  runtime
- [uv](https://github.com/astral-sh/uv) is used as the package manager
- [ruff](https://github.com/astral-sh/ruff) is used as a formatter and linter
- [mypy](https://github.com/python/mypy) is used for type-checking
- [pylsp](https://github.com/python-lsp/python-lsp-server) is used for LSP
  functionality

## Libraries

Important libraries that are javascript-specific:

- [strudel](https://codeberg.org/uzu/strudel) is used for a web-based
  live-coding environment

Important libraries that are python-specific:

- [audiocraft](https://github.com/facebookresearch/audiocraft) is used for
  sample synthesis
