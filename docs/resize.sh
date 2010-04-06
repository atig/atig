#!/bin/sh
for i in $@; do
    echo $i
    mv $i $i.$$
    convert -resize 300x300 $i.$$ $i
    rm -f $i.$$
done
