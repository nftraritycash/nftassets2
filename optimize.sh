#!/bin/bash

# if file extensions need to be added
# for file in *; do mv "$file" "$(basename "$file").png"; done;
# if file extensions need to be removed
# for i in ./*.png; do mv -i "$i" "${i%.png}"; done

commandExists () {
  type "$1" &> /dev/null ;
}

installImageMagick() {
  if commandExists brew; then
    brew install imagemagick
  else
    apt-get install imagemagick
  fi
}

installJpegOptim() {
  if commandExists brew; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
    brew install jpegoptim
  else
    apt-get install jpegoptim
  fi
}

installOptiPng() {
  if commandExists brew; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
    brew install optipng
  else
    apt-get install optipng
  fi
}

resize() {
  RESIZE_PARAM='500x500>'
  # resize different file types in parallel
  find . -name "*.jpg" -exec convert -resize $RESIZE_PARAM -verbose {} {} \; & find . -name "*.jpeg" -exec convert -resize $RESIZE_PARAM -verbose {} {} \; & find . -name "*.png" -exec convert -resize $RESIZE_PARAM -verbose {} {} \;
}

optimizePng() {
  # change -o5 to the desired levels of optimisation, the higher the number the slower it will go
  find . -name "*.png" -exec optipng -o5 -strip all {} \;
}

optimizeJpg() {
  QUALITY=65
  # optimize differen file types in parallel
  find . -name "*.jpg" -exec jpegoptim --max=$QUALITY -o -p --strip-all {} \; & find . -name "*.jpeg" -exec jpegoptim --max=$QUALITY -o -p --strip-all {} \;
}

if ! commandExists jpegoptim; then
  installJpegOptim
fi

if ! commandExists optipng; then
  installOptiPng
fi

resize
optimizeJpg & optimizePng
