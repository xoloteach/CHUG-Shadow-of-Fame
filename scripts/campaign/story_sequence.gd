class_name StorySequence
extends RefCounted
## Small cursor over one campaign part's normalized story events.

var _events: Array = []
var _cursor := 0

func load_events(events: Array) -> void:
    _events = events.duplicate(true)
    _cursor = 0

func next_event() -> Dictionary:
    if _cursor >= _events.size():
        return {}
    var event = _events[_cursor]
    _cursor += 1
    return event.duplicate(true) if event is Dictionary else {}

func has_more() -> bool:
    return _cursor < _events.size()

func clear() -> void:
    _events.clear()
    _cursor = 0
