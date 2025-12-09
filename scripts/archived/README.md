# Archived Scripts

This directory contains legacy scripts that have been replaced by the unified kernel configuration system.

## Archived Files

- **config.sh** - Basic kernel configuration (replaced by `kernel-config.sh --mode=minimal`)
- **trim.sh** - Aggressive kernel trimming (replaced by `kernel-config.sh --mode=trim`)
- **cachy.sh** - CachyOS configuration (replaced by `kernel-config.sh --mode=cachy`)

## Migration

These scripts have been **merged** into a unified system:

### New Unified System

**Library**: `lib-kernel-config.sh`
- Modular functions for kernel configuration
- Reusable components
- Single source of truth

**CLI Wrapper**: `kernel-config.sh`
- Unified interface for all configuration modes
- Command-line options for different profiles
- Better error handling and user feedback

### Migration Guide

#### Old: config.sh
```bash
cd /path/to/kernel-source
/path/to/scripts/config.sh .
```

#### New: kernel-config.sh --mode=minimal
```bash
/path/to/scripts/kernel-config.sh --mode=minimal /path/to/kernel-source
```

---

#### Old: trim.sh
```bash
cd /path/to/kernel-source
/path/to/scripts/trim.sh .
```

#### New: kernel-config.sh --mode=trim
```bash
/path/to/scripts/kernel-config.sh --mode=trim /path/to/kernel-source
```

---

#### Old: cachy/cachy.sh
```bash
cd /path/to/kernel-source
/path/to/scripts/cachy/cachy.sh .
```

#### New: kernel-config.sh --mode=cachy
```bash
/path/to/scripts/kernel-config.sh --mode=cachy /path/to/kernel-source
```

## Benefits of the New System

1. **Reduced duplication**: Eliminated ~70% code duplication
2. **Maintainability**: Single source of truth for kernel configs
3. **Modularity**: Reusable functions can be combined
4. **Flexibility**: Mix and match optimization profiles
5. **Better UX**: Clear command-line interface with help text

## Backward Compatibility

These archived scripts are preserved for reference but are no longer maintained. Use the new unified system instead.

If you need the exact old behavior, you can still run these archived scripts, but they will not receive updates or bug fixes.

## More Information

See:
- `scripts/kernel-config.sh --help` for usage
- `scripts/lib-kernel-config.sh` for available functions
- `CLAUDE.md` for complete documentation
