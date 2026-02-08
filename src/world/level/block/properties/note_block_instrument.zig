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

    pub fn name(instrument: NoteBlockInstrument) []const u8 {
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
        };
    }

    pub const Type = enum {
        BaseBlock,
        MobHead,
        Custom,
    };
};
