#!/bin/bash


for p in $1/*.par ; do

    parname=$p
    timname="${p%.par}_pn.tim"

    outstem=""
    outroot="TPA_timing_export"
    mkdir -p $outroot

    timhead=$(basename ${timname%.tim})
    #`echo $timname | awk -F .tim '{print $1}'`
    par=$(basename ${parname%.par})
    # `echo $parname | awk -F .par '{print $1}'`

    # 1K mode, PTM not applied by PTUSE [PTM value -24.629 us]
    awk  '{if ($3 > 58526.21089) print $0, "-MJD_58526.21089_1K -1"; else print $0 }' $timname > tmp.tim

    # 1K mode PTM applied by PTUSE [PTM value -24.630]
    awk '{if ($3 > 58550.14921) print $0, "-MJD_58550.14921_1K -1"; else print $0 }' tmp.tim > tmp2.tim
    mv tmp2.tim tmp.tim

    # 1K mode, AJ added 1 sample [1.196 us] delay to PTUSE
    awk  '{if ($3 > 58550.14921) print $0, "-MJD_58550.14921B_1K -1"; else print $0 }' tmp.tim > tmp2.tim
    mv tmp2.tim tmp.tim

    # 1K mode, PTM sensor changed from -24 to -19 us [4.785 us]
    awk '{if ($3> 58557.14847) print $0, "-MJD_58557.14847_1K -1"; else print $0 }' tmp.tim > tmp2.tim
    mv tmp2.tim tmp.tim

    # 1K mode, AJ changed from 1 sample delay, to 0.5 sample delay in PTUSE
    awk '{if ($3 > 58575.95951) print $0, "-MJD_58575.9591_1K -1"; else print $0}' tmp.tim > tmp2.tim
    mv tmp2.tim tmp.tim


    #  306 microsec offset in CBF
    awk '{if (($3 > 58550) && ($3 < 58690)) print $0, "-MJD_58550_58690_1K -1"; else print $0}' tmp.tim > tmp2.tim
    mv tmp2.tim tmp.tim

    # Remove UHF and whatever this little range is that I guess is bad?
    awk '{if ( ($3  < 59378.46) || ($3 > 59387.1) || (($3 > 59386.8) && ($3 < 59386.9)))   print $0} ' < tmp.tim | grep -ve '/816/' tmp.tim > $outroot/${timhead}${outstem}.tim

    if grep -q TDB $parname ; then
        tempo2 -gr transform $parname t2.par
        parname=t2.par
    fi

    #Flags to add to parfile:
    grep -ve 'JUMP\|CLK\|EPHEM' ${parname}  | grep -ve '^F2 ' > $outroot/${par}${outstem}.par
    echo 'F2        0' >> $outroot/${par}${outstem}.par
    echo 'TRACK    -2' >> $outroot/${par}${outstem}.par
    echo 'EPHEM DE440' >> $outroot/${par}${outstem}.par
    echo "CLK TT(BIPM2019)" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58550_58690_1K -1 -0.000306243 0" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58526.21089_1K -1 -2.4628e-05 0" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58550.14921_1K -1 2.463e-05 0" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58550.14921B_1K -1 -1.196e-06 0" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58557.14847_1K -1 -4.785e-06 0" >> $outroot/${par}${outstem}.par
    echo "SATJUMP -MJD_58575.9591_1K -1 5.981308411e-07 0" >> $outroot/${par}${outstem}.par
    tempo2 -f $outroot/${par}${outstem}.par $outroot/${timhead}${outstem}.tim -newpar -nofit -fit f0 -fit f1
    mv new.par $outroot/${par}${outstem}.par
    echo $outroot/${par}${outstem}
done
