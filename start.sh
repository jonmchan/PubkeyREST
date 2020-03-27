#!/bin/sh

# had some problems getting this working on gitlab, so trying to introduce script to make sure all dependencies are here before running.

/usr/local/bundle/bin/bundle
/usr/local/bundle/bin/bundle exec ruby main.rb -s Puma -o 0.0.0.0
