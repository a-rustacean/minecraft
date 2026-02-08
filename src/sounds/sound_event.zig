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
    pub const NOTE_BLOCK_BASEDRUM = .init(Identifier.initDefaultNamespace("block.note_block.basedrum"), null);
    pub const NOTE_BLOCK_BASS = .init(Identifier.initDefaultNamespace("block.note_block.bass"), null);
    pub const NOTE_BLOCK_BELL = .init(Identifier.initDefaultNamespace("block.note_block.bell"), null);
    pub const NOTE_BLOCK_CHIME = .init(Identifier.initDefaultNamespace("block.note_block.chime"), null);
    pub const NOTE_BLOCK_FLUTE = .init(Identifier.initDefaultNamespace("block.note_block.flute"), null);
    pub const NOTE_BLOCK_GUITAR = .init(Identifier.initDefaultNamespace("block.note_block.guitar"), null);
    pub const NOTE_BLOCK_HARP = .init(Identifier.initDefaultNamespace("block.note_block.harp"), null);
    pub const NOTE_BLOCK_HAT = .init(Identifier.initDefaultNamespace("block.note_block.hat"), null);
    pub const NOTE_BLOCK_PLING = .init(Identifier.initDefaultNamespace("block.note_block.pling"), null);
    pub const NOTE_BLOCK_SNARE = .init(Identifier.initDefaultNamespace("block.note_block.snare"), null);
    pub const NOTE_BLOCK_XYLOPHONE = .init(Identifier.initDefaultNamespace("block.note_block.xylophone"), null);
    pub const NOTE_BLOCK_IRON_XYLOPHONE = .init(Identifier.initDefaultNamespace("block.note_block.iron_xylophone"), null);
    pub const NOTE_BLOCK_COW_BELL = .init(Identifier.initDefaultNamespace("block.note_block.cow_bell"), null);
    pub const NOTE_BLOCK_DIDGERIDDO = .init(Identifier.initDefaultNamespace("block.note_block.didgeriddo"), null);
    pub const NOTE_BLOCK_BIT = .init(Identifier.initDefaultNamespace("block.note_block.bit"), null);
    pub const NOTE_BLOCK_BANJO = .init(Identifier.initDefaultNamespace("block.note_block.banjo"), null);
    pub const NOTE_BLOCK_IMITATE_ZOMBIE = .init(Identifier.initDefaultNamespace("block.note_block.imitate.zombie"), null);
    pub const NOTE_BLOCK_IMITATE_SKELETON = .init(Identifier.initDefaultNamespace("block.note_block.imitate.skeleton"), null);
    pub const NOTE_BLOCK_IMITATE_CREEPER = .init(Identifier.initDefaultNamespace("block.note_block.imitate.creeper"), null);
    pub const NOTE_BLOCK_IMITATE_ENDER_DRAGON = .init(Identifier.initDefaultNamespace("block.note_block.imitate.ender_dragon"), null);
    pub const NOTE_BLOCK_IMITATE_WITHER_SKELETON = .init(Identifier.initDefaultNamespace("block.note_block.imitate.wither_skeleton"), null);
    pub const NOTE_BLOCK_IMITATE_PIGLIN = .init(Identifier.initDefaultNamespace("block.note_block.imitate.piglin"), null);
    // TODO: add more
    pub const STONE_BREAK: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.break"), null);
    // TODO: add more
    pub const STONE_FALL: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.fall"));
    pub const STONE_HIT: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.hit"));
    pub const STONE_PLACE: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.place"));
    // TODO: add more
    pub const STONE_STEP: SoundEvent = .init(Identifier.initDefaultNamespace("block.stone.step"));
    // TODO: add more
    pub const UI_BUTTON_CLICK: SoundEvent = .init(Identifier.initDefaultNamespace("ui.button.click"));
    // TODO: add more
};
