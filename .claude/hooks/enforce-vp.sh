#!/bin/bash
# .claude/hooks/enforce-vp.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# --- BLOCK with guidance (Claude retries on its own) ---

# Block bare "npm install" / "npm i" → tell Claude to use vp
if echo "$COMMAND" | grep -qE '\bnpm (install|i)\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use npm. Use `vp install` instead."
    }
  }'
  exit 0
fi

# Block "npm run <script>" → tell Claude to use vp <script>
if echo "$COMMAND" | grep -qE '\bnpm run \S+'; then
  SCRIPT=$(echo "$COMMAND" | grep -oE '\bnpm run \S+' | head -1 | sed 's/npm run //')
  jq -n --arg s "$SCRIPT" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("Do not use npm. Use `vp " + $s + "` instead.")
    }
  }'
  exit 0
fi

# Block "npx" → tell Claude to use vp dlx
if echo "$COMMAND" | grep -qE '\bnpx\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use npx. Use `vp dlx` instead."
    }
  }'
  exit 0
fi

# Block "npm test" → tell Claude to use vp test
if echo "$COMMAND" | grep -qE '\bnpm test\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use npm. Use `vp test` instead."
    }
  }'
  exit 0
fi

# --- Everything else is fine ---
exit 0
