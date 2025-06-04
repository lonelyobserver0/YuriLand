#! /bin/bash

selected=$(ls /home/loneobs/Scripts/|rofi -dmenu -p "Run a Custom Script: ")&&bash /home/loneobs/Scripts/$selected
