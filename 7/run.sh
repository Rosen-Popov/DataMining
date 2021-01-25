#!/bin/zsh
nim c -r --threads:on -d:release main.nim;
python3 graph.py;
