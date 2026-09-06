#!/usr/bin/env python3
"""voice-inventory.py — fingerprint a workspace's voice-agent stack for snitch-voice STEP 0.

Walks a directory and prints, as detection evidence only:

  * platforms and providers it can fingerprint (packages, imports, env-var names, URLs, headers)
  * routes that look like telephony / platform webhooks or media-stream sockets
  * tool / function definitions it can parse, with the ones on the consequential-tool list marked
  * client-side files (browser / mobile bundles, public env prefixes) that reference a provider
  * files that look like exported assistant / agent configurations

It matches literal strings. It does not trace, verify, or judge, and nothing it prints is a
finding. Read its output the way you would read a grep: as the list of places to go look.

Usage:
    python3 voice-inventory.py <dir> [--json] [--max-files N]
    python3 voice-inventory.py --selftest

python3 stdlib only. Read-only: it never writes inside the scanned directory.
"""

from __future__ import annotations

import json
import os
import re
import sys
import tempfile
from collections import defaultdict

# --------------------------------------------------------------------------------------------
# Fingerprint tables. Literal, case-sensitive unless a regex says otherwise. Each hit records the
# file and line so the auditor can Read it. Vendor product names are allowed here: they are what
# the auditor greps for.
# --------------------------------------------------------------------------------------------

