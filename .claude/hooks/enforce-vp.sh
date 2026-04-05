#!/bin/bash
# .claude/hooks/enforce-vp.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# --- Specific rules with tailored guidance (checked first) ---

# Block "npx oxlint" / "pnpx oxlint" / "<pm> dlx/exec/run oxlint" → tell Claude to use vp lint
if echo "$COMMAND" | grep -qE '\b(npx|pnpx) oxlint\b|\b(npm|pnpm|yarn) (dlx|exec|run) oxlint\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not run oxlint through a package manager. Use `vp lint` instead."
    }
  }'
  exit 0
fi

# Block "npx oxfmt" / "pnpx oxfmt" / "<pm> dlx/exec/run oxfmt" → tell Claude to use vp fmt
if echo "$COMMAND" | grep -qE '\b(npx|pnpx) oxfmt\b|\b(npm|pnpm|yarn) (dlx|exec|run) oxfmt\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not run oxfmt through a package manager. Use `vp fmt` instead."
    }
  }'
  exit 0
fi

# Block "<pm> run <script>" → tell Claude to use vp <script>
if echo "$COMMAND" | grep -qE '\b(npm|pnpm|yarn) run \S+'; then
  SCRIPT=$(echo "$COMMAND" | grep -oE '\b(npm|pnpm|yarn) run \S+' | head -1 | sed -E 's/(npm|pnpm|yarn) run //')
  jq -n --arg s "$SCRIPT" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("Do not use a package manager directly. Use `vp run " + $s + "` instead.")
    }
  }'
  exit 0
fi

# Block "<pm> test" → tell Claude to use vp test
if echo "$COMMAND" | grep -qE '\b(npm|pnpm|yarn) test\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use a package manager directly. Use `vp test` instead."
    }
  }'
  exit 0
fi

# Block "npx" / "pnpx" / "<pm> dlx" / "<pm> exec" → tell Claude to use vp dlx
if echo "$COMMAND" | grep -qE '\b(npx|pnpx)\b|\b(npm|pnpm|yarn) (dlx|exec)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use npx/pnpx/dlx/exec. Use `vp dlx` or `vp exec` instead."
    }
  }'
  exit 0
fi

# --- Direct tool invocations replaced by vp ---

# Block "vitest" → tell Claude to use vp test
if echo "$COMMAND" | grep -qE '\bvitest\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not run vitest directly. Use `vp test` instead."
    }
  }'
  exit 0
fi

# Block "oxlint" → tell Claude to use vp lint
if echo "$COMMAND" | grep -qE '\boxlint\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not run oxlint directly. Use `vp lint` instead."
    }
  }'
  exit 0
fi

# Block "oxfmt" → tell Claude to use vp fmt
if echo "$COMMAND" | grep -qE '\boxfmt\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not run oxfmt directly. Use `vp fmt` instead."
    }
  }'
  exit 0
fi

# --- Catch-all: block any remaining npm/pnpm/yarn usage ---

if echo "$COMMAND" | grep -qE '\bnpm\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use npm. Use the equivalent `vp` command instead (e.g. `vp install`, `vp add`, `vp remove`, `vp update`). You can also use `vp pm` to forward a command to the package manager."
    }
  }'
  exit 0
fi

if echo "$COMMAND" | grep -qE '\bpnpm\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use pnpm. Use the equivalent `vp` command instead (e.g. `vp install`, `vp add`, `vp remove`, `vp update`). You can also use `vp pm` to forward a command to the package manager."
    }
  }'
  exit 0
fi

if echo "$COMMAND" | grep -qE '\byarn\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use yarn. Use the equivalent `vp` command instead (e.g. `vp install`, `vp add`, `vp remove`, `vp update`). You can also use `vp pm` to forward a command to the package manager."
    }
  }'
  exit 0
fi

# --- Everything else is fine ---
exit 0
