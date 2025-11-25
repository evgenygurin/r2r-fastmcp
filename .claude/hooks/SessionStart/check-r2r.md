# R2R Availability Check Hook

This hook runs at the start of every Claude Code session to verify R2R server availability.

## Configuration

**Event:** SessionStart
**Type:** command
**Description:** Check R2R server availability

## Command

```bash
curl -s -o /dev/null -w '%{http_code}' ${R2R_BASE_URL:-http://localhost:7272}/v3/system/settings | grep -q 200 && echo '✓ R2R: Connected' || echo '✗ R2R: Not available'
```

## What It Does

1. Makes a silent curl request to R2R `/v3/system/settings` endpoint
2. Uses `R2R_BASE_URL` environment variable (default: `http://localhost:7272`)
3. Returns HTTP status code
4. Checks if status is 200 (OK)
5. Prints friendly message:
   - ✓ R2R: Connected (if available)
   - ✗ R2R: Not available (if unavailable)

## Purpose

- **Early Warning:** Know immediately if R2R is unavailable
- **Configuration Validation:** Verify R2R_BASE_URL is correct
- **User Experience:** Set expectations for R2R functionality

## When R2R is Not Available

If the hook reports R2R is not available:

1. **Check Docker:** `docker ps | grep r2r`
2. **Start R2R:** `cd ~/R2R && docker compose up -d`
3. **Verify URL:** `echo $R2R_BASE_URL`
4. **Test manually:** `curl ${R2R_BASE_URL}/v3/system/settings`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `R2R_BASE_URL` | `http://localhost:7272` | R2R server URL |

## Integration in settings.json

This hook is configured in `.claude/settings.json`:

```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "hooks": [
        {
          "type": "command",
          "command": "curl -s -o /dev/null -w '%{http_code}' ${R2R_BASE_URL:-http://localhost:7272}/v3/system/settings | grep -q 200 && echo '✓ R2R: Connected' || echo '✗ R2R: Not available'",
          "description": "Check R2R availability"
        }
      ]
    }
  ]
}
```

## Alternative Implementations

### Verbose Mode

For more detailed output:

```bash
R2R_URL=${R2R_BASE_URL:-http://localhost:7272}
STATUS=$(curl -s -o /dev/null -w '%{http_code}' $R2R_URL/v3/system/settings)

if [ "$STATUS" = "200" ]; then
    echo "✓ R2R: Connected ($R2R_URL)"
else
    echo "✗ R2R: Not available ($R2R_URL) - Status: $STATUS"
    echo "  Run: cd ~/R2R && docker compose up -d"
fi
```

### With Timeout

To avoid hanging on network issues:

```bash
curl -s --max-time 2 -o /dev/null -w '%{http_code}' ${R2R_BASE_URL:-http://localhost:7272}/v3/system/settings | grep -q 200 && echo '✓ R2R: Connected' || echo '✗ R2R: Timeout or not available'
```

## Disabling This Hook

To disable the R2R availability check:

1. Remove the hook from `.claude/settings.json`, or
2. Delete this file: `.claude/hooks/SessionStart/check-r2r.md`

## Related Hooks

- **PostToolUse/log-r2r.md** - Logs R2R tool usage after each call
