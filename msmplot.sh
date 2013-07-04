#!/bin/sh
#
# msmplot.sh
#
# produced by Takashi Unuma, Kyoto Univ.
# Last modified: 2013/07/05
#

### for debug
debug_level=100

### for picture option
picopt=0

### for draw range 
# default
dRANGE="120/150/22.4/47.6";dPRJ="m0.131";vINT=2
# case 20120506
#dRANGE="135.0/145.0/31.0/39.5";dPRJ="m0.3925";vINT=1
# case 20080513
#dRANGE="132/135/32/35";dPRJ="m1.31";vINT=0.2
# case 20130317
#dRANGE="120/130/22.4/31.0";dPRJ="m0.3925";vINT=1

############################################################
# executable section
############################################################
source ~/.bashrc
alias rm="rm"
WGRIB2=/usr/local/grads-2.0.a9/bin/wgrib2
export PATH="/home/unuma/usr/local/gmt-4.5.9_barbjp/bin:${PATH}"
export PATH="/home/unuma/usr/local/bin:${PATH}"

wwwdir="/home/unuma/www"

echo "Start Time = `date +%F_%T`"
 
export LANG=en_US
date=$(TZ=JST-9 date +%Y%m%d)
hh=$(TZ=JST-9 date +%H)

if test $# -eq 1 ; then
    input=$1
    date=${input:0:8}
    hh=${input:8:2}
    echo "Time: ${date}${hh} (UTC)"
fi

yyyy=${date:0:4}
mm=${date:4:2}
dd=${date:6:2}
URL="http://database.rish.kyoto-u.ac.jp/arch/jmadata/data/gpv/original"
OPT="--wait=15 --no-verbose"
#OPT="--wait=15 --no-verbose --append-output=/home/unuma/www/autoplot/wget.log"

if test ${debug_level} -ge 100 ; then
    echo "DEBUG MODE"
    if test $# -eq 1 ; then
	if test -s /work7/work2/DATA/msm_grib2/${yyyy}/${mm}/${file0} ; then
	    file0=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_L-pall_FH00-15_grib2.bin
	    ln -s /work7/work2/DATA/msm_grib2/${yyyy}/${mm}/${file0} ./
	    file1=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_Lsurf_FH00-15_grib2.bin
	    ln -s /work7/work2/DATA/msm_grib2/${yyyy}/${mm}/${file1} ./
	else
	    file0=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_L-pall_FH00-15_grib2.bin
	    wget ${OPT} ${URL}/${yyyy}/${mm}/${dd}/${file0}
	    file1=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_Lsurf_FH00-15_grib2.bin
	    wget ${OPT} ${URL}/${yyyy}/${mm}/${dd}/${file1}
	fi
    else
	file0=Z__C_RJTD_20080513120000_MSM_GPV_Rjp_L-pall_FH00-15_grib2.bin
	ln -s /work7/work2/DATA/msm_grib2/2008/05/${file0} ./
	file1=Z__C_RJTD_20080513120000_MSM_GPV_Rjp_Lsurf_FH00-15_grib2.bin
	ln -s /work7/work2/DATA/msm_grib2/2008/05/${file1} ./
    fi

else
    file0=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_L-pall_FH00-15_grib2.bin
    wget ${OPT} ${URL}/${yyyy}/${mm}/${dd}/${file0}
    file1=Z__C_RJTD_${yyyy}${mm}${dd}${hh}0000_MSM_GPV_Rjp_Lsurf_FH00-15_grib2.bin
    wget ${OPT} ${URL}/${yyyy}/${mm}/${dd}/${file1}
fi

