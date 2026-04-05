#!/bin/bash
# .claude/hooks/enforce-vp-config.sh
# Block creation of standalone oxlint/oxfmt config files — configure in vite.config.ts instead.
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.content // empty')

BASENAME=$(basename "$FILE_PATH" 2>/dev/null)

case "$BASENAME" in
  .oxlintrc.json|.oxlintrc.jsonc|oxlint.config.ts|.oxfmtrc.json|.oxfmtrc.jsonc|oxfmt.config.ts)
    jq -n '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "Do not create standalone oxlint/oxfmt config files. Configure linting and formatting in `vite.config.ts` instead."
      }
    }'
    exit 0
    ;;
esac

exit 0
