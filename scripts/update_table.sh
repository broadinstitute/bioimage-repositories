#!/bin/bash

# Update README table from repositories.yaml
# Usage: ./scripts/update_table.sh

set -e  # Exit on error

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "❌ yq is not installed. Install with: brew install yq"
    exit 1
fi

# Check if files exist
if [ ! -f "data/repositories.yaml" ]; then
    echo "❌ data/repositories.yaml not found"
    exit 1
fi

if [ ! -f "README.md" ]; then
    echo "❌ README.md not found"
    exit 1
fi

echo "🔄 Generating table from YAML..."

# Create temporary table file
# Table headers correspond to YAML fields as follows:
# Repository -> .name (with optional logo below) | URL -> .short_url/.url | Best For -> .description | Qualifications -> .qualifications
# Size Limit -> .size_limit | Cost -> .cost | Metadata -> .metadata_requirements
cat > /tmp/table.md << 'EOF'

*Auto-generated from [data/repositories.yaml](data/repositories.yaml)*

| Repository | URL | Best For | Qualifications | Size Limit | Cost | Metadata |
|------------|-----|----------|----------------|------------|------|----------|
EOF

# Generate table rows from YAML with optional logos
# This script does the following:
# 1. Iterates through each repository key from the YAML file
# 2. Extracts all field values for each repository
# 3. Checks for logo files in images/ folder (supports png, jpg, jpeg, svg, ico)
# 4. Creates a markdown table row with:
#    - Repository name in **bold** with optional logo below on new line
#    - URL as markdown link using short_url and full url
#    - All other fields as plain text columns
#
# Logo handling:
# - Searches for images/{key}.{ext} where ext is png, jpg, jpeg, svg, ico
# - If found, adds <img> tag with height="16" below repository name
# - Logos appear on separate line using <br> tag
# - No logo shown if no image file exists
#
# To modify the table structure:
# - Edit the echo statement format
# - Add/remove field extractions
# - Modify logo search extensions or sizing
yq eval '.repositories | keys | .[]' data/repositories.yaml | while read -r key; do
    name=$(yq eval ".repositories.$key.name" data/repositories.yaml)
    short_url=$(yq eval ".repositories.$key.short_url" data/repositories.yaml)
    url=$(yq eval ".repositories.$key.url" data/repositories.yaml)
    description=$(yq eval ".repositories.$key.description" data/repositories.yaml)
    qualifications=$(yq eval ".repositories.$key.qualifications" data/repositories.yaml)
    size_limit=$(yq eval ".repositories.$key.size_limit" data/repositories.yaml)
    cost=$(yq eval ".repositories.$key.cost" data/repositories.yaml)
    metadata=$(yq eval ".repositories.$key.metadata_requirements" data/repositories.yaml)
    
    # Check if logo exists (try common image formats)
    logo=""
    for ext in png jpg jpeg svg ico; do
        if [ -f "images/${key}.${ext}" ]; then
            logo="<img src=\"images/${key}.${ext}\" height=\"16\"> "
            break
        fi
    done
    
    echo "| **${name}**<br>${logo}| [${short_url}](${url}) | ${description} | ${qualifications} | ${size_limit} | ${cost} | ${metadata} |" >> /tmp/table.md
done

echo "" >> /tmp/table.md

echo "📝 Updating README.md..."

# Use GNU sed for consistent behavior across platforms
if command -v gsed &> /dev/null; then
    SED=gsed
else
    SED=sed
fi

# Replace content between markers using sed
$SED -i '/<!-- AUTO-GENERATED TABLE START -->/,/<!-- AUTO-GENERATED TABLE END -->/{
    /<!-- AUTO-GENERATED TABLE START -->/r /tmp/table.md
    /<!-- AUTO-GENERATED TABLE START -->/!d
}' README.md

# Clean up
rm /tmp/table.md

echo "🎨 Formatting markdown..."

# Format with prettier if available
if command -v prettier &> /dev/null; then
    prettier --write README.md
    echo "✅ Markdown formatted with prettier"
else
    echo "⚠️  prettier not found, skipping formatting"
fi

echo "✅ Table updated successfully!"
echo "💡 Check the changes with: git diff README.md"