RANGE="120/150/22.4/47.6"
PRJ="m0.131"
INT0="0.0625/0.05"
INT1="0.125/0.1"
if test -s ${file1} ; then
    ${WGRIB2} -match 'anl' ${file1} -grib MSM_S > /dev/null 2>&1
    ${WGRIB2} MSM_S -s | grep ":PRMSL:"  | ${WGRIB2} -i -no_header MSM_S -bin prmsl.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_S -s | grep ":UGRD:"   | ${WGRIB2} -i -no_header MSM_S -bin u10.bin   >> /dev/null 2>&1
    ${WGRIB2} MSM_S -s | grep ":VGRD:"   | ${WGRIB2} -i -no_header MSM_S -bin v10.bin   >> /dev/null 2>&1
    ${WGRIB2} MSM_S -s | grep ":TMP:"    | ${WGRIB2} -i -no_header MSM_S -bin temp.bin  >> /dev/null 2>&1
    ${WGRIB2} MSM_S -s | grep ":RH:"     | ${WGRIB2} -i -no_header MSM_S -bin rh.bin    >> /dev/null 2>&1
    
    ${WGRIB2} -match 'anl' ${file0} -grib MSM_P >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":HGT:"   | ${WGRIB2} -i -no_header MSM_P -bin hgt.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":TMP:"   | ${WGRIB2} -i -no_header MSM_P -bin ttt.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":RH:"    | ${WGRIB2} -i -no_header MSM_P -bin rhh.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":UGRD:"  | ${WGRIB2} -i -no_header MSM_P -bin uuu.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":VGRD:"  | ${WGRIB2} -i -no_header MSM_P -bin vvv.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":VVEL:"  | ${WGRIB2} -i -no_header MSM_P -bin www.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":UGRD:975"  | ${WGRIB2} -i -no_header MSM_P -bin u975.bin >> /dev/null 2>&1
    ${WGRIB2} MSM_P -s | grep ":VGRD:975"  | ${WGRIB2} -i -no_header MSM_P -bin v975.bin >> /dev/null 2>&1

else
    echo "failer wget section"
    exit 1
fi

if test ${debug_level} -ge 100 ; then
    echo "DEBUG MODE"
    /home/unuma/work/program/msmplot/calc_index #> /home/unuma/work/program/msmplot/src/msmindex.log 2>&1
else
    /home/unuma/work/program/msmplot/calc_index > /dev/null 2>&1
fi


if test -s "temp.bin" ; then
    # for surface data
    for file in temp u10 v10 press qv thetae td ; do
	xyz2grd ${file}.bin -G${file}.grd -R${RANGE} -I${INT0} -ZBLf
    done

    # for pressure data
    for file in brn cape cin ehi ki lcl lfc lnb pw srh ssi tt wsh lsta dlfc dlnb ; do
	xyz2grd ${file}.bin -G${file}.grd -R${RANGE} -I${INT1} -ZBLf
    done

    for level in 1000 975 950 925 850 700 500 300 250 200 ; do
	ls *${level}.bin | parallel -j +0 xyz2grd {} -G{.}.grd -R${RANGE} -I${INT1} -ZBLf
    done

else
    echo "fail wgrib2 section"
    exit 1
fi

wind=0
for ifile in $(ls *.grd) ; do
    file=${ifile%.grd}
