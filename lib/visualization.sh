#!/bin/bash
# Visualization Library for CalcX Advanced
# Uses gnuplot for graphing and ASCII art for terminal display

# ==============================================================================
# GNUPLOT FUNCTIONS
# ==============================================================================

plot_function() {
    local function_expr="$1"
    local x_min="${2:--10}"
    local x_max="${3:-10}"
    local title="${4:-Function Plot}"
    local output_file="${5:-/tmp/calcx_plot_$$.png}"

    if ! command -v gnuplot >/dev/null 2>&1; then
        echo "Error: gnuplot not installed" >&2
        echo "Install with: sudo apt install gnuplot (Ubuntu/Debian)" >&2
        return 1
    fi

    gnuplot <<EOF
set terminal png size 800,600
set output "$output_file"
set title "$title"
set xlabel "x"
set ylabel "f(x)"
set grid
set samples 1000
plot [$x_min:$x_max] $function_expr title "$function_expr"
EOF

    if [ $? -eq 0 ]; then
        echo "Plot saved to: $output_file"
        # Try to open the image
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$output_file" 2>/dev/null &
        elif command -v open >/dev/null 2>&1; then
            open "$output_file" 2>/dev/null &
        fi
    else
        echo "Error: Failed to generate plot" >&2
        return 1
    fi
}

plot_data() {
    local data_file="$1"
    local title="${2:-Data Plot}"
    local output_file="${3:-/tmp/calcx_plot_$$.png}"
    local plot_style="${4:-linespoints}"

    if [ ! -f "$data_file" ]; then
        echo "Error: Data file not found" >&2
        return 1
    fi

    if ! command -v gnuplot >/dev/null 2>&1; then
        echo "Error: gnuplot not installed" >&2
        return 1
    fi

    gnuplot <<EOF
set terminal png size 800,600
set output "$output_file"
set title "$title"
set xlabel "x"
set ylabel "y"
set grid
plot "$data_file" with $plot_style title "$title"
EOF

    if [ $? -eq 0 ]; then
        echo "Plot saved to: $output_file"
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$output_file" 2>/dev/null &
        fi
    else
        echo "Error: Failed to generate plot" >&2
        return 1
    fi
}

plot_parametric() {
    local x_expr="$1"
    local y_expr="$2"
    local t_min="${3:-0}"
    local t_max="${4:-10}"
    local title="${5:-Parametric Plot}"
    local output_file="${6:-/tmp/calcx_plot_$$.png}"

    if ! command -v gnuplot >/dev/null 2>&1; then
        echo "Error: gnuplot not installed" >&2
        return 1
    fi

    gnuplot <<EOF
set terminal png size 800,600
set output "$output_file"
set title "$title"
set xlabel "x"
set ylabel "y"
set grid
set parametric
set samples 1000
plot [$t_min:$t_max] $x_expr,$y_expr title "$title"
EOF

    if [ $? -eq 0 ]; then
        echo "Plot saved to: $output_file"
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$output_file" 2>/dev/null &
        fi
    else
        echo "Error: Failed to generate plot" >&2
        return 1
    fi
}

plot_histogram() {
    local data_file="$1"
    local bins="${2:-20}"
    local title="${3:-Histogram}"
    local output_file="${4:-/tmp/calcx_plot_$$.png}"

    if [ ! -f "$data_file" ]; then
        echo "Error: Data file not found" >&2
        return 1
    fi

    if ! command -v gnuplot >/dev/null 2>&1; then
        echo "Error: gnuplot not installed" >&2
        return 1
    fi

    gnuplot <<EOF
set terminal png size 800,600
set output "$output_file"
set title "$title"
set xlabel "Value"
set ylabel "Frequency"
set grid
set boxwidth 0.9 relative
set style fill solid 1.0
bin_width = (1.0 * (GPVAL_DATA_Y_MAX - GPVAL_DATA_Y_MIN)) / $bins
bin(x, width) = width * floor(x/width)
plot "$data_file" using (bin(\$1, bin_width)):(1.0) smooth freq with boxes notitle
EOF

    if [ $? -eq 0 ]; then
        echo "Plot saved to: $output_file"
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$output_file" 2>/dev/null &
        fi
    else
        echo "Error: Failed to generate plot" >&2
        return 1
    fi
}

# ==============================================================================
# ASCII ART PLOTTING
# ==============================================================================

