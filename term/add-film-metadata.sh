#!/bin/bash

echo "=== Film Scan Metadata Tool ==="
echo "This script adds camera, lens, film stock, etc. to your images using ExifTool."
echo ""

# Ask for the directory containing the images
read -p "Path to images folder (default: current folder): " image_dir
image_dir=${image_dir:-.}

cd "$image_dir" || { echo "Error: Cannot access directory $image_dir"; exit 1; }
mkdir -p ./originals

# Interactive prompts
read -p "Film Stock (Make field, e.g. Fujifilm 400): " film_stock
read -p "Camera Model (e.g. Canon AE-1): " camera_model
read -p "Lens Model (e.g. Canon FD 50mm f/1.8): " lens_model
read -p "ISO (e.g. 400): " iso_value
read -p "Shooting Date (YYYY:MM:DD, e.g. 2026:06:17) [optional]: " shoot_date
read -p "Image Description (optional, e.g. Roll 1 - Street): " description
read -p "Extra Keywords (optional, comma separated): " keywords

read -p "File extension to process (default: jpg): " ext
ext=${ext:-jpg}

echo ""
echo "Applying metadata in folder: $image_dir"
echo "Make: $film_stock"
echo "Model: $camera_model"
echo "Lens: $lens_model"
echo "ISO: $iso_value"
if [ -n "$shoot_date" ]; then
    echo "Date: $shoot_date"
fi
echo ""

# Build the exiftool command
cmd="exiftool -Make=\"$film_stock\" -Model=\"$camera_model\" -LensModel=\"$lens_model\" -Lens=\"$lens_model\" -ISO=$iso_value"

if [ -n "$shoot_date" ]; then
    cmd="$cmd -DateTimeOriginal=\"$shoot_date 00:00:00\""
fi

if [ -n "$description" ]; then
    cmd="$cmd -ImageDescription=\"$description\""
fi

if [ -n "$keywords" ]; then
    cmd="$cmd -Keywords=\"$keywords\""
fi

cmd="$cmd *.$ext"

eval $cmd

echo ""
echo "Metadata applied successfully!"
echo "Original files moved to ${image_dir}/originals/"

if ls *_original 1> /dev/null 2>&1; then
    mv *_original ./originals/
    echo "Backups moved successfully."
fi

echo ""
echo "Done!"
