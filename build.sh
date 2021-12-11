#/bin/sh
rm -rf target/*
cp -r src/* target
cd target/sketchrope_ropefall
wine ../../../util/SketchUpRubyScramblerWindows.exe *
rm *.rb
cd ..
export DATE=`date +"%Y%m%d"`
zip ropefall_${DATE}.rbz *.rb sketchrope_ropefall/*

