extends BulletMLValueElementASTNode

class_name BulletMLWaitASTNode

func get_value() -> float:
    return float(super.get_value()) / BulletMLContext.FRAME_MULTIPLIER
