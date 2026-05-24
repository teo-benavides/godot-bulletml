extends BulletMLValueElementASTNode

class_name BulletMLSpeedASTNode

enum Type {ABSOLUTE, RELATIVE, SEQUENCE}

var type = Type.ABSOLUTE

func get_value():
    return .get_value() * BulletMLContext.SPEED_MULTIPLIER