PLATFORMS: dict[str, dict[str, list[str]]] = {
    "twilio": {
        "packages": ["twilio", "@twilio/voice-sdk", "twilio-voice-react-native", "twilio-ruby", "twilio-go"],
        "env": ["TWILIO_ACCOUNT_SID", "TWILIO_AUTH_TOKEN", "TWILIO_API_KEY", "TWILIO_API_SECRET", "TWILIO_PHONE_NUMBER"],
        "strings": ["<Connect>", "<Stream ", "<ConversationRelay", "X-Twilio-Signature", "validateRequest", "twilio.webhook(", "RequestValidator", "calls.create(", "<Dial>", "<Record", "<Gather", "sendDigits", "SendDigits"],
    },
    "vonage": {
        "packages": ["@vonage/server-sdk", "@vonage/voice", "@vonage/jwt", "vonage", "nexmo"],
        "env": ["VONAGE_API_KEY", "VONAGE_API_SECRET", "VONAGE_APPLICATION_ID", "VONAGE_PRIVATE_KEY", "VONAGE_SIGNATURE_SECRET", "NEXMO_API_KEY"],
        "strings": ["ncco", "NCCO", "answer_url", "event_url", "verifySignature", "verify_signature", "createOutboundCall"],
    },
    "telnyx": {
        "packages": ["telnyx", "@telnyx/webrtc"],
        "env": ["TELNYX_API_KEY", "TELNYX_PUBLIC_KEY", "TELNYX_CONNECTION_ID"],
        "strings": ["telnyx-signature-ed25519", "telnyx-timestamp", "constructEvent", "construct_event", "skipSignatureVerification"],
    },
    "plivo": {
        "packages": ["plivo", "plivo-node"],
        "env": ["PLIVO_AUTH_ID", "PLIVO_AUTH_TOKEN"],
        "strings": ["X-Plivo-Signature-V3", "X-Plivo-Signature-V3-Nonce", "validate_v3_signature", "validateV3Signature"],
    },
    "signalwire": {
        "packages": ["@signalwire/compatibility-api", "@signalwire/realtime-api", "signalwire", "@signalwire/js"],
        "env": ["SIGNALWIRE_PROJECT_ID", "SIGNALWIRE_TOKEN", "SIGNALWIRE_SPACE_URL", "SIGNALWIRE_API_TOKEN"],
        "strings": ["x-signalwire-signature", "signalwire.com"],
    },
    "bandwidth": {
        "packages": ["@bandwidth/voice", "bandwidth-sdk"],
        "env": ["BW_ACCOUNT_ID", "BW_USERNAME", "BW_PASSWORD", "BANDWIDTH_ACCOUNT_ID"],
        "strings": ["<Transfer", "bandwidth.com"],
    },
    "vapi": {
        "packages": ["@vapi-ai/web", "@vapi-ai/server-sdk", "vapi_server_sdk", "@vapi-ai/react-native"],
        "env": ["VAPI_API_KEY", "VAPI_PRIVATE_KEY", "VAPI_PUBLIC_KEY", "VAPI_SERVER_SECRET", "VAPI_WEBHOOK_SECRET"],
        "strings": ["api.vapi.ai", "assistantOverrides", "variableValues", "serverUrl", "serverUrlSecret", "credentialId", "X-Vapi-Secret", "x-vapi-secret", "transferCall", "endCallPhrases", "endCallFunctionEnabled", "maxDurationSeconds", "silenceTimeoutSeconds", "hipaaEnabled", "assistant-request", "tool-calls", "allowedAssistantIds"],
    },
    "retell": {
        "packages": ["retell-sdk", "retell-client-js-sdk"],
        "env": ["RETELL_API_KEY", "RETELL_AGENT_ID"],
        "strings": ["api.retellai.com", "X-Retell-Signature", "x-retell-signature", "Retell.verify", "retell.verify", "llm_websocket_url", "transfer_destination", "press_digit", "max_call_duration_ms", "end_call_after_silence_ms", "data_storage_setting", "data_storage_retention_days", "pii_config", "create-web-call", "create-phone-call", "opt_out_sensitive_data_storage", "begin_message"],
    },
    "bland": {
        "packages": ["bland-ai", "@bland-ai/sdk"],
        "env": ["BLAND_API_KEY", "BLAND_AUTHORIZATION"],
        "strings": ["api.bland.ai", "transfer_phone_number", "transfer_list", "max_duration", "pathway_id", "voicemail_action"],
    },
    "elevenlabs": {
        "packages": ["@elevenlabs/elevenlabs-js", "@elevenlabs/client", "@elevenlabs/react", "elevenlabs", "@11labs/client", "@11labs/react"],
        "env": ["ELEVENLABS_API_KEY", "ELEVEN_API_KEY", "ELEVENLABS_AGENT_ID", "ELEVENLABS_WEBHOOK_SECRET", "XI_API_KEY"],
        "strings": ["api.elevenlabs.io", "convai", "get-signed-url", "getSignedUrl", "get_signed_url", "ElevenLabs-Signature", "enable_auth", "Conversation.startSession", "transfer_to_number", "transfer_to_agent", "conversation_config_override", "xi-api-key"],
    },
    "livekit": {
        "packages": ["livekit-server-sdk", "livekit-client", "@livekit/agents", "livekit-agents", "livekit-api", "livekit", "@livekit/components-react", "@livekit/react-native"],
        "env": ["LIVEKIT_URL", "LIVEKIT_API_KEY", "LIVEKIT_API_SECRET", "LIVEKIT_SIP_URI"],
        "strings": ["AccessToken(", "VideoGrant", "WebhookReceiver", "RoomConfiguration", "headers_to_attributes", "allowed_addresses", "allowed_numbers", "auth_username", "inbound_numbers", "TransferSIPParticipant", "transfer_sip_participant", "CreateSIPParticipant", "create_sip_participant", "sip.phoneNumber", "sip.trunkPhoneNumber", "function_tool", "ai_callable", "@llm.ai_callable"],
    },
    "pipecat": {
        "packages": ["pipecat-ai", "pipecat", "@pipecat-ai/client-js", "@pipecat-ai/client-react", "pipecat-ai-small-webrtc-prebuilt"],
        "env": ["DAILY_API_KEY", "DAILY_ROOM_URL", "PIPECAT_API_KEY"],
        "strings": ["TwilioFrameSerializer", "TelnyxFrameSerializer", "PlivoFrameSerializer", "DailyRESTHelper", "DailyTransport", "FastAPIWebsocketTransport", "register_function", "FunctionSchema", "ToolsSchema", "DailyDialinSettings", "dialout", "dial_out", "is_owner"],
    },
    "daily": {
        "packages": ["@daily-co/daily-js", "@daily-co/daily-react", "daily-python"],
        "env": ["DAILY_API_KEY", "DAILY_DOMAIN"],
        "strings": ["api.daily.co", "meeting-tokens", "meeting_tokens", "dialOut", "dial_out"],
    },
    "vocode": {
        "packages": ["vocode", "vocode-core"],
        "env": ["VOCODE_API_KEY"],
        "strings": ["StreamingConversation", "TelephonyServer", "TwilioConfig", "VonageConfig"],
    },
    "openai-realtime": {
        "packages": ["openai", "@openai/agents", "@openai/agents-realtime", "openai-agents", "@openai/realtime-api-beta"],
        "env": ["OPENAI_API_KEY", "OPENAI_WEBHOOK_SECRET"],
        "strings": ["api.openai.com/v1/realtime", "/v1/realtime/client_secrets", "/v1/realtime/calls", "/v1/realtime/sessions", "realtime.call.incoming", "session.update", "RealtimeAgent", "RealtimeSession", "webhooks.unwrap", "webhook-signature", "gpt-realtime", "gpt-4o-realtime", "OpenAI-Safety-Identifier", "dangerouslyAllowBrowser"],
    },
    "gemini-live": {
        "packages": ["@google/genai", "google-genai", "@google/generative-ai", "google-generativeai"],
        "env": ["GEMINI_API_KEY", "GOOGLE_API_KEY", "GOOGLE_GENAI_API_KEY"],
        "strings": ["auth_tokens.create", "authTokens.create", "live_connect_constraints", "liveConnectConstraints", "bidi_generate_content_setup", "lock_additional_fields", "lockAdditionalFields", "new_session_expire_time", "newSessionExpireTime", "ai.live.connect", "live.connect(", "BidiGenerateContent"],
    },
    "deepgram": {
        "packages": ["@deepgram/sdk", "deepgram-sdk", "deepgram"],
        "env": ["DEEPGRAM_API_KEY", "DEEPGRAM_PROJECT_ID"],
        "strings": ["api.deepgram.com", "agent.deepgram.com", "/v1/auth/grant", "auth/grant", "ttl_seconds", "redact=", "redact:", "agent.think", "endpoint.headers", "\"type\": \"Settings\""],
    },
    "assemblyai": {
        "packages": ["assemblyai"],
        "env": ["ASSEMBLYAI_API_KEY"],
        "strings": ["api.assemblyai.com", "redact_pii", "streaming.assemblyai.com", "temporary-token", "temporary_token"],
    },
    "hume": {
        "packages": ["hume", "@humeai/voice", "@humeai/voice-react"],
        "env": ["HUME_API_KEY", "HUME_SECRET_KEY", "HUME_CONFIG_ID"],
        "strings": ["api.hume.ai", "fetchAccessToken", "fetch_access_token", "/v0/evi/"],
    },
    "cartesia": {
        "packages": ["@cartesia/cartesia-js", "cartesia"],
        "env": ["CARTESIA_API_KEY"],
        "strings": ["api.cartesia.ai", "X-API-Key"],
    },
    "azure-speech": {
        "packages": ["microsoft-cognitiveservices-speech-sdk", "azure-cognitiveservices-speech", "@azure/openai"],
        "env": ["AZURE_SPEECH_KEY", "AZURE_SPEECH_REGION", "SPEECH_KEY", "AZURE_OPENAI_API_KEY", "AZURE_OPENAI_ENDPOINT"],
        "strings": ["SpeechConfig", "cognitiveservices.azure.com", "/realtime?", "issueToken", "sts/v1.0/issueToken"],
    },
    "amazon-connect": {
        "packages": ["@aws-sdk/client-connect", "@aws-sdk/client-lex-runtime-v2", "boto3"],
        "env": ["CONNECT_INSTANCE_ID", "LEX_BOT_ID", "LEX_BOT_ALIAS_ID"],
        "strings": ["connect.amazonaws.com", "StartOutboundVoiceContact", "start_outbound_voice_contact", "ContactFlow", "contactAttributes", "Contact Lens", "RecordedParticipants", "CommunicationLimitsConfig", "lexv2"],
    },
    "ultravox": {
        "packages": ["ultravox-client", "ultravox"],
        "env": ["ULTRAVOX_API_KEY"],
        "strings": ["api.ultravox.ai", "joinUrl", "selectedTools", "maxDuration"],
    },
    "jambonz": {
        "packages": ["@jambonz/node-client", "@jambonz/node-client-ws"],
        "env": ["JAMBONZ_ACCOUNT_SID", "JAMBONZ_API_KEY", "JAMBONZ_WEBHOOK_SECRET"],
        "strings": ["jambonz", "\"verb\"", "llm_url", "call_hook"],
    },
    "asterisk-freeswitch": {
        "packages": ["ari-client", "asterisk-ari-client", "ESL", "greenswitch"],
        "env": ["ARI_USERNAME", "ARI_PASSWORD", "FREESWITCH_PASSWORD", "ESL_PASSWORD"],
        "strings": ["/ari/", "originate", "uuid_bridge", "sofia", "extensions.conf", "dialplan"],
    },
}

