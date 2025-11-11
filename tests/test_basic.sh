#!/bin/bash
source ../lib/colors.sh

echo -e "${BOLD_CYAN}Running Basic Tests...${RESET}"

result=$(echo "2 + 2" | bc)
if [ "$result" = "4" ]; then
    print_success "Addition test passed"
else
    print_error "Addition test failed"
fi

result=$(echo "5 * 3" | bc)
if [ "$result" = "15" ]; then
    print_success "Multiplication test passed"
else
    print_error "Multiplication test failed"
fi

result=$(echo "scale=2; 10 / 3" | bc)
if [ "$result" = "3.33" ]; then
    print_success "Division test passed"
else
    print_error "Division test failed"
fi
