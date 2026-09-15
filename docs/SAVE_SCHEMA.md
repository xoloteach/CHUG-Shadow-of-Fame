# Save Schema

The current save is intentionally tiny:

```json
{
  "current_part": 1,
  "completed_parts": [],
  "campaign_complete": false
}
```

## Rules

- `current_part` is always 1..50.
- `completed_parts` contains unique numeric part IDs only.
- `campaign_complete` becomes true when Part 50 is completed.
- Loading sanitizes the file into exactly these fields, so stale keys from older prototypes are dropped.
- There is no speculative version/migration framework in this lean build.
