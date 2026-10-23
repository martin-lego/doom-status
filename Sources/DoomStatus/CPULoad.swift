// Doom Status
// Copyright (C) 2026 Martin LeGo
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// Face images from DOOM, id Software.
// PNG files 1.png–6.png from https://github.com/rjzak/doom-status

import Darwin
import Foundation

/// Global CPU load from two `host_statistics(HOST_CPU_LOAD_INFO)` samples.
/// Busy time is user + system + nice; the rest of the delta is idle.
enum CPULoad {
    struct Sample {
        var user: UInt32
        var system: UInt32
        var idle: UInt32
        var nice: UInt32
    }

    static func sample() -> Sample? {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride
        )
        let result = withUnsafeMutablePointer(to: &info) { pointer -> kern_return_t in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { raw in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, raw, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        // cpu_ticks order: user, system, idle, nice.
        return Sample(
            user: info.cpu_ticks.0,
            system: info.cpu_ticks.1,
            idle: info.cpu_ticks.2,
            nice: info.cpu_ticks.3
        )
    }

    /// Whole-percent CPU, rounded, clamped to 0...100.
    static func percent(from previous: Sample, to current: Sample) -> Int {
        let user = UInt64(current.user &- previous.user)
        let system = UInt64(current.system &- previous.system)
        let nice = UInt64(current.nice &- previous.nice)
        let idle = UInt64(current.idle &- previous.idle)
        let busy = user + system + nice
        let total = busy + idle
        guard total > 0 else { return 0 }
        let rounded = (busy * 100 + total / 2) / total
        return Int(min(100, rounded))
    }
}
