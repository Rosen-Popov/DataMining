#!/bin/zsh
nim c -r --threads:on main.nim;
python3 graph.py;
