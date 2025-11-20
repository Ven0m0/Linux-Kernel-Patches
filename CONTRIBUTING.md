# Contributing to Linux Kernel Patches

Thank you for your interest in contributing to this kernel patch collection! This document provides guidelines for contributing patches, scripts, and improvements.

## How to Contribute

### Adding New Patches

1. **Organize by kernel version**: Place patches in the appropriate version directory (e.g., `6.15/`, `6.16/`)
2. **Use descriptive names**: Name patch files clearly to indicate their purpose
   - Good: `mm-madvise-use-walk_page_range_vma.patch`
   - Bad: `patch1.patch`
3. **Create subdirectories for related patches**: Group related patches together
   - Example: `6.15/zen-patches/`, `6.18/mesa/`

### Patch Naming Convention

Follow this naming pattern:
```
[subsystem]-[component]-[brief-description].patch
```

Examples:
- `mm-hugetlb-remove-unnecessary-holding-of-hugetlb_lock.patch`
- `sched-optimize-sched_move_task.patch`
- `f2fs-gc_boost.patch`

### Adding Scripts

1. Place scripts in the `scripts/` directory
2. Use appropriate subdirectories:
   - `scripts/cachy/` - CachyOS-specific scripts
   - `scripts/utils/` - General utility scripts
3. Make scripts executable: `chmod +x script-name.sh`
4. Include a header comment explaining the script's purpose
5. Use `.sh` extension for shell scripts

### Documentation

When adding patches or scripts:
1. Update relevant patch list files in `docs/`
2. Add entries to `patches.txt`, `patches-cachy.txt`, or create new list files as needed
3. Include source information (upstream URL, commit hash, etc.)

### Patch List Format

When updating patch lists in `docs/`, use this format:
```
# Description of patch or category
https://source.url/path/to/patch.patch
```

## Quality Guidelines

### For Patches

1. **Test patches before submitting**: Ensure patches apply cleanly to the target kernel version
2. **Include upstream source**: Document where the patch originated
3. **Verify compatibility**: Note any dependencies or conflicts with other patches
4. **Check for duplicates**: Search existing patches before adding new ones

### For Scripts

1. **Use `set -e`**: Exit on errors to prevent silent failures
2. **Add error handling**: Check for required dependencies and provide helpful error messages
3. **Use variables**: Don't hardcode paths when possible
4. **Add comments**: Explain complex logic
5. **Test thoroughly**: Test scripts on a clean system when possible

### Code Style

Shell scripts should follow these conventions:
- Use 2-space indentation
- Use meaningful variable names
- Quote variables to prevent word splitting: `"$variable"`
- Use `#!/usr/bin/env bash` shebang
- Prefer `[[` over `[` for conditionals

Example:
```bash
#!/usr/bin/env bash
set -e

KERNEL_VERSION="6.15"
PATCH_DIR="${KERNEL_VERSION}/patches"

if [[ ! -d "$PATCH_DIR" ]]; then
  echo "Error: Patch directory not found: $PATCH_DIR"
  exit 1
fi
```

## Pull Request Process

1. **Create a descriptive branch name**: `feature/add-6.19-patches` or `fix/script-permissions`
2. **Write clear commit messages**:
   - Use present tense: "Add mesa patches for 6.18"
   - Be specific: "Fix compile.sh missing kernel version check"
3. **Keep changes focused**: One feature or fix per pull request
4. **Test your changes**: Verify patches apply and scripts work
5. **Update documentation**: Update README.md if adding major features

### Commit Message Format

```
[type]: Brief description (50 chars or less)

Detailed explanation if needed. Wrap at 72 characters.
Include motivation for the change and contrast with previous behavior.

- Bullet points are okay
- Use hyphens for bullets

Fixes #123
```

Types:
- `patch`: Adding or updating patches
- `script`: Adding or updating scripts
- `docs`: Documentation changes
- `refactor`: Code reorganization
- `fix`: Bug fixes

## Testing

Before submitting patches:
1. Apply patches to a clean kernel source tree
2. Verify no conflicts or failures
3. Test build process if modifying build scripts
4. Check that documentation is accurate

## Getting Help

If you need help:
- Open an issue with the `question` label
- Check upstream patch sources for documentation
- Review existing patches and scripts as examples

## Upstream Contributions

If you're contributing patches from upstream sources:
1. Maintain original authorship information
2. Include source URL in commit message
3. Note any modifications made to the original patch
4. Check upstream license compatibility

## License

By contributing to this repository, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Code of Conduct

- Be respectful and constructive
- Focus on technical merit
- Help others learn and improve
- Give credit where it's due

## Review Process

Contributions will be reviewed for:
- Correctness and functionality
- Code quality and style
- Documentation completeness
- Compatibility with existing patches

Thank you for contributing!
