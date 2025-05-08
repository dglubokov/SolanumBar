from PIL import Image
import os

# Path to your source image (replace with your PNG file path)
source_image_path = "tomato.png"
output_directory = "AppIcon.appiconset"

# Create output directory if it doesn't exist
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Define the sizes and scales from the image
icon_sizes = [
    {"size": 16, "scale": 1, "idiom": "macOS"},
    {"size": 16, "scale": 2, "idiom": "macOS"},
    {"size": 32, "scale": 1, "idiom": "macOS"},
    {"size": 32, "scale": 2, "idiom": "macOS"},
    {"size": 128, "scale": 1, "idiom": "macOS"},
    {"size": 128, "scale": 2, "idiom": "macOS"},
    {"size": 256, "scale": 1, "idiom": "macOS"},
    {"size": 256, "scale": 2, "idiom": "macOS"},
    {"size": 512, "scale": 1, "idiom": "macOS"},
    {"size": 512, "scale": 2, "idiom": "macOS"},
    {"size": 1024, "scale": 1, "idiom": "macOS"},
    {"size": 1024, "scale": 2, "idiom": "macOS"},
]

# Open the source image
source_image = Image.open(source_image_path)

# Generate resized images
for icon in icon_sizes:
    size = icon["size"] * icon["scale"]
    resized_image = source_image.resize((size, size), Image.LANCZOS)
    
    # Naming convention: icon_[size]x[size]@[scale]x.png
    filename = f"icon_{icon['size']}x{icon['size']}@{icon['scale']}x.png"
    output_path = os.path.join(output_directory, filename)
    
    # Save the resized image
    resized_image.save(output_path, "PNG")
    print(f"Saved: {output_path}")

# Create Contents.json file for the asset catalog
contents_json = {
    "images": [],
    "info": {
        "version": 1,
        "author": "xcode"
    }
}

for icon in icon_sizes:
    contents_json["images"].append({
        "size": f"{icon['size']}x{icon['size']}",
        "idiom": icon["idiom"],
        "scale": f"{icon['scale']}x",
        "filename": f"icon_{icon['size']}x{icon['size']}@{icon['scale']}x.png"
    })

# Write Contents.json
import json
with open(os.path.join(output_directory, "Contents.json"), "w") as f:
    json.dump(contents_json, f, indent=2)

print("Contents.json created successfully.")
