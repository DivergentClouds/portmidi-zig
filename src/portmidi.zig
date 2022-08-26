// Requires PortMidi
// https://github.com/PortMidi/portmidi/
//
// Other versions may or may not work
//

// The following functions have been intentionally excluded:
//
// Pm_GetDefaultInputDeviceID()
// (Deprecated)
//
// Pm_GetDefaultOutputDeviceID()
// (Deprecated)
//
// PmBefore()
// (Just use a less than sign...)
//
// Pm_Poll()
// (Deprecated)
//

// The following variables have been intentionally excluded:
//
// pmNoDevice
// (Exclusively for use with Pm_GetDefaultInputDeviceID() and
// Pm_GetDefaultOutputDeviceID() which are also excluded)
//
// PM_FILT_FD
// (equivalent to PM_FILT_UNDEFINED)
//

const c = @cImport({
    @cInclude("portmidi.h");
});

pub const Stream = c.PortMidiStream;
pub const DeviceID = c.PmDeviceID;
pub const TimeProcPtr = c.PmTimeProcPtr;
pub const DeviceInfo = c.PmDeviceInfo;
pub const Timestamp = c.PmTimestamp;
pub const Event = c.PmEvent;
pub const Message = c.PmMessage;

pub const host_error_msg_len = c.PM_HOST_ERROR_MSG_LEN;
pub const default_sysex_buffer_size = c.PM_DEFAULT_SYSEX_BUFFER_SIZE;
pub const deviceinfo_version = c.PM_DEVICEINFO_VERS;

pub const filter = struct {
    pub const active_sensing: i32 = c.PM_FILT_ACTIVE;
    pub const sysex: i32 = c.PM_FILT_SYSEX;
    pub const play: i32 = c.PM_FILT_PLAY;
    pub const tick: i32 = c.PM_FILT_TICK;
    pub const undefined_msg: i32 = c.PM_FILT_FD;
    pub const system_reset: i32 = c.PM_FILT_RESET;
    pub const realtime: i32 = c.PM_FILT_REALTIME;
    pub const note: i32 = c.PM_FILT_NOTE;
    pub const channel_aftertouch: i32 = c.PM_FILT_CHANNEL_AFTERTOUCH;
    pub const poly_aftertouch: i32 = c.PM_FILT_POLY_AFTERTOUCH;
    pub const aftertouch: i32 = c.PM_FILT_AFTERTOUCH;
    pub const program_change: i32 = c.PM_FILT_PROGRAM;
    pub const control_change: i32 = c.PM_FILT_CONTROL;
    pub const pitchbend: i32 = c.PM_FILT_PITCHBEND;
    pub const mtc: i32 = c.PM_FILT_MTC;
    pub const song_postion: i32 = c.PM_FILT_SONG_POSITION;
    pub const song_select: i32 = c.PM_FILT_SONG_SELECT;
    pub const tune_request: i32 = c.PM_FILT_TUNE;
    pub const system_common: i32 = c.PM_FILT_SYSTEMCOMMON;
};

pub const midi = struct {
    pub const status = struct { 
        /// Note off <key number> <velocity>
        /// The bottom 4 bits are the channel number
        /// See channel()
        pub const note_off: u8 = 0x80;
        
        /// Note on <key number> <velocity>
        /// The bottom 4 bits are the channel number
        /// See channel()
        pub const note_on: u8 = 0x90;
        
        /// Polyphonic aftertouch <key number> <pressure>
        /// The bottom 4 bits are the channel number
        /// See channel()
        /// Called 'poly_at' in portmidi.c
        pub const poly_aftertouch : u8 = 0xa0;
        
        /// Control change <controller number> <controller value>
        /// The bottom 4 bits are the channel number
        /// See channel()
        /// Called 'control' in portmidi.c
        pub const control_change: u8 = 0xb0;
        
        /// Program change <program number>
        /// The bottom 4 bits are the channel number
        /// See channel()
        /// Called 'program' in portmidi.cc
        pub const program_change: u8 = 0xc0;
        
        /// Channel aftertouch <pressure>
        /// The bottom 4 bits are the channel number
        /// See channel()
        pub const channel_aftertouch: u8 = 0xd0;
        
        /// Pitchbend <LSB> <MSB>
        /// The bottom 4 bits are the channel number
        /// See channel()
        pub const pitchbend: u8 = 0xe0;
        
        /// SysEx [...] EoX
        /// Start of system exclusive message
        pub const sysex: u8 = 0xf0;

        /// Midi Timecode <quarter frame message>
        pub const mtc: u8 = 0xf1;
        
        /// Song position <LSB> <MSB>
        /// Called 'songpos' in portmidi.c
        pub const song_postion: u8 = 0xf2;

        /// Song select <song number>
        /// Called 'songsel' in portmidi.c
        pub const song_select: u8 = 0xf3;
        
        /// Tune Request
        /// Called 'tune' in portmidi.c
        pub const tune_request: u8 = 0xf6;
        
        /// Marks the end of a SysEx message
        /// See midi.status.sysex
        pub const eox: u8 = 0xf7;

        /// Timing clock
        /// Called 'clock' in portmidi.c
        pub const timing_clock: u8 = 0xf8;

        /// Start sequence
        /// Called 'start' in portmmidi.c
        pub const start_sequence: u8 = 0xfa;

        /// Continue sequence
        /// Called 'continue' in portmidi.c
        pub const continue_sequence: u8 = 0xfb;

        /// Stop sequence
        /// Called 'stop' in portmidi.c
        pub const stop_sequence: u8 = 0xfc;

        /// Active sensing
        /// Called 'active' in portmidi.c
        pub const active_sensing: u8 = 0xfe;

        /// System reset
        /// Called 'reset' in portmidi.c
        pub const system_reset: u8 = 0xff;
 
    };
};

