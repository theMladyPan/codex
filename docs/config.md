# Configuration

For basic configuration instructions, see [this documentation](https://developers.openai.com/codex/config-basic).

For advanced configuration instructions, see [this documentation](https://developers.openai.com/codex/config-advanced).

For a full configuration reference, see [this documentation](https://developers.openai.com/codex/config-reference).

## OpenAI-compatible custom providers

Custom entries under `model_providers` can point at OpenAI-compatible APIs, including
localhost-served LLMs. When the active provider does not require OpenAI auth, Codex now uses that
provider for model discovery too, so `/models` responses from the custom endpoint can populate the
available model list.

### Quick setup for a custom endpoint and API key

Add a custom provider to `~/.codex/config.toml` and make it the active provider:

```toml
model_provider = "my-openai-compatible"
model = "my-model-name"

[model_providers.my-openai-compatible]
name = "My OpenAI-compatible server"
base_url = "http://localhost:1234/v1"
env_key = "MY_LLM_API_KEY"
wire_api = "responses"
requires_openai_auth = false
```

Then export the API key before starting Codex:

```bash
export MY_LLM_API_KEY="your-api-key-here"
```

Then start your compiled binary normally, for example:

```bash
./target/release/codex
```

Notes:

- `base_url` should point at the root of the OpenAI-compatible API, usually ending in `/v1`.
- `env_key` is the name of the environment variable that stores the API key. For a local server
  without auth, you can omit `env_key`.
- `wire_api` should be set to `"responses"`.
- `requires_openai_auth = false` tells Codex to use this provider directly instead of requiring
  ChatGPT/OpenAI login.
- `model` lets you force a specific model slug even if it does not appear in the model picker.

### If your model is not visible in the model list

Codex loads the model list from the active provider's `/models` endpoint. If your custom endpoint
does not implement `/models`, or if it does not return your model in a picker-visible form, the
model may not appear in the UI list even though you can still use it.

In that case, set the model explicitly in `~/.codex/config.toml`:

```toml
model_provider = "my-openai-compatible"
model = "my-model-name"
```

and start the binary again. Codex will use that model even when it is missing from the picker.

## Connecting to MCP servers

Codex can connect to MCP servers configured in `~/.codex/config.toml`. See the configuration reference for the latest MCP server options:

- https://developers.openai.com/codex/config-reference

## Apps (Connectors)

Use `$` in the composer to insert a ChatGPT connector; the popover lists accessible
apps. The `/apps` command lists available and installed apps. Connected apps appear first
and are labeled as connected; others are marked as can be installed.

## Notify

Codex can run a notification hook when the agent finishes a turn. See the configuration reference for the latest notification settings:

- https://developers.openai.com/codex/config-reference

When Codex knows which client started the turn, the legacy notify JSON payload also includes a top-level `client` field. The TUI reports `codex-tui`, and the app server reports the `clientInfo.name` value from `initialize`.

## JSON Schema

The generated JSON Schema for `config.toml` lives at `codex-rs/core/config.schema.json`.

## SQLite State DB

Codex stores the SQLite-backed state DB under `sqlite_home` (config key) or the
`CODEX_SQLITE_HOME` environment variable. When unset, WorkspaceWrite sandbox
sessions default to a temp directory; other modes default to `CODEX_HOME`.

## Custom CA Certificates

Codex can trust a custom root CA bundle for outbound HTTPS and secure websocket
connections when enterprise proxies or gateways intercept TLS. This applies to
login flows and to Codex's other external connections, including Codex
components that build reqwest clients or secure websocket clients through the
shared `codex-client` CA-loading path and remote MCP connections that use it.

Set `CODEX_CA_CERTIFICATE` to the path of a PEM file containing one or more
certificate blocks to use a Codex-specific CA bundle. If
`CODEX_CA_CERTIFICATE` is unset, Codex falls back to `SSL_CERT_FILE`. If
neither variable is set, Codex uses the system root certificates.

`CODEX_CA_CERTIFICATE` takes precedence over `SSL_CERT_FILE`. Empty values are
treated as unset.

The PEM file may contain multiple certificates. Codex also tolerates OpenSSL
`TRUSTED CERTIFICATE` labels and ignores well-formed `X509 CRL` sections in the
same bundle. If the file is empty, unreadable, or malformed, the affected Codex
HTTP or secure websocket connection reports a user-facing error that points
back to these environment variables.

## Notices

Codex stores "do not show again" flags for some UI prompts under the `[notice]` table.

## Plan mode defaults

`plan_mode_reasoning_effort` lets you set a Plan-mode-specific default reasoning
effort override. When unset, Plan mode uses the built-in Plan preset default
(currently `medium`). When explicitly set (including `none`), it overrides the
Plan preset. The string value `none` means "no reasoning" (an explicit Plan
override), not "inherit the global default". There is currently no separate
config value for "follow the global default in Plan mode".

## Realtime start instructions

`experimental_realtime_start_instructions` lets you replace the built-in
developer message Codex inserts when realtime becomes active. It only affects
the realtime start message in prompt history and does not change websocket
backend prompt settings or the realtime end/inactive message.

Ctrl+C/Ctrl+D quitting uses a ~1 second double-press hint (`ctrl + c again to quit`).