#    echo "Now execute: ${file}"

    rm -f .gmt*
    gmtdefaults -D > .gmtdefaults4
    gmtset HEADER_FONT_SIZE       6p
    gmtset LABEL_FONT_SIZE        6p
    gmtset ANOT_FONT_SIZE         5p
    gmtset ANNOT_OFFSET_PRIMARY 0.03c
    gmtset BASEMAP_TYPE        plain
    gmtset TICK_LENGTH        -0.10c
    gmtset FRAME_PEN           0.20p
    gmtset GRID_PEN            0.20p
    gmtset TICK_PEN            0.25p
    gmtset MEASURE_UNIT           cm
    gmtset PAPER_MEDIA            a4
    gmtset VECTOR_SHAPE            2
    
    gmtsta='-P -K'
    gmtcon='-P -K -O'
    gmtend='-P -O'
    
    if test ${picopt} -eq 1 ; then
	ymdh=$(/home/unuma/usr/local/bin/utc2jst ${yyyy}${mm}${dd}${hh}00 | cut -c1-10)
	Y=${ymdh:0:4}
	m=${ymdh:4:2}
	M=$(/home/unuma/usr/local/bin/mm2MMM ${m})
	D=${ymdh:6:2}
	H=${ymdh:8:2}
	psfile=${file}_${Y}${m}${D}${H}.ps
    else
	psfile=${file}.ps
    fi

    if test ${file} = "prmsl" ; then
	unucpt prmsl 99200 104800 400
	unit="[Pa]"
	wind=0
    elif test ${file} = "press" ; then
	unucpt press 960 1048 4
	unit="[hPa]"
	wind=0
    elif test ${file} = "hgt500" ; then
	unucpt hgt500 4800 6300 50
	scaleopt="a300f50"
	unit="[hPa]"
	wind=0
    elif test ${file} = "temp" ; then
	unucpt temp 232 312 3
	scaleopt="a9f3"
	unit="[K]"
	wind=0
    elif test ${file} = "temp850" ; then
	unucpt temp850 -18 18 3
	scaleopt="a9f3"
	unit="[K]"
	wind="850"
    elif test ${file} = "temp700" ; then
	unucpt temp700 -27 9 3
	scaleopt="a9f3"
	unit="[K]"
	wind="700"
    elif test ${file} = "temp500" ; then
	unucpt temp500 -39 0 3
	scaleopt="a9f3"
	unit="[C]"
	wind="500"
    elif test ${file} = "td" ; then
	unucpt td 232 312 3
	scaleopt="a30f3"
	unit="[K]"
	wind=0
    elif test ${file} = "thetae" ; then
	#unucpt thetae 270 330 3
	unucpt thetae 270 360 3
	scaleopt="a30f6"
	unit="[K]"
	wind="surface"
    elif test ${file} = "thetae975" ; then
	#unucpt thetae975 240 330 6
	unucpt thetae975 270 360 6
	scaleopt="a30f6"
	unit="[K]"
	wind="975"
    elif test ${file} = "thetae950" ; then
	#unucpt thetae950 240 330 6
	unucpt thetae950 270 360 6
	scaleopt="a30f6"
	unit="[K]"
	wind="950"
    elif test ${file} = "thetae925" ; then
	#unucpt thetae925 240 330 6
	unucpt thetae925 270 360 6
	scaleopt="a30f6"
	unit="[K]"
	wind="925"
    elif test ${file} = "rh" ; then
	unucpt rh 0 100 10
	scaleopt="a20f10"
	unit="[%]"
	wind=0
    elif test ${file} = "qv" ; then
	#unucpt qv 0 20 2
	unucpt qv 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="surface"
    elif test ${file} = "qv1000" ; then
	unucpt qv1000 0 20 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="1000"
    elif test ${file} = "qv975" ; then
	#unucpt qv975 0 20 2
	unucpt qv975 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="975"
    elif test ${file} = "qv950" ; then
	#unucpt qv950 0 20 2
	unucpt qv950 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="950"
    elif test ${file} = "qv925" ; then
	#unucpt qv925 0 20 2
	unucpt qv925 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="925"
    elif test ${file} = "qv850" ; then
	#unucpt qv850 0 20 2
	unucpt qv850 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="850"
    elif test ${file} = "qv700" ; then
	#unucpt qv700 0 20 2
	unucpt qv700 0 24 2
	scaleopt="a4f2"
	unit="[g/kg]"
	wind="700"
    elif test ${file} = "cape" ; then
	unucpt cape 0 1500 100
	scaleopt="a500f100"
	unit="[J/kg]"
	wind=0
    elif test ${file} = "cin" ; then
	unucpt cin 0 250 10
	scaleopt="a50f10"
	unit="[J/kg]"
	wind=0
    elif test ${file} = "lcl" ; then
	unucpt lcl 500 2000 250
	scaleopt="a500f250"
	unit="[m]"
	wind=0
    elif test ${file} = "lfc" ; then
	unucpt lfc 500 5000 250
	scaleopt="a1000f250"
	unit="[m]"
	wind=0
    elif test ${file} = "lnb" ; then
	unucpt lnb 500 10000 500
	scaleopt="a2500f500"
	unit="[m]"
	wind=0
    elif test ${file} = "dlfc" ; then
	unucpt dlfc 250 2000 250
	scaleopt="a500f250"
	unit="[m]"
	wind=0
    elif test ${file} = "dlnb" ; then
	unucpt dlnb 500 5000 500
	scaleopt="a1000f500"
	unit="[m]"
	wind=0
    elif test ${file} = "lsta" ; then
	unucpt lsta -20 15 5 polar
	scaleopt="a5"
	unit="[K]"
	wind=0
    elif test ${file} = "wspd250" ; then
	unucpt wspd250 0 100 10
	scaleopt="a20f10"
	unit="[m/s]"
	wind=0
    elif test ${file} = "wspd500" ; then
	unucpt wspd500 0 100 10
	scaleopt="a20f10"
	unit="[m/s]"
	wind=0
    elif test ${file} = "wsh" ; then
	unucpt wsh 0 50 5
	scaleopt="a10f5"
	unit="[m/s]"
	wind=0
    elif test ${file} = "pv200" ; then
	unucpt pv200 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pv300" ; then
	unucpt pv300 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pv500" ; then
	unucpt pv500 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pv700" ; then
	unucpt pv700 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pv850" ; then
	unucpt pv850 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pv950" ; then
	unucpt pv950 0 5 0.5
	scaleopt="a1f0.5"
	unit="[PVU]"
	wind=0
    elif test ${file} = "pw" ; then
	unucpt pw 0 100 10
	scaleopt="a10f5"
	unit="[mm]"
	wind=0
    elif test ${file} = "ki" ; then
	unucpt ki 0 60 5
	scaleopt="a10f5"
	unit="[C]"
	wind=0
    elif test ${file} = "tt" ; then
	unucpt tt 0 60 5
	scaleopt="a10f5"
	unit="[K]"
	wind=0
    elif test ${file} = "ehi" ; then
	unucpt ehi 0 3 0.2
	scaleopt="a1f0.2"
	unit="[m^2/s^2*J/kg]"
	wind=0
    elif test ${file} = "srh" ; then
	unucpt srh 25 350 25
	scaleopt="a50f25"
	unit="[m^2/s^2]"
	wind=0
    elif test ${file} = "ssi" ; then
	unucpt ssi -9 9 3
	scaleopt="a3f1"
	unit="[K]"
	wind=0
    elif test ${file} = "brn" ; then
	unucpt brn 0 60 5
	scaleopt="a10f5"
	unit="[-]"
	wind=0
    elif test ${file} = "qfwind975" ; then
	unucpt qfwind975 0 1000 100
	scaleopt="a500f100"
	unit="[g/(m^2*s)]"
	wind="qf975"
    elif test ${file} = "qfwind950" ; then
	unucpt qfwind950 0 1000 100
	scaleopt="a500f100"
	unit="[g/(m^2*s)]"
	wind="qf950"
    elif test ${file} = "qfwind925" ; then
	unucpt qfwind925 0 1000 100
	scaleopt="a500f100"
	unit="[g/(m^2*s)]"
	wind=0
    elif test ${file} = "qfdiv975" ; then
	unucpt qfdiv975 -500 500 100 polar
	scaleopt="a500f100"
	unit="[g/(m*s)]"
	wind=0
    elif test ${file} = "qfdiv950" ; then
	unucpt qfdiv950 -500 500 100 polar
	scaleopt="a500f100"
	unit="[g/(m*s)]"
	wind=0
    elif test ${file} = "qfdiv925" ; then
	unucpt qfdiv925 -500 500 100 polar
	scaleopt="a500f100"
	unit="[g/(m*s)]"
	wind=0
    else
	#echo "Not supported"
	continue
    fi

    if test ${file} = "prmsl" -o ${file} = "press" ; then
        # grdcontour
	grdcontour ${file}.grd -J${dPRJ} -R${dRANGE} -Ba10WSne -W0.25,255/0/0 -A4tf3 -Ccpalet_${file}.cpt -X1.0 -Y1.0 ${gmtsta} > ${psfile}

        # pscoast
	pscoast -J${dPRJ} -R${dRANGE} -W1.2 -A100 -Df ${gmtcon} >> ${psfile}
    elif test ${file} = "srh" -o ${file} = "brn" -o ${file} = "cape" -o ${file} = "cin" -o ${file} = "lcl" -o ${file} = "lfc" -o ${file} = "lnb" -o ${file} = "qfdiv925" -o ${file} = "qfdiv950" -o ${file} = "qfdiv975" ; then
	# grdimage
	grdimage ${file}.grd -J${dPRJ} -R${dRANGE} -Ba10WSne -Ccpalet_${file}.cpt -X1.0 -Y1.0 ${gmtsta} > ${psfile}

        # pscoast
	pscoast -J${dPRJ} -R${dRANGE} -W1.2 -A100 -Df ${gmtcon} >> ${psfile}

	# psscale
	gmtset FRAME_PEN 0.10p
	gmtset GRID_PEN  0.10p
	gmtset TICK_PEN  0.10p
	gmtset ANOT_FONT_SIZE 3p
	psscale -D1.0/-0.3/2.0/0.1h -Ccpalet_${file}.cpt -B${scaleopt}/:"${unit}": ${gmtcon} >> ${psfile}
    else
        # grdimage
	grdimage ${file}.grd -J${dPRJ} -R${dRANGE} -Ba10WSne -Ccpalet_${file}.cpt -X1.0 -Y1.0 ${gmtsta} > ${psfile}

        # grdcontour
	grdcontour ${file}.grd -J${dPRJ} -R${dRANGE} -W0.25,0/0/0 -A- -Ccpalet_${file}.cpt ${gmtcon} >> ${psfile}

        # pscoast
	pscoast -J${dPRJ} -R${dRANGE} -W1.2 -A100 -Df ${gmtcon} >> ${psfile}

	# psscale
	gmtset FRAME_PEN 0.10p
	gmtset GRID_PEN  0.10p
	gmtset TICK_PEN  0.10p
	gmtset ANOT_FONT_SIZE 3p
	psscale -D1.0/-0.3/2.0/0.1h -Ccpalet_${file}.cpt -B${scaleopt}/:"${unit}": ${gmtcon} >> ${psfile}
    fi

