#!/bin/sh -e
shotgun $(hacksaw -f "-i %i -g %g") - | xclip -t 'image/png' -selection clipboard
