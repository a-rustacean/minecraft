const SoundEvent = @import("../../../sounds.zig").SoundEvent;

pub const SoundType = struct {
    volume: f32,
    pitch: f32,

    break_sound: SoundEvent,
    step_sound: SoundEvent,
    place_sound: SoundEvent,
    hit_sound: SoundEvent,
    fall_sound: SoundEvent,

    pub fn init(
        volume: f32,
        pitch: f32,
        break_sound: SoundEvent,
        step_sound: SoundEvent,
        place_sound: SoundEvent,
        hit_sound: SoundEvent,
        fall_sound: SoundEvent,
    ) SoundType {
        return .{
            .volume = volume,
            .pitch = pitch,
            .break_sound = break_sound,
            .step_sound = step_sound,
            .place_sound = place_sound,
            .hit_sound = hit_sound,
            .fall_sound = fall_sound,
        };
    }

    pub const EMPTY: SoundType = .init(
        1.0,
        1.0,
        SoundEvent.EMTPY,
        SoundEvent.EMPTY,
        SoundEvent.EMPTY,
        SoundEvent.EMPTY,
        SoundEvent.EMPTY,
    );
    // TODO: add more
    const STONE: SoundType = .init(
        1.0,
        1.0,
        SoundEvent.STONE_BREAK,
        SoundEvent.STONE_STEP,
        SoundEvent.STONE_PLACE,
        SoundEvent.STONE_HIT,
        SoundEvent.STONE_FALL,
    );
    // TODO: add more
};
