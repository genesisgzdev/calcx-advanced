#!/bin/bash
# Unit Conversion Library for CalcX Advanced
# Provides functions for converting between various units of measurement

# ==============================================================================
# TEMPERATURE CONVERSIONS
# ==============================================================================

celsius_to_fahrenheit() {
    local celsius=$1
    echo "scale=6; ($celsius * 9/5) + 32" | bc -l
}

fahrenheit_to_celsius() {
    local fahrenheit=$1
    echo "scale=6; ($fahrenheit - 32) * 5/9" | bc -l
}

celsius_to_kelvin() {
    local celsius=$1
    echo "scale=6; $celsius + 273.15" | bc -l
}

kelvin_to_celsius() {
    local kelvin=$1
    echo "scale=6; $kelvin - 273.15" | bc -l
}

fahrenheit_to_kelvin() {
    local fahrenheit=$1
    local celsius=$(fahrenheit_to_celsius $fahrenheit)
    celsius_to_kelvin $celsius
}

kelvin_to_fahrenheit() {
    local kelvin=$1
    local celsius=$(kelvin_to_celsius $kelvin)
    celsius_to_fahrenheit $celsius
}

# ==============================================================================
# LENGTH/DISTANCE CONVERSIONS
# ==============================================================================

meters_to_feet() {
    local meters=$1
    echo "scale=6; $meters * 3.28084" | bc -l
}

feet_to_meters() {
    local feet=$1
    echo "scale=6; $feet / 3.28084" | bc -l
}

meters_to_miles() {
    local meters=$1
    echo "scale=6; $meters / 1609.344" | bc -l
}

miles_to_meters() {
    local miles=$1
    echo "scale=6; $miles * 1609.344" | bc -l
}

meters_to_kilometers() {
    local meters=$1
    echo "scale=6; $meters / 1000" | bc -l
}

kilometers_to_meters() {
    local kilometers=$1
    echo "scale=6; $kilometers * 1000" | bc -l
}

miles_to_kilometers() {
    local miles=$1
    echo "scale=6; $miles * 1.609344" | bc -l
}

kilometers_to_miles() {
    local kilometers=$1
    echo "scale=6; $kilometers / 1.609344" | bc -l
}

inches_to_centimeters() {
    local inches=$1
    echo "scale=6; $inches * 2.54" | bc -l
}

centimeters_to_inches() {
    local centimeters=$1
    echo "scale=6; $centimeters / 2.54" | bc -l
}

# ==============================================================================
# WEIGHT/MASS CONVERSIONS
# ==============================================================================

kilograms_to_pounds() {
    local kilograms=$1
    echo "scale=6; $kilograms * 2.20462" | bc -l
}

pounds_to_kilograms() {
    local pounds=$1
    echo "scale=6; $pounds / 2.20462" | bc -l
}

grams_to_ounces() {
    local grams=$1
    echo "scale=6; $grams * 0.035274" | bc -l
}

ounces_to_grams() {
    local ounces=$1
    echo "scale=6; $ounces / 0.035274" | bc -l
}

grams_to_kilograms() {
    local grams=$1
    echo "scale=6; $grams / 1000" | bc -l
}

kilograms_to_grams() {
    local kilograms=$1
    echo "scale=6; $kilograms * 1000" | bc -l
}

# ==============================================================================
# SPEED CONVERSIONS
# ==============================================================================

mph_to_kph() {
    local mph=$1
    echo "scale=6; $mph * 1.609344" | bc -l
}

kph_to_mph() {
    local kph=$1
    echo "scale=6; $kph / 1.609344" | bc -l
}

mph_to_mps() {
    local mph=$1
    echo "scale=6; $mph * 0.44704" | bc -l
}

mps_to_mph() {
    local mps=$1
    echo "scale=6; $mps / 0.44704" | bc -l
}

kph_to_mps() {
    local kph=$1
    echo "scale=6; $kph / 3.6" | bc -l
}

mps_to_kph() {
    local mps=$1
    echo "scale=6; $mps * 3.6" | bc -l
}

# ==============================================================================
# DATA/STORAGE CONVERSIONS
# ==============================================================================

bytes_to_kilobytes() {
    local bytes=$1
    echo "scale=6; $bytes / 1024" | bc -l
}

kilobytes_to_bytes() {
    local kilobytes=$1
    echo "scale=6; $kilobytes * 1024" | bc -l
}

kilobytes_to_megabytes() {
    local kilobytes=$1
    echo "scale=6; $kilobytes / 1024" | bc -l
}

megabytes_to_kilobytes() {
    local megabytes=$1
    echo "scale=6; $megabytes * 1024" | bc -l
}

megabytes_to_gigabytes() {
    local megabytes=$1
    echo "scale=6; $megabytes / 1024" | bc -l
}

gigabytes_to_megabytes() {
    local gigabytes=$1
    echo "scale=6; $gigabytes * 1024" | bc -l
}

gigabytes_to_terabytes() {
    local gigabytes=$1
    echo "scale=6; $gigabytes / 1024" | bc -l
}

terabytes_to_gigabytes() {
    local terabytes=$1
    echo "scale=6; $terabytes * 1024" | bc -l
}

# ==============================================================================
# VOLUME CONVERSIONS
# ==============================================================================

liters_to_gallons() {
    local liters=$1
    echo "scale=6; $liters * 0.264172" | bc -l
}

gallons_to_liters() {
    local gallons=$1
    echo "scale=6; $gallons / 0.264172" | bc -l
}

liters_to_milliliters() {
    local liters=$1
    echo "scale=6; $liters * 1000" | bc -l
}

