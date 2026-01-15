# TODO

## Schedulers

### scx_cake Integration
- **Repository**: [scx_cake](https://github.com/RitzDaCat/scx_cake)
- **Type**: sched_ext BPF scheduler (not a traditional kernel patch)
- **Description**: Gaming-optimized CPU scheduler with 7-tier priority system, reduces scheduling overhead by ~70%
- **Requirements**:
  - Linux kernel 6.12+ with sched_ext support
  - Rust toolchain for BPF compilation
  - Does NOT require kernel recompilation (loads as BPF program)
- **Status**: To be evaluated for inclusion
- **Notes**: This is a userspace BPF scheduler that loads dynamically, different from traditional patch-based schedulers like BORE/BMQ/PDS. May be better suited as an optional installation script rather than a kernel patch.