CONSEQUENTIAL_TOOL_PATTERNS = [
    r"transfer", r"forward", r"\bdial\b", r"call[_-]?back", r"outbound", r"redial",
    r"payment", r"\bpay\b", r"charge", r"refund", r"invoice", r"balance", r"transfer[_-]?funds", r"wire",
    r"update[_-]?(account|address|email|phone|profile|contact)", r"change[_-]?(address|email|phone|password|pin)",
    r"cancel", r"reschedule", r"\bbook", r"schedule", r"appointment",
    r"send[_-]?(sms|text|email|message)", r"\bsms\b", r"notify",
    r"end[_-]?call", r"hang[_-]?up", r"endCall",
    r"dtmf", r"press[_-]?digit", r"send[_-]?digits",
    r"verify", r"otp", r"lookup", r"look[_-]?up", r"get[_-]?(account|customer|order|patient)",
    r"delete", r"remove", r"reset",
]
CONSEQUENTIAL_RE = re.compile("|".join(CONSEQUENTIAL_TOOL_PATTERNS), re.IGNORECASE)

# Tool / function definition shapes across SDKs and JSON configs.
TOOL_DEF_PATTERNS = [
    # JSON / JS object: "name": "transfer_call"  inside tools/functions arrays (we just capture names)
    re.compile(r'(?<![A-Za-z0-9_])["\']?name["\']?\s*:\s*["\']([A-Za-z_][A-Za-z0-9_\-]*)["\']'),
    # OpenAI-style: { type: "function", function: { name: "x" } } handled by the above
    # Python decorators: @function_tool / @llm.ai_callable / @tool  followed by def name(
    re.compile(r'@(?:function_tool|llm\.ai_callable|ai_callable|tool|agents\.function_tool)[^\n]*\n\s*(?:async\s+)?def\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('),
    # Pipecat: register_function("name", ...)
    re.compile(r'register_function\(\s*["\']([A-Za-z_][A-Za-z0-9_\-]*)["\']'),
    # Vercel AI SDK / TS: tool({ name }) or tools: { transferCall: tool(...) }
    re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*:\s*tool\(', re.MULTILINE),
    # Anthropic / generic: name: 'x' with type: 'function' nearby is covered by the first pattern
    # Retell general_tools: "type": "transfer_call"
    re.compile(r'["\']type["\']\s*:\s*["\'](transfer_call|end_call|press_digit|transferCall|endCall|dtmf|book_appointment|transfer_to_number|transfer_to_agent)["\']'),
]

ROUTE_PATTERNS = [
    # Express / Fastify / Hono / Koa / Flask / FastAPI / Django / Rails / Go / Next route files
    re.compile(r'\.(?:get|post|all|route|put)\(\s*["\']([^"\']+)["\']'),
    re.compile(r'@(?:app|router|api|bp|blueprint)\.(?:get|post|route|websocket|api_route)\(\s*["\']([^"\']+)["\']'),
    re.compile(r'path\(\s*["\']([^"\']+)["\']'),
    re.compile(r'(?:HandleFunc|Handle)\(\s*["\']([^"\']+)["\']'),
    re.compile(r'(?:post|get)\s+["\']([^"\']+)["\']\s*(?:,|=>|to:)'),
]
VOICE_ROUTE_HINT = re.compile(
    r"voice|twiml|incoming|call|webhook|hook|vapi|retell|bland|eleven|livekit|media|stream|ws\b|socket|"
    r"tool|function|answer|event|ncco|status|recording|transcript|post-call|postcall|token|session|"
    r"client[_-]?secret|ephemeral|sip|dial|transfer|sms|dtmf",
    re.IGNORECASE,
)
WEBSOCKET_HINT = re.compile(r"websocket|\.ws\(|WebSocketServer|websockets\.serve|@app\.websocket|socket\.io|wss?://", re.IGNORECASE)

CLIENT_ENV_PREFIXES = ["NEXT_PUBLIC_", "VITE_", "REACT_APP_", "EXPO_PUBLIC_", "NUXT_PUBLIC_", "PUBLIC_", "GATSBY_", "VUE_APP_", "SVELTE_PUBLIC_", "ANGULAR_"]
CLIENT_PATH_HINTS = re.compile(r"(^|/)(public|static|client|frontend|web|app|src/app|src/pages|pages|components|hooks|ios|android|mobile|assets)(/|$)", re.IGNORECASE)
CLIENT_EXTS = {".html", ".jsx", ".tsx", ".vue", ".svelte", ".swift", ".kt", ".dart", ".m"}
SERVER_HINT = re.compile(r"(^|/)(server|api|backend|functions|lambda|worker|workers|routes|handlers|pages/api|app/api)(/|$)", re.IGNORECASE)

SECRET_SHAPES = [
    (re.compile(r"\bsk-[A-Za-z0-9_\-]{20,}"), "openai-style secret key"),
    (re.compile(r"\bek_[A-Za-z0-9_\-]{10,}"), "openai realtime ephemeral key literal"),
    (re.compile(r"\bAC[0-9a-fA-F]{32}\b"), "twilio account sid"),
    (re.compile(r"\bSK[0-9a-fA-F]{32}\b"), "twilio api key sid"),
    (re.compile(r"\bkey_[0-9a-f]{32}\b"), "retell-style api key"),
    (re.compile(r"\bAPI[A-Za-z0-9]{20,}\b"), "livekit-style api key"),
    (re.compile(r"\beyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{10,}"), "jwt literal"),
]

CONFIG_FILE_HINT = re.compile(r"(assistant|agent|pathway|ncco|twiml|voice[_-]?config|retell|vapi|bland|eleven|convai|dispatch[_-]?rule|sip[_-]?trunk|contact[_-]?flow)", re.IGNORECASE)
CONFIG_EXTS = {".json", ".yaml", ".yml", ".toml", ".xml"}
CONFIG_KEYS = re.compile(r'"(?:firstMessage|first_message|begin_message|welcomeGreeting|systemPrompt|system_prompt|instructions|general_prompt|voice_id|voiceId|serverUrl|server_url|webhook_url|webhookUrl|tools|functions|general_tools|transferCall|transfer_call|recordingEnabled|record|maxDurationSeconds|max_call_duration_ms|max_duration|silenceTimeoutSeconds|end_call_after_silence_ms|endCallPhrases|hipaaEnabled|data_storage_setting|assistantId|agent_id)"')

TUNNEL_RE = re.compile(r"https?://[a-z0-9\-]+\.(ngrok(-free)?\.(app|io|dev)|loca\.lt|trycloudflare\.com|serveo\.net|localhost\.run|pinggy\.io)|wss?://[a-z0-9\-]+\.ngrok", re.IGNORECASE)
PLAINTEXT_WEBHOOK_RE = re.compile(r'["\'](http://|ws://)(?!localhost|127\.0\.0\.1|0\.0\.0\.0)[^"\']+["\']')

SKIP_DIRS = {"node_modules", ".git", "dist", "build", ".next", ".nuxt", ".output", ".venv", "venv", "__pycache__", "coverage", ".turbo", ".cache", "vendor", "target", "Pods", ".gradle", ".idea", ".vscode"}
TEXT_EXTS = {".js", ".mjs", ".cjs", ".ts", ".tsx", ".jsx", ".py", ".rb", ".go", ".java", ".kt", ".swift", ".dart", ".php", ".cs", ".rs", ".json", ".yaml", ".yml", ".toml", ".xml", ".html", ".vue", ".svelte", ".env", ".md", ".txt", ".cfg", ".ini", ".conf", ".tf", ".hcl", ".sh", ".lock", ".m"}
MAX_BYTES = 1_500_000


def is_text_candidate(path: str) -> bool:
    base = os.path.basename(path)
    if base.startswith(".env"):
        return True
    if base in ("package.json", "requirements.txt", "pyproject.toml", "Pipfile", "go.mod", "Gemfile", "pubspec.yaml", "Podfile", "build.gradle", "Cargo.toml", "composer.json"):
        return True
    _, ext = os.path.splitext(base)
    return ext.lower() in TEXT_EXTS


def iter_files(root: str, max_files: int):
    n = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".git")]
        for fn in filenames:
            p = os.path.join(dirpath, fn)
            if not is_text_candidate(p):
                continue
            try:
                if os.path.getsize(p) > MAX_BYTES:
                    continue
            except OSError:
                continue
            yield p
            n += 1
            if n >= max_files:
                return