if test ${wind} = "surface" ; then
    grdbarb u10.grd v10.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "1000" ; then
    grdbarb u1000.grd v1000.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "975" ; then
    grdbarb u975.grd v975.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "qf975" ; then
    grdvector qfu975.grd qfv975.grd -J${dPRG} -R${dRANGE} -S2000 -Q0.005/0.1/0.05n0.25 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.0 0.65 0.0 0.5" | psxy -R1/100/1/100 -Jx1.0 -Sv0.005/0.1/0.05 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.5 0.5 3 0.0 0 MC 1000 [g/(m^2*s)]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "950" ; then
    grdbarb u950.grd v950.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "qf950" ; then
    grdvector qfu950.grd qfv950.grd -J${dPRG} -R${dRANGE} -S2000 -Q0.005/0.1/0.05n0.25 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.0 0.65 0.0 0.5" | psxy -R1/100/1/100 -Jx1.0 -Sv0.005/0.1/0.05 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.5 0.5 3 0.0 0 MC 1000 [g/(m^2*s)]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "925" ; then
    grdbarb u925.grd v925.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "qf925" ; then
    grdvector qfu925.grd qfv925.grd -J${dPRG} -R${dRANGE} -S2000 -Q0.005/0.1/0.05n0.25 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.0 0.65 0.0 0.5" | psxy -R1/100/1/100 -Jx1.0 -Sv0.005/0.1/0.05 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.5 0.5 3 0.0 0 MC 1000 [g/(m^2*s)]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "850" ; then
    grdbarb u850.grd v850.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "qf850" ; then
    grdvector qfu850.grd qfv850.grd -J${dPRG} -R${dRANGE} -S2000 -Q0.005/0.1/0.05n0.25 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.0 0.65 0.0 0.5" | psxy -R1/100/1/100 -Jx1.0 -Sv0.005/0.1/0.05 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.5 0.5 3 0.0 0 MC 1000 [g/(m^2*s)]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "700" ; then
    grdbarb u700.grd v700.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "500" ; then
    grdbarb u500.grd v500.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "300" ; then
    grdbarb u300.grd v300.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "250" ; then
    grdbarb u250.grd v250.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
