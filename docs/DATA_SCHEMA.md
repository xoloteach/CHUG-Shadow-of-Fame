# Runtime Data Schema

Only three JSON files are loaded.

## `campaign.json`

```json
{
  "worlds": [
    {"id": 1, "title": "SHADOW OF FAME", "parts": [1, 20]}
  ],
  "parts": [
    {"id": 1, "title": "THE FALL", "chapter": 1, "act": 1, "world": 1}
  ]
}
```

The runtime uses part IDs/titles and keeps chapter/act/world as real structural metadata. There are no empty future worlds.

## `story.json`

Story is grouped by part and uses explicit event types.

Text event:

```json
{"type": "text", "text": "...", "color": "#cc0033"}
```

Fight event:

```json
{
  "type": "fight",
  "text": "SYSTEM: FIGHT",
  "enemy_id": 4,
  "required_result": "win",
  "rounds_to_win": 2
}
```

End event:

```json
{"type": "end", "text": "— END OF PART 1 —"}
```

No generic flags are carried unless runtime code consumes them.

## `combat.json`

Contains:

- player base stats
- movement constants
- stamina/rage resource rules
- light/heavy attack definitions
- rage-tier multipliers and story-part unlocks
- enemy combat stats and AI aggression

Browser-only CSS/gradient rage metadata was removed.