def rel(root: str, path: str) -> str:
    return os.path.relpath(path, root).replace(os.sep, "/")


def is_client_path(relpath: str) -> bool:
    _, ext = os.path.splitext(relpath)
    if SERVER_HINT.search(relpath):
        return False
    if ext.lower() in CLIENT_EXTS:
        return True
    return bool(CLIENT_PATH_HINTS.search(relpath))


def scan(root: str, max_files: int = 20000) -> dict:
    root = os.path.abspath(root)
    platforms: dict[str, dict] = defaultdict(lambda: {"packages": [], "env": [], "strings": [], "files": set()})
    routes: list[dict] = []
    sockets: list[dict] = []
    tools: dict[str, dict] = {}
    client_refs: list[dict] = []
    public_env: list[dict] = []
    secret_shapes: list[dict] = []
    configs: list[dict] = []
    tunnels: list[dict] = []
    plaintext: list[dict] = []
    files_scanned = 0

    for path in iter_files(root, max_files):
        rp = rel(root, path)
        try:
            with open(path, "r", encoding="utf-8", errors="replace") as fh:
                text = fh.read()
        except OSError:
            continue
        files_scanned += 1
        lines = text.split("\n")
        base = os.path.basename(path)
        is_manifest = base in ("package.json", "requirements.txt", "pyproject.toml", "Pipfile", "go.mod", "Gemfile", "pubspec.yaml", "Podfile", "build.gradle", "Cargo.toml", "composer.json") or base.endswith(".lock")
        client = is_client_path(rp)

        # platform fingerprints
        for name, fp in PLATFORMS.items():
            hit = False
            if is_manifest:
                for pkg in fp["packages"]:
                    if re.search(r'["\'\s/]' + re.escape(pkg) + r'["\'\s@=:>]', text) or re.search(r'^\s*' + re.escape(pkg) + r'\b', text, re.M):
                        platforms[name]["packages"].append({"pkg": pkg, "file": rp})
                        hit = True
            for i, line in enumerate(lines, 1):
                for pkg in fp["packages"]:
                    if ("import" in line or "require(" in line or "from " in line) and pkg in line:
                        platforms[name]["packages"].append({"pkg": pkg, "file": rp, "line": i})
                        hit = True
                for ev in fp["env"]:
                    if ev in line:
                        platforms[name]["env"].append({"var": ev, "file": rp, "line": i})
                        hit = True
                for s in fp["strings"]:
                    if s in line:
                        platforms[name]["strings"].append({"s": s, "file": rp, "line": i})
                        hit = True
            if hit:
                platforms[name]["files"].add(rp)

        # routes and sockets
        for i, line in enumerate(lines, 1):
            for pat in ROUTE_PATTERNS:
                for m in pat.finditer(line):
                    route = m.group(1)
                    if VOICE_ROUTE_HINT.search(route) or VOICE_ROUTE_HINT.search(line):
                        routes.append({"route": route, "file": rp, "line": i, "snippet": line.strip()[:160]})
            if WEBSOCKET_HINT.search(line) and (VOICE_ROUTE_HINT.search(line) or VOICE_ROUTE_HINT.search(rp)):
                sockets.append({"file": rp, "line": i, "snippet": line.strip()[:160]})

        # tool definitions
        for pat in TOOL_DEF_PATTERNS:
            for m in pat.finditer(text):
                name = m.group(1)
                # only keep names that appear near tool-ish context, to keep noise down
                start = max(0, m.start() - 400)
                ctx = text[start:m.end() + 200]
                if not re.search(r"tool|function|parameters|description|general_tools|transfer|end_call|press_digit", ctx, re.IGNORECASE):
                    continue
                line_no = text.count("\n", 0, m.start()) + 1
                key = f"{name}@{rp}"
                if key in tools:
                    continue
                tools[key] = {
                    "name": name,
                    "file": rp,
                    "line": line_no,
                    "consequential": bool(CONSEQUENTIAL_RE.search(name)),
                    "client_side": client,
                }

        # client-side references and public env prefixes
        for i, line in enumerate(lines, 1):
            for prefix in CLIENT_ENV_PREFIXES:
                for m in re.finditer(re.escape(prefix) + r"[A-Z0-9_]+", line):
                    var = m.group(0)
                    if re.search(r"KEY|SECRET|TOKEN|PASSWORD|SID|PRIVATE", var):
                        public_env.append({"var": var, "file": rp, "line": i})
            if client:
                for name, fp in PLATFORMS.items():
                    for ev in fp["env"]:
                        if ev in line and re.search(r"KEY|SECRET|TOKEN|PASSWORD|SID|PRIVATE", ev):
                            client_refs.append({"platform": name, "var": ev, "file": rp, "line": i})
                    for s in fp["strings"]:
                        if s in line and s in ("dangerouslyAllowBrowser", "xi-api-key", "X-API-Key", "auth_tokens.create", "assistantOverrides", "session.update", "AccessToken("):
                            client_refs.append({"platform": name, "marker": s, "file": rp, "line": i})
            for rx, label in SECRET_SHAPES:
                if rx.search(line) and "example" not in line.lower() and "xxx" not in line.lower():
                    secret_shapes.append({"shape": label, "file": rp, "line": i})
                    break
            for m in TUNNEL_RE.finditer(line):
                tunnels.append({"url": m.group(0), "file": rp, "line": i})
            if PLAINTEXT_WEBHOOK_RE.search(line) and VOICE_ROUTE_HINT.search(line):
                plaintext.append({"file": rp, "line": i, "snippet": line.strip()[:160]})

        # exported configs
        _, ext = os.path.splitext(base)
        if ext.lower() in CONFIG_EXTS and (CONFIG_FILE_HINT.search(rp) or len(CONFIG_KEYS.findall(text)) >= 3):
            keys = sorted(set(CONFIG_KEYS.findall(text)))
            if keys:
                configs.append({"file": rp, "keys": keys})

    out = {
        "root": root,
        "files_scanned": files_scanned,
        "platforms": {
            k: {
                "packages": v["packages"][:50],
                "env": v["env"][:50],
                "strings": v["strings"][:80],
                "files": sorted(v["files"])[:80],
            }
            for k, v in platforms.items()
            if v["files"]
        },
        "routes": routes[:300],
        "sockets": sockets[:100],
        "tools": sorted(tools.values(), key=lambda t: (not t["consequential"], t["file"], t["line"]))[:400],
        "client_side_references": client_refs[:200],
        "public_env_secrets": public_env[:200],
        "secret_shaped_literals": secret_shapes[:100],
        "exported_configs": configs[:100],
        "tunnel_urls": tunnels[:100],
        "plaintext_voice_urls": plaintext[:100],
    }
    return out


