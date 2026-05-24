extends BulletMLValueElementASTNode

class_name BulletMLTermASTNode

func get_value() -> float:
    return float(.get_value()) / BulletMLContext.FRAME_MULTIPLIER
