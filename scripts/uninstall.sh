#!/bin/bash
echo "Uninstalling CalcX Advanced..."
sudo rm -f /usr/local/bin/calcx
read -p "Remove configuration files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/calcx"
    rm -f "$HOME/.calcx_history"
    rm -f "$HOME/.calcx.log"
fi
echo "✓ CalcX Advanced uninstalled"