def fmt(inv: dict) -> str:
    lines = []
    lines.append(f"snitch-voice inventory — {inv['root']} ({inv['files_scanned']} files read)")
    lines.append("")
    lines.append("PLATFORMS AND PROVIDERS (detection signals, not findings)")
    if not inv["platforms"]:
        lines.append("  none fingerprinted — check the stack by hand before assuming there is no voice agent here")
    for name, v in inv["platforms"].items():
        sig = len(v["packages"]) + len(v["env"]) + len(v["strings"])
        lines.append(f"  {name:<20} {sig:>4} signals in {len(v['files'])} files: " + ", ".join(v["files"][:6]) + (" …" if len(v["files"]) > 6 else ""))
    lines.append("")
    lines.append(f"VOICE-LOOKING ROUTES ({len(inv['routes'])})")
    for r in inv["routes"][:60]:
        lines.append(f"  {r['file']}:{r['line']}  {r['route']}")
    lines.append("")
    lines.append(f"WEBSOCKET / MEDIA-STREAM SITES ({len(inv['sockets'])})")
    for s in inv["sockets"][:40]:
        lines.append(f"  {s['file']}:{s['line']}  {s['snippet']}")
    lines.append("")
    cons = [t for t in inv["tools"] if t["consequential"]]
    lines.append(f"TOOL / FUNCTION DEFINITIONS ({len(inv['tools'])} found, {len(cons)} on the consequential list)")
    for t in inv["tools"][:80]:
        mark = "!! " if t["consequential"] else "   "
        side = " [client-side]" if t["client_side"] else ""
        lines.append(f"  {mark}{t['name']:<32} {t['file']}:{t['line']}{side}")
    lines.append("")
    lines.append(f"CLIENT-SIDE PROVIDER REFERENCES ({len(inv['client_side_references'])})")
    for c in inv["client_side_references"][:40]:
        what = c.get("var") or c.get("marker")
        lines.append(f"  {c['file']}:{c['line']}  {c['platform']}: {what}")
    lines.append("")
    lines.append(f"PUBLIC-PREFIXED SECRET-LOOKING ENV NAMES ({len(inv['public_env_secrets'])})")
    for p in inv["public_env_secrets"][:40]:
        lines.append(f"  {p['file']}:{p['line']}  {p['var']}")
    lines.append("")
    lines.append(f"SECRET-SHAPED LITERALS ({len(inv['secret_shaped_literals'])}) — values are not printed; go Read the line")
    for s in inv["secret_shaped_literals"][:40]:
        lines.append(f"  {s['file']}:{s['line']}  {s['shape']}")
    lines.append("")
    lines.append(f"EXPORTED ASSISTANT / AGENT CONFIGS ({len(inv['exported_configs'])})")
    for c in inv["exported_configs"][:40]:
        lines.append(f"  {c['file']}  keys: {', '.join(c['keys'][:12])}")
    lines.append("")
    lines.append(f"TUNNEL URLS ({len(inv['tunnel_urls'])})")
    for t in inv["tunnel_urls"][:20]:
        lines.append(f"  {t['file']}:{t['line']}  {t['url']}")
    lines.append("")
    lines.append(f"PLAINTEXT http:// OR ws:// VOICE URLS ({len(inv['plaintext_voice_urls'])})")
    for p in inv["plaintext_voice_urls"][:20]:
        lines.append(f"  {p['file']}:{p['line']}  {p['snippet']}")
    lines.append("")
    lines.append("This is a literal-string inventory. Every line above is a place to Read, not a finding.")
    return "\n".join(lines)