plot_ascii() {
    local function_expr="$1"
    local x_min="${2:--10}"
    local x_max="${3:-10}"
    local width="${4:-60}"
    local height="${5:-20}"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required for ASCII plotting" >&2
        return 1
    fi

    python3 <<EOF
import sys
import math

function_expr = "$function_expr"
x_min = $x_min
x_max = $x_max
width = $width
height = $height

# Create canvas
canvas = [[' ' for _ in range(width)] for _ in range(height)]

# Calculate function values
x_step = (x_max - x_min) / width
x_values = [x_min + i * x_step for i in range(width)]
y_values = []

for x in x_values:
    try:
        # Evaluate function
        y = eval(function_expr.replace('x', str(x)))
        y_values.append(y)
    except:
        y_values.append(float('nan'))

# Filter out NaN
valid_y = [y for y in y_values if not math.isnan(y)]
if not valid_y:
    print("Error: No valid y values")
    sys.exit(1)

y_min = min(valid_y)
y_max = max(valid_y)

if y_min == y_max:
    y_min -= 1
    y_max += 1

# Plot points
for i, (x, y) in enumerate(zip(x_values, y_values)):
    if math.isnan(y):
        continue

    # Map to canvas coordinates
    canvas_x = i
    canvas_y = int((y_max - y) / (y_max - y_min) * (height - 1))

    if 0 <= canvas_y < height:
        canvas[canvas_y][canvas_x] = '*'

# Draw axes
zero_y = int((y_max - 0) / (y_max - y_min) * (height - 1))
if 0 <= zero_y < height:
    for x in range(width):
        if canvas[zero_y][x] == ' ':
            canvas[zero_y][x] = '-'

zero_x = int((0 - x_min) / (x_max - x_min) * width)
if 0 <= zero_x < width:
    for y in range(height):
        if canvas[y][zero_x] == ' ':
            canvas[y][zero_x] = '|'

# Print canvas
print(f"f(x) = {function_expr}")
print(f"Range: x=[{x_min}, {x_max}], y=[{y_min:.2f}, {y_max:.2f}]")
print()
for row in canvas:
    print(''.join(row))
print()
print(f"{'─' * width}")
EOF
}

histogram_ascii() {
    local -a data=("$@")

    if [ ${#data[@]} -eq 0 ]; then
        echo "Error: No data provided" >&2
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required" >&2
        return 1
    fi

    python3 <<EOF
import sys
from collections import Counter

data = [${data[@]}]

# Create histogram
counts = Counter(data)
max_count = max(counts.values())
max_bar_width = 50

print("Histogram:")
print()

for value in sorted(counts.keys()):
    count = counts[value]
    bar_width = int((count / max_count) * max_bar_width)
    bar = '█' * bar_width
    print(f"{value:6.2f} | {bar} ({count})")

print()
print(f"Total values: {len(data)}")
print(f"Unique values: {len(counts)}")
print(f"Max frequency: {max_count}")
EOF
}

# ==============================================================================
# STATISTICAL VISUALIZATION
# ==============================================================================

box_plot_ascii() {
    local -a data=("$@")

    if [ ${#data[@]} -eq 0 ]; then
        echo "Error: No data provided" >&2
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required" >&2
        return 1
    fi

    python3 <<EOF
import sys

data = sorted([${data[@]}])
n = len(data)

# Calculate quartiles
q1_idx = n // 4
q2_idx = n // 2
q3_idx = 3 * n // 4

min_val = data[0]
q1 = data[q1_idx]
median = data[q2_idx]
q3 = data[q3_idx]
max_val = data[-1]

print("Box Plot:")
print()
print(f"Min    : {min_val:.2f}")
print(f"Q1     : {q1:.2f}")
print(f"Median : {median:.2f}")
print(f"Q3     : {q3:.2f}")
print(f"Max    : {max_val:.2f}")
print(f"IQR    : {q3 - q1:.2f}")
print()

# ASCII box plot
scale = 60 / (max_val - min_val) if max_val != min_val else 1

min_pos = 0
q1_pos = int((q1 - min_val) * scale)
med_pos = int((median - min_val) * scale)
q3_pos = int((q3 - min_val) * scale)
max_pos = int((max_val - min_val) * scale)

line = [' '] * 70
line[min_pos] = '|'
line[max_pos] = '|'

for i in range(min_pos, max_pos + 1):
    if line[i] == ' ':
        line[i] = '-'

for i in range(q1_pos, q3_pos + 1):
    line[i] = '█'

line[med_pos] = '|'

print(''.join(line))
print(' ' * min_pos + f'{min_val:.1f}' + ' ' * (max_pos - min_pos - 10) + f'{max_val:.1f}')
EOF
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

export -f plot_function plot_data plot_parametric plot_histogram
export -f plot_ascii histogram_ascii box_plot_ascii
