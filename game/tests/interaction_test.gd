extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        _fail("Scene failed to load")
        return
    var main: Node2D = scene.instantiate()
    root.add_child(main)
    await process_frame
    var start: Vector2 = main.player_position
    Input.action_press("ui_right")
    for i in range(5):
        await process_frame
    Input.action_release("ui_right")
    if main.player_position.x <= start.x:
        _fail("Right movement input did not move the player")
        return
    main.player_position = Vector2(15 * 32, 8 * 32)
    main._process(0.0)
    Input.action_press("ui_accept")
    await process_frame
    Input.action_release("ui_accept")
    main.queue_free()
    print("INTERACTION_TEST_PASS: scene instantiation and player movement")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