elif test ${wind} = "200" ; then
    grdbarb u200.grd v200.grd -J${dPRG} -R${dRANGE} -Q0.1/0.2/120/1 -W1 -G0 -I${vINT}/${vINT} ${gmtcon} >> ${psfile}
    echo " 4.1 0.65 0.0 5" | psxy -R1/100/1/100 -Jx1.0 -Swb0.1/0.2/120/1 -G0 -N ${gmtcon} >> ${psfile}
    echo " 4.0 0.5 3 0.0 0 MC 10 [m/s]" | pstext -R -J -N ${gmtcon} >> ${psfile}
fi

    ymdh=$(/home/unuma/usr/local/bin/utc2jst ${yyyy}${mm}${dd}${hh}00 | cut -c1-10)
    Y=${ymdh:0:4}
    m=${ymdh:4:2}
    M=$(/home/unuma/usr/local/bin/mm2MMM ${m})
    D=${ymdh:6:2}
    H=${ymdh:8:2}

# labels (pstext)
# x     y   size angle font place comment
    cat << EOF | pstext -R1/100/1/100 -Jx1.0 -N ${gmtend} >> ${psfile}
 1.0   5.2    6   0.0   0    ML    JMA MSM ${file}
 4.95  5.2    6   0.0   0    MR    ${H}JST ${D}${M}${Y}
 0.4   0.25   1   0.0   0    ML    .
 5.5   0.25   1   0.0   0    MR    .
 0.4   5.5    1   0.0   0    ML    .
 5.5   5.5    1   0.0   0    MR    .
