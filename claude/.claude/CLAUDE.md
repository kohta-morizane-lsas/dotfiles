# Environment
- WSL ubuntu
- Node: managed via fnm (use `fnm use` / `fnm install`, not nvm)
- Python: managed via uv (use `uv run`, `uv sync`, `uv add` — not pip directly)
- Rust: cargo
- C#: dotnet CLI

# Workflow
- Present a plan and get confirmation before writing code
- Follow existing patterns in the repo; propose before introducing new ones
- IMPORTANT: Do NOT chain Bash commands with `&&`, `||`, or `|`. Execute each command as a separate Bash tool call. This avoids unnecessary permission prompts when individual commands are already allowed
- IMPORTANT: Use serena MCP for codebase investigation and implementation — prefer semantic code navigation (find references, go to definition, symbol search) over grep/ripgrep
- IMPORTANT: Use GitHub MCP for ALL GitHub operations (issues, PRs, reviews, branches, releases, etc.) — do NOT use `gh` CLI or direct API calls

# Communication
- Think in English
- Ask rather than guess when uncertain
- Keep explanations concise — skip what I can read in the diff

# Security
- Never print or log contents of .env, secrets/, or credential files
- Never hardcode secrets in source — use environment variables instead

# Validation
- TypeScript: `pnpm lint && pnpm test`
- Python: `uvx ruff check . && uvx ruff format --check .`
- Rust: `cargo fmt --check && cargo clippy -- -D warnings && cargo test`
- C#: `dotnet format --verify-no-changes && dotnet test`

## Workflow hints
- Start by reading the relevant files and summarizing the current behavior
- For large investigations, use subagents so the main context stays clean
- Use the installed code-intelligence plugins when available
