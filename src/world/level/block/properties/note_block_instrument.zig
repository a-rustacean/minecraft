// complete

const SoundEvent = @import("../../../../sounds.zig").SoundEvent;

pub const NoteBlockInstrument = enum {
    Harp,
    Basedrum,
    Snare,
    Hat,
    Bass,
    Flute,
    Bell,
    Guitar,
    Chime,
    Xylophone,
    IronXylophone,
    CowBell,
    Didgeriddo,
    Bit,
    Banjo,
    Pling,
    Zombie,
    Skeleton,
    Creeper,
    Dragon,
    WitherSkeleton,
    Piglin,
    CustomHead,

    pub fn getName(instrument: NoteBlockInstrument) []const u8 {
        return switch (instrument) {
            .Harp => "harp",
            .Basedrum => "basedrum",
            .Snare => "snare",
            .Hat => "hat",
            .Bass => "bass",
            .Flute => "flute",
            .Bell => "bell",
            .Guitar => "guitar",
            .Chime => "chime",
            .Xylophone => "xylophone",
            .IronXylophone => "iron_xylophone",
            .CowBell => "cow_bell",
            .Didgeriddo => "didgeriddo",
            .Bit => "bit",
            .Banjo => "banjo",
            .Pling => "pling",
            .Zombie => "zombie",
            .Skeleton => "skeleton",
            .Creeper => "creeper",
            .Dragon => "dragon",
            .WitherSkeleton => "wither_skeleton",
            .Piglin => "piglin",
            .CustomHead => "custom_head",
        };
    }

    pub fn getSoundEvent(instrument: NoteBlockInstrument) SoundEvent {
        return switch (instrument) {
            .Harp => SoundEvent.NOTE_BLOCK_HARP,
            .Basedrum => SoundEvent.NOTE_BLOCK_BASEDRUM,
            .Snare => SoundEvent.NOTE_BLOCK_SNARE,
            .Hat => SoundEvent.NOTE_BLOCK_HAT,
            .Bass => SoundEvent.NOTE_BLOCK_BASS,
            .Flute => SoundEvent.NOTE_BLOCK_FLUTE,
            .Bell => SoundEvent.NOTE_BLOCK_BELL,
            .Guitar => SoundEvent.NOTE_BLOCK_GUITAR,
            .Chime => SoundEvent.NOTE_BLOCK_CHIME,
            .Xylophone => SoundEvent.NOTE_BLOCK_XYLOPHONE,
            .IronXylophone => SoundEvent.NOTE_BLOCK_IRON_XYLOPHONE,
            .CowBell => SoundEvent.NOTE_BLOCK_COW_BELL,
            .Didgeriddo => SoundEvent.NOTE_BLOCK_DIDGERIDDO,
            .Bit => SoundEvent.NOTE_BLOCK_BIT,
            .Banjo => SoundEvent.NOTE_BLOCK_BANJO,
            .Pling => SoundEvent.NOTE_BLOCK_PLING,
            .Zombie => SoundEvent.NOTE_BLOCK_IMITATE_ZOMBIE,
            .Skeleton => SoundEvent.NOTE_BLOCK_IMITATE_SKELETON,
            .Creeper => SoundEvent.NOTE_BLOCK_IMITATE_CREEPER,
            .Dragon => SoundEvent.NOTE_BLOCK_IMITATE_ENDER_DRAGON,
            .WitherSkeleton => SoundEvent.NOTE_BLOCK_IMITATE_WITHER_SKELETON,
            .Piglin => SoundEvent.NOTE_BLOCK_IMITATE_PIGLIN,
            .CustomHead => SoundEvent.UI_BUTTON_CLICK,
        };
    }

    pub fn isTunable(instrument: NoteBlockInstrument) bool {
        return instrument.getType() == Type.BaseBlock;
    }

    pub fn hasCustomSound(instrument: NoteBlockInstrument) bool {
        return instrument.getType() == Type.Custom;
    }

    pub fn worksAboveNoteBlock(instrument: NoteBlockInstrument) bool {
        return instrument.getType() != Type.BaseBlock;
    }

    pub fn getType(instrument: NoteBlockInstrument) Type {
        return switch (instrument) {
            .Harp => Type.BaseBlock,
            .Basedrum => Type.BaseBlock,
            .Snare => Type.BaseBlock,
            .Hat => Type.BaseBlock,
            .Bass => Type.BaseBlock,
            .Flute => Type.BaseBlock,
            .Bell => Type.BaseBlock,
            .Guitar => Type.BaseBlock,
            .Chime => Type.BaseBlock,
            .Xylophone => Type.BaseBlock,
            .IronXylophone => Type.BaseBlock,
            .CowBell => Type.BaseBlock,
            .Didgeriddo => Type.BaseBlock,
            .Bit => Type.BaseBlock,
            .Banjo => Type.BaseBlock,
            .Pling => Type.BaseBlock,
            .Zombie => Type.MobHead,
            .Skeleton => Type.MobHead,
            .Creeper => Type.MobHead,
            .Dragon => Type.MobHead,
            .WitherSkeleton => Type.MobHead,
            .Piglin => Type.MobHead,
            .CustomHead => Type.Custom,
        };
    }

    pub const Type = enum {
        BaseBlock,
        MobHead,
        Custom,
    };
};
