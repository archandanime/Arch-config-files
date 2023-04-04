#!/bin/bash

echo -n Minecraft Bedrock guardian spawn spots finder

echo
echo "
--> X
|            N
v
Z     North  | North
      West   | East
  W  --------+-------- E
      South  | South    <- here
      West   | East

             S
"
echo "Assume (X Z) is the SOUTH EAST corner of the empty 2x2 square on very top of the monument"
read -p "Enter X: " X
read -p "Enter Z: " Z
# echo $X $Z

Z1=$(( $Z - 27 ))
Z2=$(( $Z - 16))
Z3=$(( $Z - 0))
Z4=$(( $Z + 16))
Z5=$(( $Z + 26))

X1=$(($X - 27))
X2=$(($X - 16))
X3=$(($X - 0))
X4=$(($X + 16))
X5=$(($X + 26))



echo -e "
($X1 $Z1)\t($X1 $Z2)\t($X1 $Z3)\t($X1 $Z4)\t($X1 $Z5)\n
($X2 $Z1)\t($X2 $Z2)\t($X2 $Z3)\t($X2 $Z4)\t($X2 $Z5)\n
($X3 $Z1)\t($X3 $Z2)\t($X3 $Z3)\t($X3 $Z4)\t($X3 $Z5)\n
($X4 $Z1)\t($X4 $Z2)\t($X4 $Z3)\t($X4 $Z4)\t($X4 $Z5)\n
($X5 $Z1)\t($X5 $Z2)\t($X5 $Z3)\t($X5 $Z4)\t($X5 $Z5)\n
"