// Do NOT make public, use errorCheck instead
const PmError = c.PmError;

pub fn initialize() void {
    _ = c.Pm_Initialize(); // only returns pmNoError
}

pub fn terminate() void {
    defer _ = c.Pm_Terminate(); // only returns pmNoError
}

pub fn hasHostError(stream: *Stream) bool {
    if (c.Pm_HasHostError(stream) == c.TRUE) return true;
    return false;
}

pub fn getHostErrorText(msg: []u8) void {
    c.Pm_GetHostErrorText(msg.ptr, msg.len);
}

pub fn countDevices() c_int {
    return c.Pm_CountDevices();
}

pub fn getDeviceInfo(id: DeviceID) ?*const DeviceInfo {
    return c.Pm_GetDeviceInfo(id);
}

pub fn openInput(stream: **Stream,
        inputDevice: DeviceID, inputDriverInfo: ?*anyopaque, 
        bufferSize: i32, time_proc: TimeProcPtr, time_info: *anyopaque
    ) !void {

    try errorCheck(
        c.Pm_OpenInput(stream, inputDevice, inputDriverInfo,
        bufferSize, time_proc, time_info)
    );
}

pub fn openOutput(stream: **Stream,
        outputDevice: DeviceID, outputDriverInfo: ?*anyopaque, 
        bufferSize: i32, time_proc: TimeProcPtr, time_info: *anyopaque,
        latency: i32,
    ) !void {

    try errorCheck(
        c.Pm_OpenOutput(stream, outputDevice, outputDriverInfo,
        bufferSize, time_proc, time_info, latency)
    );
}


pub fn createVirtualInput(name: [:0]u8, interface: [:0]u8,
        deviceInfo: ?*anyopaque
    ) !void {

    try errorCheck(
        c.Pm_CreateVirtualInput(name.ptr, interface.ptr, deviceInfo)
    );
}

pub fn createVirtualOutput(name: [:0]u8, interface: [:0]u8,
        deviceInfo: ?*anyopaque
    ) !void {

    try errorCheck(
        c.Pm_CreateVirtualOutput(name.ptr, interface.ptr, deviceInfo)
    );
}

pub fn deleteVirtualDevice(device: DeviceID) !void {
    try errorCheck(
        c.Pm_DeleteVirtualDevice(device)
    );
}

pub fn setFilter(stream: *Stream, filters: i32) !void {
    try errorCheck(
        c.Pm_SetFilter(stream, filters)
    );
}

pub inline fn channel(channel_id: u4) u16 {
    return @as(u16, 1) << channel_id;
}

pub fn setChannelMask(stream: *Stream, mask: u16) !void {
    try errorCheck(
        c.Pm_SetChannelMask(stream, @bitCast(i16, mask))
    );
}


pub fn abort(stream: *Stream) !void {
    try errorCheck(
        c.Pm_Abort(stream)
    );
}

pub fn close(stream: *Stream) !void {
    try errorCheck(
        c.Pm_Close(stream)
    );
}

pub fn synchronize(stream: *Stream) !void {
    try errorCheck(
        c.Pm_Synchronize(stream)
    );
}

pub inline fn message(status: u8, data1: u8, data2: u8) u32 {
    return ((data2 << 16) & 0xff0000) |
        ((data1 << 8) & 0xff00) |
        (status & 0xff);
}

pub inline fn messageStatus(msg: u32) u8 {
    return msg & 0xff;
}

pub inline fn messageData1(msg: u32) u8 {
    return (msg >> 8) & 0xff;
}

pub inline fn messageData2(msg: u32) u8 {
    return (msg >> 16) & 0xff;
}

pub fn read(stream: *Stream, buffer: *Event, length: i32) !i32 {
    const result = c.Pm_Read(stream, buffer, length);
    
    if (result < 0) try errorCheck(result);
    return result;
}

pub fn write(stream: *Stream, buffer: *Event, length: i32) !void {
    try hasData( // I'm like, 90% sure this is correct
        c.PmWrite(stream, buffer, length)
    );
}

pub fn writeShort(stream: *Stream, when: Timestamp, msg: Message) !void {
    try errorCheck(
        c.PmWriteShort(stream, when, msg)
    );
}

pub fn writeSysEx(stream: *Stream, when: Timestamp, msg: [:0xf7]u8) !void {
    try errorCheck(
        c.PmWriteSysExec(stream, when, msg)
    );
}

/// Use hasData() if err can be pmNoData or pmGotData
fn errorCheck(err: PmError) !void {
    switch (err) {
        c.pmNoError => return,
        c.pmHostError => return error.PmHostError,
        c.pmInvalidDeviceId => return error.PmInvalidDeviceId,
        c.pmInsufficientMemory => return error.PmInsufficientMemory,
        c.pmBufferTooSmall => return error.PmBufferTooSmall,
        c.pmBufferOverflow => return error.PmBufferOverflow,
        c.pmBadPtr => return error.PmBadPtr,
        c.pmBadData => return error.PmBadData,
        c.pmInternalError => return error.PmInternalError,
        c.pmBufferMaxSize => return error.PmBufferMaxSize,
        c.pmNotImplemented => return error.PmNotImplemented,
        c.pmInterfaceNotSupported => return error.InterfaceNotSupported,
        c.pmNoData => return error.PmNoData, // use pmHasData()
        c.pmGotData => return error.PmGotData, // use pmHasData()
        else => return error.PmUnknownError,
    }
}

/// Use errorCheck() if err cannot be pmNoData or pmGotData
fn hasData(err: PmError) !bool {
    switch (err) {
        c.pmNoData => return false,
        c.pmGotData => return true,
        else => errorCheck(err),
    }
}
