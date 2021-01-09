local constants = {
    DEFAULT_LEVEL_SIZE = Vector2.new(128, 128),
    BLOCK_SIZE = Vector2.new(4, 4),
    WALL_COLOR = Color3.fromRGB(85, 85, 85),
    DOOR_COLOR = {
        BLUE = 1,
        GREEN = 2,
        RED = 3,
        YELLOW = 4,
    },
    DOOR_PART_COLOR = {}
}
constants.DOOR_PART_COLOR[constants.DOOR_COLOR.BLUE] = Color3.fromRGB(85, 85, 215)
constants.DOOR_PART_COLOR[constants.DOOR_COLOR.GREEN] = Color3.fromRGB(85, 215, 85)
constants.DOOR_PART_COLOR[constants.DOOR_COLOR.RED] = Color3.fromRGB(215, 85, 85)
constants.DOOR_PART_COLOR[constants.DOOR_COLOR.YELLOW] = Color3.fromRGB(215, 215, 85)

return constants