EOF

done

echo "Now convert ps to png file"
ls *.ps | parallel -j +0 unurast_g {} >& /dev/null 2>&1

wwwdir="/home/unuma/www"
if test ${debug_level} -ge 100 ; then
    echo "DEBUG MODE"
else
    mv press.png qv.png temp.png thetae.png cape.png cin.png lcl.png lfc.png lnb.png td.png ki.png pw.png tt.png ehi.png srh.png ssi.png brn.png qv1000.png hgt???.png temp???.png qv???.png thetae???.png wspd???.png pv???.png qfwind???.png qfdiv???.png wsh.png lsta.png dlfc.png dlnb.png ${wwwdir}/autoplot/jmamsm/
    rm -f Z*bin press.bin prmsl.bin thetae.bin rh.bin temp.bin [uv]10.bin qv.bin cape.bin cin.bin lcl.bin lfc.bin lnb.bin hgt.bin uuu.bin vvv.bin ttt.bin rhh.bin td.bin temp???.bin qv1000.bin qv???.bin thetae???.bin wspd???.bin [uv]1000.bin [uv]???.bin www.bin pv???.bin tt.bin pw.bin ki.bin ehi.bin srh.bin ssi.bin brn.bin qf[uv]???.bin qfwind???.bin qfdiv???.bin hgt???.bin wsh.bin lsta.bin dlfc.bin dlnb.bin
    rm -f press.grd prmsl.grd thetae.grd qv.grd temp.grd [uv]10.grd rh.grd cape.grd cin.grd lcl.grd lfc.grd lnb.grd td.grd temp???.grd qv1000.grd qv???.grd thetae???.grd wspd???.grd [uv]1000.grd [uv]???.grd pv???.grd tt.grd pw.grd ki.grd ehi.grd srh.grd ssi.grd brn.grd qf[uv]???.grd qfwind???.grd qfdiv???.grd hgt???.grd wsh.grd lsta.grd dlfc.grd dlnb.grd
fi

rm -f press.ps prmsl.ps thetae.ps qv.ps temp.ps cape.ps cin.ps lfc.ps lcl.ps lnb.ps td.ps temp???.ps qv1000.ps qv???.ps thetae???.ps wspd???.ps [uv]???.ps pv???.ps pw.ps tt.ps ki.ps ehi.ps srh.ps ssi.ps brn.ps qfwind???.ps qfdiv???.ps hgt???.ps wsh.ps lsta.ps dlfc.ps dlnb.ps
rm -f MSM_S
rm -f MSM_P
rm -f cpalet_*
rm -f .gmt*
