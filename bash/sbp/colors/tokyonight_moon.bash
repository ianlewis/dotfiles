#!/usr/bin/env bash

# shellcheck disable=SC2034

# Color configuration for the segments.
# See src/colors/*.bash for the color values
# All segments colors have default values in src/config/colors.conf

# Tokyo Night Moon
################################################################################
# black = "#1b1d2b"
black="27;29;43"
# bg = "#222436",
bg="34;36;54" # NOTE: very similar to black
# bg_dark = "#1e2030",
bg_dark="30;32;48" # NOTE: very similar to black
# bg_dark1 = "#191B29",
bg_dark1="25;27;41" # NOTE: very similar to black
# bg_highlight = "#2f334d",
bg_highlight="47;51;77" # NOTE: very similar to black
# blue = "#82aaff",
blue="130;170;255"
# blue0 = "#3e68d7",
blue0="62;104;215"
# blue1 = "#65bcff",
blue1="101;188;255"
# blue2 = "#0db9d7",
blue2="13;185;215"
# blue5 = "#89ddff",
blue5="137;221;255" # NOTE: very similar to cyan
# blue6 = "#b4f9f8",
blue6="180;249;248"
# blue7 = "#394b70",
blue7="57;75;112" # NOTE: very similar to fg_gutter
# comment = "#636da6",
comment="99;109;166"
# cyan = "#86e1fc",
cyan="134;225;252"
# dark3 = "#545c7e",
dark3="84;92;126"
# dark5 = "#737aa2",
dark5="115;122;162"
# fg = "#c8d3f5",
fg="200;211;245"
# fg_dark = "#828bb8",
fg_dark="130;139;184"
# fg_gutter = "#3b4261",
fg_gutter="59;66;97"
# green = "#c3e88d",
green="195;232;141"
# green1 = "#4fd6be",
green1="79;214;190"
# green2 = "#41a6b5",
green2="65;166;181"
# magenta = "#c099ff",
magenta="192;153;255"
# magenta2 = "#ff007c",
magenta2="255;0;124"
# orange = "#ff966c",
# purple = "#fca7ea",
purple="252;167;234"
# red = "#ff757f",
red="197;59;83"
# red1 = "#c53b53",
red1="255;117;127"
# teal = "#4fd6be",
teal="79;214;190"
# terminal_black = "#444a73",
terminal_black="68;74;115"
# yellow = "#ffc777",
yellow="255;199;119"

# sbp color scheme
################################################################################
color0="${black}"
color1="${bg_highlight}"
color2="${blue}"
color3="${bg_dark1}"
color4="${fg}"
color5="${black}"
color6="" # This doesn't seem to be used.
color7="${fg_dark}"
color8="${red}"
color9="${fg_gutter}"
color10="${cyan}"
# color11="136;62;150"
color11="${dark3}"
color12="" # This doesn't seem to be used.
color13="${green}"
color14="${bg_dark}"
color15="${blue}"
