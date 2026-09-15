# Campaign Specification

## Structure

The campaign contains Parts 1 through 50 in strict numeric order.

`data/campaign.json` stores structural metadata:

- part ID;
- part title;
- chapter;
- act;
- world.

Only Worlds I-III are present because they contain the authored 50 parts.

## Story event stream

`data/story.json` is grouped by part ID.
Each part is an ordered array of events.

Allowed event types are exactly:

### Text

```json
{
  "type": "text",
  "text": "Story text",
  "color": "#hexcolor"
}
```

`color` is optional presentation data and is consumed by `StoryPanel`.

### Fight

```json
{
  "type": "fight",
  "text": "SYSTEM: FIGHT",
  "enemy_id": 4,
  "required_result": "win",
  "rounds_to_win": 2
}
```

`required_result` must be `win` or `lose`.

### End

```json
{
  "type": "end",
  "text": "— END OF PART 1 —"
}
```

Every part must finish with an `end` event.

## Runtime flow

`Main` asks `GameData` for the current part's event array and loads it into `StorySequence`.
`StorySequence` is only a cursor; it does not interpret combat.
`StoryPanel` displays one event and emits a semantic action.
`Main` reacts to that action.

For a fight:

1. store the fight event as pending;
2. hide the story panel;
3. instantiate `FightArena`;
4. wait for `fight_finished(player_won)`;
5. compare the result with `required_result`;
6. if it matches, continue the event stream;
7. if it does not match, return to menu without advancing the part.

## Part completion

An `end` event leads to part completion.
`GameSession.complete_part(part_id)` is the only campaign progression entry point.

For Parts 1-49:

- completed part ID is recorded;
- `current_part` becomes the next part.

For Part 50:

- Part 50 is recorded complete;
- `campaign_complete` becomes true;
- the menu shows completion and disables campaign continuation.

## Quick Fight contract

Quick Fight is a sandbox convenience path:

- uses the first enemy found in the current part;
- uses a normal win condition;
- does not advance story;
- does not complete a part;
- does not write campaign progression.

Any future quick-fight options must preserve that separation.

## Editing campaign content safely

When changing campaign/story data:

1. keep part IDs 1..50 contiguous;
2. keep every story part present;
3. keep an `end` event as the final event;
4. use only documented event keys;
5. ensure every `enemy_id` exists in `data/combat.json`;
6. run `python3 tools/validate_project.py`.

Do not add generic event flags without a runtime consumer.
