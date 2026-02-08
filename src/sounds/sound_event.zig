const Identifier = @import("../resources.zig").Identifier;

pub const SoundEvent = struct {
    location: Identifier,
    fixed_range: ?f32,

    pub fn init(location: Identifier, range: ?f32) SoundEvent {
        return .{ .location = location, .fixed_range = range };
    }

    // TODO: rename the parameter `f`
    pub fn getRange(self: *SoundEvent, f: f32) f32 {
        if (self.fixed_range) |range| {
            return range;
        }

        return if (f > 1.0) 16.0 * f else 16.0;
    }

    pub const ALLAY_AMBIENT_WITH_ITEM: SoundEvent = .init(Identifier.initDefaultNamespace("entity.allay.ambient_with_item"), null);
    pub const ALLAY_AMBIENT_WITHOUT_ITEM: SoundEvent = .init(Identifier.initDefaultNamespace("entity.allay.ambient_without_item"), null);
    pub const ALLAY_DEATH: SoundEvent = .register(Identifier.initDefaultNamespace("entity.allay.death"), null);
    // TODO: add more
    pub const EMPTY: SoundEvent = .init(Identifier.initDefaultNamespace("intentionally_empty"), null);
    // TODO: add more
    pub const STONE_BREAK: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.break"), null);
    // TODO: add more
    pub const STONE_FALL: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.fall"));
    pub const STONE_HIT: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.hit"));
    pub const STONE_PLACE: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.place"));
    // TODO: add more
    pub const STONE_STEP: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.step"));
    // TODO: add more
};
