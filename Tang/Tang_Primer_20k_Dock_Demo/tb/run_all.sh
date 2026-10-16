#!/bin/sh
# Runs all testbenches from the project root.
set -e
mkdir -p build sim
python3 tb/test_eth.py
