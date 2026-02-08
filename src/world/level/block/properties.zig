const MapColor = @import("./material.zig").MapColor;
const PushReaction = @import("./material.zig").PushReaction;
const SoundType = @import("./sound_type.zig").SoundType;

pub const NoteBlockInstrument = @import("./properties/note_block_instrument.zig").NoteBlockInstrument;

// TODO: temp!
const BlockState = u32;

// TODO: revisit
pub const BlockProperties = struct {
    map_color: fn (BlockState) MapColor = fn (_: BlockState) MapColor{MapColor.None},
    sound_type: SoundType = SoundType.EMPTY,
    light_emission: fn (BlockState) u4 = fn (_: BlockState) u4{0},
    explosion_resistance: f32,
    destroy_time: f32,
    friction: f32 = 0.6,
    speed_factor: f32 = 1.0,
    jump_factor: f32 = 1.0,
    requires_correct_tool_for_drops: bool,
    is_randomly_ticking: bool,
    has_collision: bool = true,
    liquid: bool,
    force_solid_off: bool,
    force_solid_on: bool,
    can_occlude: bool = true,
    is_air: bool,
    ignited_by_lava: bool,
    spawn_terrain_particles: bool = true,
    replaceable: bool,
    dynamic_shape: bool,
    // TODO:
    // - drops
    // - descriptionID
    // - isValidSpawn
    // - isRedstoneConductor
    // - isSuffocating
    // - isViewBlocking
    // - hasPostProcess
    // - emissiveRendering
    push_reaction: PushReaction,
    offset_type: OffsetType,
};

pub const OffsetType = enum(u2) {
    None,
    Xz,
    Xyz,
};
