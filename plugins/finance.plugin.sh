#!/bin/bash
# PLUGIN_NAME: finance
# PLUGIN_VERSION: 1.0
# PLUGIN_DESCRIPTION: Financial calculations and analysis
# PLUGIN_AUTHOR: Genesis GZ

finance_init() {
    echo "Financial calculator plugin loaded"
}

finance_compound_interest() {
    local principal=$1
    local rate=$2
    local time=$3
    local n=${4:-1}  # Compounding frequency (default: annually)

    if [ -z "$principal" ] || [ -z "$rate" ] || [ -z "$time" ]; then
        echo "Usage: finance_compound_interest <principal> <rate> <time> [frequency]" >&2
        return 1
    fi

    # A = P(1 + r/n)^(nt)
    local result=$(echo "scale=2; $principal * e( l(1 + $rate / $n) * $n * $time )" | bc -l)
    echo "Principal: \$$principal"
    echo "Rate: $(echo "scale=2; $rate * 100" | bc)%"
    echo "Time: $time years"
    echo "Compounding: $n times per year"
    echo "Future Value: \$$result"
}

finance_loan_payment() {
    local principal=$1
    local annual_rate=$2
    local years=$3

    if [ -z "$principal" ] || [ -z "$annual_rate" ] || [ -z "$years" ]; then
        echo "Usage: finance_loan_payment <principal> <annual_rate> <years>" >&2
        return 1
    fi

    local monthly_rate=$(echo "scale=10; $annual_rate / 12" | bc -l)
    local num_payments=$(echo "$years * 12" | bc)

    # M = P[r(1+r)^n]/[(1+r)^n-1]
    local numerator=$(echo "scale=10; $principal * $monthly_rate * e( l(1 + $monthly_rate) * $num_payments )" | bc -l)
    local denominator=$(echo "scale=10; e( l(1 + $monthly_rate) * $num_payments ) - 1" | bc -l)
    local monthly_payment=$(echo "scale=2; $numerator / $denominator" | bc -l)
    local total_paid=$(echo "scale=2; $monthly_payment * $num_payments" | bc -l)
    local total_interest=$(echo "scale=2; $total_paid - $principal" | bc -l)

    echo "Loan Amount: \$$principal"
    echo "Annual Rate: $(echo "scale=2; $annual_rate * 100" | bc)%"
    echo "Term: $years years ($num_payments months)"
    echo "Monthly Payment: \$$monthly_payment"
    echo "Total Paid: \$$total_paid"
    echo "Total Interest: \$$total_interest"
}

finance_npv() {
    local rate=$1
    shift
    local -a cash_flows=("$@")

    if [ -z "$rate" ] || [ ${#cash_flows[@]} -eq 0 ]; then
        echo "Usage: finance_npv <discount_rate> <cash_flow_1> <cash_flow_2> ..." >&2
        return 1
    fi

    local npv=0
    local t=0

    for cf in "${cash_flows[@]}"; do
        local pv=$(echo "scale=6; $cf / e( l(1 + $rate) * $t )" | bc -l)
        npv=$(echo "scale=2; $npv + $pv" | bc -l)
        t=$((t + 1))
    done

    echo "Discount Rate: $(echo "scale=2; $rate * 100" | bc)%"
    echo "Cash Flows: ${cash_flows[@]}"
    echo "NPV: \$$npv"
}

finance_irr() {
    local -a cash_flows=("$@")

    if [ ${#cash_flows[@]} -lt 2 ]; then
        echo "Usage: finance_irr <cash_flow_0> <cash_flow_1> ..." >&2
        return 1
    fi

    # Use Newton-Raphson to find IRR
    if ! command -v python3 >/dev/null 2>&1; then
        echo "Error: Python required for IRR calculation" >&2
        return 1
    fi

    python3 <<EOF
import sys
cash_flows = [${cash_flows[@]}]

def npv(rate, cfs):
    return sum(cf / (1 + rate)**t for t, cf in enumerate(cfs))

def npv_derivative(rate, cfs):
    return sum(-t * cf / (1 + rate)**(t+1) for t, cf in enumerate(cfs))

# Newton-Raphson
rate = 0.1  # Initial guess
tolerance = 1e-6
max_iterations = 100

for i in range(max_iterations):
    npv_val = npv(rate, cash_flows)
    npv_deriv = npv_derivative(rate, cash_flows)

    if abs(npv_deriv) < 1e-10:
        break

    new_rate = rate - npv_val / npv_deriv

    if abs(new_rate - rate) < tolerance:
        rate = new_rate
        break

    rate = new_rate

print(f"Cash Flows: {cash_flows}")
print(f"IRR: {rate*100:.2f}%")
EOF
}

finance_annuity() {
    local pv=$1
    local rate=$2
    local periods=$3

    if [ -z "$pv" ] || [ -z "$rate" ] || [ -z "$periods" ]; then
        echo "Usage: finance_annuity <present_value> <rate_per_period> <num_periods>" >&2
        return 1
    fi

    # PMT = PV * [r(1+r)^n] / [(1+r)^n - 1]
    local numerator=$(echo "scale=10; $pv * $rate * e( l(1 + $rate) * $periods )" | bc -l)
    local denominator=$(echo "scale=10; e( l(1 + $rate) * $periods ) - 1" | bc -l)
    local payment=$(echo "scale=2; $numerator / $denominator" | bc -l)

    echo "Present Value: \$$pv"
    echo "Rate per Period: $(echo "scale=4; $rate * 100" | bc)%"
    echo "Number of Periods: $periods"
    echo "Payment per Period: \$$payment"
}

finance_cleanup() {
    echo "Financial calculator plugin unloaded"
}

export -f finance_init finance_compound_interest finance_loan_payment
export -f finance_npv finance_irr finance_annuity finance_cleanup
