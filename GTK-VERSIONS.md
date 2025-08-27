# Factor GTK Version Support

Factor now supports GTK2, GTK3, and GTK4, but they cannot coexist in the same image due to symbol conflicts.

## Default (GTK2)
The default Factor image uses GTK2:
```bash
./factor  # Uses GTK2 with scaling support
```

## GTK3 Support
To use GTK3, you need a separate image:
```bash
# Build GTK3 image (one-time setup)
./build-gtk3-fresh.sh

# Run with GTK3
./factor -i=factor-gtk3.image
```

## GTK4 Support  
To use GTK4, you need a separate image:
```bash
# Build GTK4 image (one-time setup)
./build-gtk4-fresh.sh

# Run with GTK4
./factor -i=factor-gtk4.image
```

## Environment Variables
- `GDK_SCALE=2` - Set the scale factor for HiDPI displays (works with all versions)

## Notes
- Each GTK version requires its own Factor image
- You cannot load multiple GTK versions in the same process
- The GIR parser has been updated to support modern GIR files
- All versions support proper HiDPI scaling