def selftest() -> int:
    with tempfile.TemporaryDirectory() as td:
        os.makedirs(os.path.join(td, "src", "routes"))
        os.makedirs(os.path.join(td, "public"))
        with open(os.path.join(td, "package.json"), "w") as f:
            f.write('{"dependencies": {"twilio": "^5.0.0", "@vapi-ai/web": "^2.0.0", "openai": "^4.0.0"}}')
        with open(os.path.join(td, "src", "routes", "voice.ts"), "w") as f:
            f.write(
                "import twilio from 'twilio';\n"
                "app.post('/incoming-call', (req, res) => { res.type('text/xml').send(twiml); });\n"
                "app.get('/media-stream', { websocket: true }, (conn) => {});\n"
                "const tools = [{ type: 'function', function: { name: 'transfer_call', description: 'x', parameters: {} } },\n"
                "  { type: 'function', function: { name: 'get_weather', description: 'x', parameters: {} } }];\n"
                "const url = 'wss://abc123.ngrok-free.app/media-stream';\n"
                "const hook = 'http://example.com/voice/webhook';\n"
            )
        with open(os.path.join(td, "public", "app.js"), "w") as f:
            f.write("const key = process.env.NEXT_PUBLIC_VAPI_PRIVATE_KEY;\nconst c = new OpenAI({ apiKey, dangerouslyAllowBrowser: true });\n")
        with open(os.path.join(td, "assistant.json"), "w") as f:
            f.write('{"firstMessage": "hi", "serverUrl": "https://x", "maxDurationSeconds": 600, "tools": []}')
        inv = scan(td)
    checks = [
        ("twilio fingerprinted", "twilio" in inv["platforms"]),
        ("vapi fingerprinted", "vapi" in inv["platforms"]),
        ("openai fingerprinted", "openai-realtime" in inv["platforms"]),
        ("route found", any(r["route"] == "/incoming-call" for r in inv["routes"])),
        ("socket found", len(inv["sockets"]) >= 1),
        ("consequential tool marked", any(t["name"] == "transfer_call" and t["consequential"] for t in inv["tools"])),
        ("benign tool unmarked", any(t["name"] == "get_weather" and not t["consequential"] for t in inv["tools"])),
        ("public env secret found", any(p["var"] == "NEXT_PUBLIC_VAPI_PRIVATE_KEY" for p in inv["public_env_secrets"])),
        ("client marker found", any(c.get("marker") == "dangerouslyAllowBrowser" for c in inv["client_side_references"])),
        ("config found", any(c["file"] == "assistant.json" for c in inv["exported_configs"])),
        ("tunnel found", len(inv["tunnel_urls"]) == 1),
        ("plaintext url found", len(inv["plaintext_voice_urls"]) == 1),
    ]
    ok = True
    for name, passed in checks:
        print(("PASS " if passed else "FAIL ") + name)
        ok = ok and passed
    print("selftest " + ("OK" if ok else "FAILED"))
    return 0 if ok else 1


def main(argv: list[str]) -> int:
    if "--selftest" in argv:
        return selftest()
    as_json = "--json" in argv
    max_files = 20000
    if "--max-files" in argv:
        try:
            max_files = int(argv[argv.index("--max-files") + 1])
        except (IndexError, ValueError):
            print("--max-files needs an integer", file=sys.stderr)
            return 2
    args = [a for a in argv if not a.startswith("--") and not a.isdigit()]
    if not args:
        print(__doc__)
        return 2
    root = args[0]
    if not os.path.isdir(root):
        print(f"not a directory: {root}", file=sys.stderr)
        return 2
    inv = scan(root, max_files)
    if as_json:
        print(json.dumps(inv, indent=2))
    else:
        print(fmt(inv))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
