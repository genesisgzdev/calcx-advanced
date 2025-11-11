#!/bin/bash
echo "Installing CalcX Advanced..."
command -v bc >/dev/null 2>&1 || {
    echo "Installing bc calculator..."
    sudo apt-get install bc -y 2>/dev/null || sudo yum install bc -y 2>/dev/null
}
sudo ln -sf "$(pwd)/calcx.sh" /usr/local/bin/calcx
mkdir -p "$HOME/.config/calcx"
cp config/calcx.conf "$HOME/.config/calcx/"
echo "✓ CalcX Advanced installed successfully!"
echo "Run 'calcx' from anywhere to start"