milliliters_to_liters() {
    local milliliters=$1
    echo "scale=6; $milliliters / 1000" | bc -l
}

cups_to_milliliters() {
    local cups=$1
    echo "scale=6; $cups * 236.588" | bc -l
}

milliliters_to_cups() {
    local milliliters=$1
    echo "scale=6; $milliliters / 236.588" | bc -l
}

# ==============================================================================
# TIME CONVERSIONS
# ==============================================================================

seconds_to_minutes() {
    local seconds=$1
    echo "scale=6; $seconds / 60" | bc -l
}

minutes_to_seconds() {
    local minutes=$1
    echo "scale=6; $minutes * 60" | bc -l
}

minutes_to_hours() {
    local minutes=$1
    echo "scale=6; $minutes / 60" | bc -l
}

hours_to_minutes() {
    local hours=$1
    echo "scale=6; $hours * 60" | bc -l
}

hours_to_days() {
    local hours=$1
    echo "scale=6; $hours / 24" | bc -l
}

days_to_hours() {
    local days=$1
    echo "scale=6; $days * 24" | bc -l
}

# ==============================================================================
# ENERGY CONVERSIONS
# ==============================================================================

joules_to_calories() {
    local joules=$1
    echo "scale=6; $joules * 0.239006" | bc -l
}

calories_to_joules() {
    local calories=$1
    echo "scale=6; $calories / 0.239006" | bc -l
}

joules_to_kilowatt_hours() {
    local joules=$1
    echo "scale=6; $joules / 3600000" | bc -l
}

kilowatt_hours_to_joules() {
    local kwh=$1
    echo "scale=6; $kwh * 3600000" | bc -l
}

# ==============================================================================
# PRESSURE CONVERSIONS
# ==============================================================================

pascals_to_psi() {
    local pascals=$1
    echo "scale=6; $pascals * 0.000145038" | bc -l
}

psi_to_pascals() {
    local psi=$1
    echo "scale=6; $psi / 0.000145038" | bc -l
}

pascals_to_bar() {
    local pascals=$1
    echo "scale=6; $pascals / 100000" | bc -l
}

bar_to_pascals() {
    local bar=$1
    echo "scale=6; $bar * 100000" | bc -l
}

# ==============================================================================
# GENERIC CONVERSION DISPATCHER
# Parses human-readable conversion strings like "100 celsius to fahrenheit"
# ==============================================================================

convert() {
    local input="$1"

    # Parse the conversion string: "VALUE UNIT to UNIT"
    if [[ ! "$input" =~ ^([0-9.+-]+)[[:space:]]+([a-zA-Z_/]+)[[:space:]]+to[[:space:]]+([a-zA-Z_/]+)$ ]]; then
        echo "Error: Invalid format. Use: VALUE UNIT to UNIT"
        echo "Example: 100 celsius to fahrenheit"
        return 1
    fi

    local value="${BASH_REMATCH[1]}"
    local from_unit="${BASH_REMATCH[2],,}"  # Convert to lowercase
    local to_unit="${BASH_REMATCH[3],,}"    # Convert to lowercase

    # Build function name from units
    local func_name="${from_unit}_to_${to_unit}"

    # Check if function exists
    if declare -f "$func_name" > /dev/null; then
        result=$($func_name "$value")
        echo "$result"
        return 0
    else
        echo "Error: Conversion from '$from_unit' to '$to_unit' not supported"
        echo "Available conversions include:"
        echo "  Temperature: celsius, fahrenheit, kelvin"
        echo "  Length: meters, feet, miles, kilometers, inches, centimeters"
        echo "  Weight: grams, kilograms, pounds, ounces"
        echo "  Speed: mph, kph, mps"
        echo "  Data: bytes, kilobytes, megabytes, gigabytes, terabytes"
        echo "  Volume: liters, gallons, milliliters, cups"
        echo "  Time: seconds, minutes, hours, days"
        echo "  Energy: joules, calories, kilowatt_hours"
        echo "  Pressure: pascals, psi, bar"
        return 1
    fi
}

# Export all conversion functions for use in other scripts
export -f celsius_to_fahrenheit fahrenheit_to_celsius celsius_to_kelvin
export -f kelvin_to_celsius fahrenheit_to_kelvin kelvin_to_fahrenheit
export -f meters_to_feet feet_to_meters meters_to_miles miles_to_meters
export -f meters_to_kilometers kilometers_to_meters miles_to_kilometers kilometers_to_miles
export -f inches_to_centimeters centimeters_to_inches
export -f kilograms_to_pounds pounds_to_kilograms grams_to_ounces ounces_to_grams
export -f grams_to_kilograms kilograms_to_grams
export -f mph_to_kph kph_to_mph mph_to_mps mps_to_mph kph_to_mps mps_to_kph
export -f bytes_to_kilobytes kilobytes_to_bytes kilobytes_to_megabytes megabytes_to_kilobytes
export -f megabytes_to_gigabytes gigabytes_to_megabytes gigabytes_to_terabytes terabytes_to_gigabytes
export -f liters_to_gallons gallons_to_liters liters_to_milliliters milliliters_to_liters
export -f cups_to_milliliters milliliters_to_cups
export -f seconds_to_minutes minutes_to_seconds minutes_to_hours hours_to_minutes
export -f hours_to_days days_to_hours
export -f joules_to_calories calories_to_joules joules_to_kilowatt_hours kilowatt_hours_to_joules
export -f pascals_to_psi psi_to_pascals pascals_to_bar bar_to_pascals
export -f convert
