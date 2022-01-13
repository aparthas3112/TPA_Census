#!/bin/bash


root=../tpa_ephemerides

if [[ -e output ]] ; then
    echo "delete old"
    rm output/*.par
else
    mkdir output
fi

for f in 2 3; do 
    for psr in $(cat ${f}x.list) ; do

        par=$root/${psr}.par
        opar=$root/${psr}_p${f}.par

        F0=$(grep -e "^F0 " $par | awk '{print $2}')
        oF0=$(grep -e "^F0 " $opar | awk '{print $2}')

        ratio=$(echo $F0 $oF0 | awk '{printf("%.0f\n",$2/$1)}')

        if [[ $ratio -ne $f ]] ;then
            echo $psr "${f}x  Ratio is: $ratio   ($F0 $oF0)"

            cp $par output/${psr}_p${f}.par

            ./eph_period_multiply.py output/${psr}_p${f}.par $f > output/${psr}.par
        fi

    done
done
