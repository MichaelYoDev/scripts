#!/bin/bash

# ===============================================
#     FILM SCAN METADATA TOOL
# ===============================================
# Adds film photography metadata (camera, lens, stock, etc.)
# to your scanned images using ExifTool.
# ===============================================

echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                FILM SCAN METADATA TOOL                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "\033[0m"
echo "This script embeds camera, lens, film stock, and other metadata"
echo "into your images for better organization and cataloging."
echo ""

# Input prompts
read -rp "Path to images folder (default: current): " image_dir
image_dir=${image_dir:-.}

cd "$image_dir" || { echo -e "\033[1;31mError: Cannot access directory '$image_dir'\033[0m"; exit 1; }

mkdir -p ./originals

echo ""
read -rp "Film Stock (e.g. Portra 400): " film_stock
read -rp "Camera Model (e.g. Canon AE-1): " camera_model
read -rp "Lens Model (e.g. Canon FD 50mm f/1.8): " lens_model
read -rp "Shooting Date (YYYY:MM:DD, optional): " shoot_date
read -rp "Image Description (optional): " description
read -rp "Extra Keywords (optional, comma separated): " keywords
read -rp "File extension to process (default: jpg): " ext
ext=${ext:-jpg}

echo -e "\n\033[1;32m--------------------------------------------------------------\033[0m"
echo -e "\033[1;33mApplying metadata to .$ext files:\033[0m"
echo -e "   $image_dir"
echo ""
echo -e "\033[1;34mFilm Stock:\033[0m $film_stock"
echo -e "\033[1;34mCamera:\033[0m     $camera_model"
echo -e "\033[1;34mLens:\033[0m       $lens_model"
[ -n "$shoot_date" ] && echo -e "\033[1;34mDate:\033[0m       $shoot_date"
[ -n "$description" ] && echo -e "\033[1;34mDescription:\033[0m $description"
[ -n "$keywords" ] && echo -e "\033[1;34mKeywords:\033[0m   $keywords"
echo -e "\033[1;32m--------------------------------------------------------------\033[0m"
echo ""

# Process files
shopt -s nullglob
files=( ./*."$ext" )

if [ ${#files[@]} -eq 0 ]; then
  echo -e "\033[1;31mNo .$ext files found in the directory.\033[0m"
  exit 1
fi

echo -e "\033[1;33mApplying metadata to ${#files[@]} file(s)...\033[0m\n"

exiftool \
  -overwrite_original \
  -Make="$film_stock" \
  -Model="$camera_model" \
  -LensModel="$lens_model" \
  -Lens="$lens_model" \
  -UserComment="film" \
  ${shoot_date:+-DateTimeOriginal="$shoot_date 00:00:00"} \
  ${description:+-ImageDescription="$description"} \
  ${keywords:+-Keywords="$keywords"} \
  "${files[@]}"

echo ""
echo -e "\033[0mMetadata applied successfully!"
echo -e "\033[0mAll done! Original files backed up to ./originals/"
