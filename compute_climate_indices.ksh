#!/bin/ksh

### This script is executed to compute indices for climate model simulation output.
### See README.md for more information.

## maskfiles (e.g. for masking days fulfilling a criterion) are generated but deleted again automatically.
## This shell scipt checks if output files of the climate indices to be computed already exist. In this case, indices are skipped.

## This index requires a land-sea mask file: GSL

## These indices need a reference simulation to compute percentiles relative to the reference: R95pTOT R99pTOT WSDI TX90p CSDI TN10p TX10p TN90p
## We here take 1940-2000 of the historical run. 
## Advantage: A sufficiently long period, but with not too much forced trend
## Disadvantage: No historical run was done in WRF, hence these indices have not been generated for downscaling_WRF (dynamical downscaling).

## Some indices are summary statistics without time resolution. The time aggregation label in these cases is "fx". 
## In case of the historical run (a transient simulation), we use 1979-2000 (same time period as used to compare models to ERA5).
## For other scenarios, the whole time period is used.


## Written for the ClimTip project by Sebastian Bathiany, Technical University of Munich,
## with support from Nikhil Kumar, Uppsala University.

## Licence: MIT


######### edit here:
indices='Rx1day Rx5day R95pTOT R99pTOT DD R10mm R20mm CDD CWD TXx TNx TXn TNn HD SU TR FD ID TX10p TN10p TX90p TN90p DTR WSDI CSDI GSL tasstd prstd HDD CoDD'

models='MPI-ESM1-2-HR HadGEM3-GC31-MM CESM1-CAM5'
#models='MPI-ESM1-2-HR CESM1-CAM5' # WRF
#models='MPI-ESM1-2-HR'
#models='HadGEM3-GC31-MM'
#models='CESM1-CAM5'

scenarios='historical piControl stableT_2K stableT_2K_AMOC stableT_2K_ARF' #ESM, ML
#scenarios='piControl stableT_2K stableT_2K_AMOC stableT_2K_ARF' # WRF


#################################
K2C="273.15"


## lookup table for units

typeset -A dict   # unit, long_name

dict[tas]="K|Near surface temperature"
dict[tasmin]="K|Daily minimum reference height temperature"
dict[tasmax]="K|Daily maximum reference height temperature"
dict[pr]="kg m**-2 s-1|Total precipitation rate"     # downscaling_ML: mm/day,   ERA5: m
dict[sfcWind]="m s-1|Daily-mean near-surface wind speed"
dict[rsds]="W m-2|Surface downwelling shortwave radiation"
dict[rlds]="W m-2|Surface downwelling longwave radiation"
dict[hurs]="%|Near-surface relative humidity"
dict[Rx1day]="mm|Maximum 1-day precipitation"
dict[Rx5day]="mm|Maximum consecutive 5-day precipitation"
dict[R95pTOT]="mm|Total PRCP when RR > 95p"
dict[R99pTOT]="mm|Total PRCP when RR > 99p"
dict[DD]="days|Dry days"
dict[R10mm]="days|Count of days when PRCP ≥ 10 mm"
dict[R20mm]="days|Count of days when PRCP ≥ 20 mm"
dict[CDD]="days|Maximum length of dry spell"
dict[CWD]="days|Maximum length of wet spell"
dict[TXx]="°C|Maximum of daily maximum temperature"
dict[TNx]="°C|Maximum of daily minimum temperature"
dict[TXn]="°C|Minimum of daily maximum temperature"
dict[TNn]="°C|Minimum of daily minimum temperature"
dict[HD]="days|Hot days"
dict[SU]="days|Summer days"
dict[TR]="days|Tropical nights"
dict[FD]="days|Frost days"
dict[ID]="days|Icing days"
dict[TX10p]="%|Percentage of cool days"
dict[TN10p]="%|Percentage of cold nights"
dict[TX90p]="%|Percentage of warm days"
dict[TN90p]="%|Percentage of warm nights"
dict[DTR]="°C|Diurnal temperature range"
dict[WSDI]="days|Warm spell duration index"
dict[CSDI]="days|Cold spell duration index"
dict[GSL]="days|Growing season length"
dict[tasstd]="°C|Stdev of annual temperature"
dict[prstd]="mm|Stdev of annual precipitation"
dict[HDD]="°C|Heating degree days"
dict[CoDD]="°C|Cooling degree days"

#dict[DSL]="days|Dry season length"


for datatype in ${datatypes}; do

  for model in ${models}; do

    if [[ ${model} == 'HadGEM3-GC31-MM' ]]; then 
      time_span_historical='18500101-20141230'
      if [[ ${datatype} == "downscaling_MLv2" ]]; then
        time_span_historical='19150101-20141230'
      fi

    elif [[ ${model} == 'MPI-ESM1-2-HR' ]]; then 
      time_span_historical='18500101-20141231'
      if [[ ${datatype} == "downscaling_MLv2" ]]; then
        time_span_historical='19150101-20141231'
      fi
    
    elif [[ ${model} == 'CESM1-CAM5' ]]; then
      time_span_historical='18500101-20051231'
      if [[ ${datatype} == "downscaling_MLv2" ]]; then
        time_span_historical='19060101-20051231'
      fi
    
    fi

    ## Some indices require computing percentiles from a reference climate.
    ## As this reference, we use the historical simulation of the model at hand, years 1940-2000
    ref_period_ini='1940'
    ref_period_fin='2000'
    ref_scenario='historical'
    ref_time_span=${time_span_historical} # only used to identify the right file; the reference time period is defined by ref_period_ini/fin.
    ref_realisation="r1i1p1f1"
    if [[ ${model} == 'HadGEM3-GC31-MM' ]]; then
      ref_realisation="r1i1p1f3"
    fi

    for scen in ${scenarios}; do

      if [[ ${datatype} == "ESM_output" ]]; then
        gridlist="gn"
        prscale=86400 # seconds per day
      elif [[ ${datatype} == "downscaling_MLv2" ]]; then
        gridlist="${datatype}"
        prscale=1 # already in mm/day
      elif [[ ${datatype} == "ESM_biascorrected" ]]; then
        gridlist="gn_biascorrected"
        prscale=1 # already in mm/day
      elif [[ ${datatype} == "downscaling_WRF" ]]; then       
        if [[ ${scen} == "stableT_2K_ARF" ]]; then
          gridlist="gn_downscaling_WRF_Amazon"
        else
          gridlist="gn_downscaling_WRF_Africa gn_downscaling_WRF_Amazon gn_downscaling_WRF_EAsia gn_downscaling_WRF_Europe gn_downscaling_WRF_India"
        fi
        prscale=1 # already in mm/day
      else
        exit
      fi


      if [[ -d /work/bm1404/ClimTip_data/${datatype}/${model}/${scen} ]]; then  # model and scenario exist
        cd /work/bm1404/ClimTip_data/${datatype}/${model}/${scen}

        ## realisations to be computed, and time spans in file name; both depend on the model and scenario
        if [[ ${model} == 'HadGEM3-GC31-MM' && ${scen} == 'historical' ]]; then 
            realisations="r1i1p1f3"
            time_span=${time_span_historical}
        elif [[ ${model} == 'HadGEM3-GC31-MM' && ! ( ${scen} == 'historical' ) ]]; then
            realisations='r1i1p1f1'
            time_span='19070101-20061230'

        elif [[ ${model} == 'MPI-ESM1-2-HR' && ${scen} == 'historical' ]]; then 
            realisations='r1i1p1f1' # r2i1p1f1 r3i1p1f1 r4i1p1f1 r5i1p1f1 r6i1p1f1 r7i1p1f1 r8i1p1f1 r9i1p1f1 r10i1p1f1'
            time_span=${time_span_historical}
        elif [[ ${model} == 'MPI-ESM1-2-HR'  && ! ( ${scen} == 'historical' ) ]]; then
          realisations='r1i1p1f1'
          time_span='19350101-20341231'
          if [[ ${datatype} == "downscaling_WRF" ]]; then
            time_span='20020101-20211231'
          fi
        elif [[ ${model} == 'CESM1-CAM5'  && ${scen} == 'historical' ]]; then
          realisations='r1i1p1f1'
          time_span=${time_span_historical}
        elif [[ ${model} == 'CESM1-CAM5'  && ! ( ${scen} == 'historical' ) ]]; then
          realisations='r1i1p1f1'
          time_span='05650101-06641231'
          if [[ ${datatype} == "downscaling_WRF" ]]; then
            time_span='06320101-06511231' # to be repaired with leading 0
          fi

        else
          echo "time span and realisations not defined - abort"
          exit
        fi

        for rea in ${realisations}; do
          for grid in ${gridlist}; do

            pr="pr_day_${model}_${scen}_${rea}_${grid}_${time_span}.nc"
            tas="tas_day_${model}_${scen}_${rea}_${grid}_${time_span}.nc"
            tasmin="tasmin_day_${model}_${scen}_${rea}_${grid}_${time_span}.nc"
            tasmax="tasmax_day_${model}_${scen}_${rea}_${grid}_${time_span}.nc"

            for index in ${indices}; do
              echo ""
              echo "${datatype}, ${model}, ${scen}, ${rea}, ${grid}, ${index}"

              #var_orig_file="${var_orig}_day_${model}_${scen}_${rea}_${grid}_${time_span}.nc"

              ### some indices have several aggregation periods, some don't:
              aggregation_periods="year"
              time_span_indexfile=${time_span}
              case "$index" in
                Rx1day|Rx5day|TXx|TNx|TXn|TNn)
                  aggregation_periods="year mon"
                  ;;
                TX10p|TN10p|TX90p|TN90p|tasstd|prstd)
                  aggregation_periods="fx"
                  if [[ ${scen} == "historical" ]]; then
                    if [[ ${model} == 'HadGEM3-GC31-MM' ]]; then
                      time_span_indexfile="19790101-20001230"
                    else
                      time_span_indexfile="19790101-20001231"
                    fi
                  fi
                  ;;                
                *)
                ;;
              esac

              for aggregation_period in ${aggregation_periods}; do

                indexfile="${index}_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                if [[ ! -f ${indexfile} ]]; then

                  ### 1. compute mask for indices that need it, and keep it until loop over aggregation time is closed.
                  maskfile="${index}_mask_${model}_${scen}_${rea}_${grid}.nc"
                  if [[ ! -f ${maskfile} ]]; then
                    percentiles=0
                    case "$index" in
                      R10mm)
                        cdo gec,10 -mulc,${prscale} ${pr} ${maskfile}
                        ;;
                      R20mm)
                        cdo gec,20 -mulc,${prscale} ${pr} ${maskfile}
                        ;;                  
                      R95pTOT)
                        ## note: cdo documentation of eca_r95ptot is so confusing (and seems to differ from common definitions) that we don't use it here!
                        ## https://code.mpimet.mpg.de/boards/1/topics/6182
                        cdo selyear,${ref_period_ini}/${ref_period_fin} -setrtomiss,-999,1 -mulc,${prscale} /work/bm1404/ClimTip_data/${datatype}/${model}/${ref_scenario}/pr_day_${model}_${ref_scenario}_${ref_realisation}_${grid}_${ref_time_span}.nc reference_climate_${index}.nc
                        cdo timpctl,95 reference_climate_${index}.nc -timmin reference_climate_${index}.nc -timmax reference_climate_${index}.nc ${maskfile}
                        rm reference_climate_${index}.nc
                        percentiles=1
                        ;;
                      R99pTOT)
                        cdo selyear,${ref_period_ini}/${ref_period_fin} -setrtomiss,-999,1 -mulc,${prscale} /work/bm1404/ClimTip_data/${datatype}/${model}/${ref_scenario}/pr_day_${model}_${ref_scenario}_${ref_realisation}_${grid}_${ref_time_span}.nc reference_climate_${index}.nc
                        cdo timpctl,99 reference_climate_${index}.nc -timmin reference_climate_${index}.nc -timmax reference_climate_${index}.nc ${maskfile}
                        rm reference_climate_${index}.nc
                        percentiles=1
                        ;;
                      DD)
                        cdo ltc,1 -mulc,${prscale} ${pr} ${maskfile}
                        ;;
                      HD)
                        cdo gtc,30 -subc,${K2C} ${tasmax} ${maskfile}
                        ;;
                      SU)
                        cdo gtc,25 -subc,${K2C} ${tasmax} ${maskfile}
                        ;;
                      TR)
                        cdo gtc,20 -subc,${K2C} ${tasmin} ${maskfile}
                        ;;
                      FD)
                        cdo ltc,0 -subc,${K2C} ${tasmin} ${maskfile}
                        ;;
                      ID)
                        cdo ltc,0 -subc,${K2C} ${tasmax} ${maskfile}
                        ;;
                      DTR)
                        cdo sub ${tasmax} ${tasmin} ${maskfile}  # not a mask in this case, but daily file
                        ;;
                      WSDI | TX90p | CSDI | TN10p | TX10p | TN90p)
                        case "$index" in
                          WSDI | TX90p | TX10p)
                            var=tasmax
                            ;;                      
                          CSDI | TN10p | TN90p)
                            var=tasmin
                            ;;
                          *)
                          ;;
                        esac
                        case "$index" in
                          WSDI | TX90p | TN90p)
                            perc=90
                            ;;
                          CSDI | TX10p | TN10p)
                            perc=10
                            ;;
                          *)
                          ;;
                        esac

                        ### problem: The command is too memory heavy for hires grid. Need to split dataset up.

                        cdo selyear,${ref_period_ini}/${ref_period_fin} /work/bm1404/ClimTip_data/${datatype}/${model}/${ref_scenario}/${var}_day_${model}_${ref_scenario}_${ref_realisation}_${grid}_${ref_time_span}.nc reference_climate_${index}.nc
                        cdo distgrid,8 reference_climate_${index}.nc reference_climate_${index}_
                        mergefilelist=""
                        for tile in 0 1 2 3 4 5 6 7; do                      
                          cdo -L settaxis,2000-01-01,00:00:00,1day -ydrunmin,5,rm=cmin,5 reference_climate_${index}_0000${tile}.nc reference_climate_${index}_${tile}_ydmin.nc
                          cdo -L settaxis,2000-01-01,00:00:00,1day -ydrunmax,5,rm=cmax,5 reference_climate_${index}_0000${tile}.nc reference_climate_${index}_${tile}_ydmax.nc
                          cdo -b F32 -z zip ydrunpctl,${perc},5,pm=r4,rm=c reference_climate_${index}_0000${tile}.nc reference_climate_${index}_${tile}_ydmin.nc reference_climate_${index}_${tile}_ydmax.nc ${maskfile}_${tile}
                          mergefilelist="${mergefilelist} ${maskfile}_${tile}"
                          rm reference_climate_${index}_${tile}_ydmin.nc reference_climate_${index}_${tile}_ydmax.nc
                          rm reference_climate_${index}_0000${tile}.nc
                        done

                        cdo settaxis,2000-01-01,00:00:00,1day -collgrid ${mergefilelist} ${maskfile}
                        rm ${mergefilelist} reference_climate_${index}.nc
                        percentiles=1
                        ;;
                      *)
                      ;;
                    esac # end case

                    if [[ ${percentiles} == 1 && ${datatype} == "ESM_output" && ${model} == "MPI-ESM1-2-HR" && ${ref_scenario} == "historical" && ! ${scen} == "historical" ]]; then ### historical run in MPI model has different grid description
                      cdo invertlat ${maskfile} ${maskfile}_corrected
                      mv ${maskfile}_corrected ${maskfile}
                    fi
                  fi




                  ### 2. compute index (directly or from mask file)
                  case "$index" in
                    
                    Rx1day)
                      cdo ${aggregation_period}max -mulc,${prscale} ${pr} ${indexfile}
                      ;;

                    Rx5day)
                      if [[ ${aggregation_period} == "mon" ]]; then
                        freq="month"
                      else
                        freq=${aggregation_period}
                      fi
                      secondfile="R50mm5day_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo eca_rx5day,50,freq=${freq} -runsum,5 -mulc,${prscale} ${pr} results.nc
                      cdo selcode,-1 results.nc ${indexfile}
                      cdo selcode,-2 results.nc ${secondfile}

                      ### metadata for R50mm5day
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},R50mm5day ${secondfile}
                      cdo setunit,"events" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"R50mm5day",o,c,"Number of 5-day heavy precipitation periods per time period (threshold: 50 mm)" ${secondfile}

                      rm results.nc
                      ;;

                    R95pTOT|R99pTOT)
                      ## note: cdo documentation of eca_r95ptot is so misleading that we don't use it here!
                      cdo -setrtomiss,-999,1 -mulc,${prscale} ${pr} wetdayprec.nc
                      cdo yearsum -mul -ge wetdayprec.nc ${maskfile} wetdayprec.nc ${indexfile}  
                      rm wetdayprec.nc
                      ;;

                    DD|R10mm|R20mm|HD|SU|TR|FD|ID)
                      cdo ${aggregation_period}sum ${maskfile} ${indexfile}
                      ;;

                    CDD)
                      secondfile="CDD5day_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo etccdi_cdd -mulc,${prscale} ${pr} ${indexfile}_etccdi
                      cdo selcode,-1 ${indexfile}_etccdi ${indexfile}
                      cdo selcode,-2 ${indexfile}_etccdi ${secondfile}

                      ### metadata for CDD5day
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},CDD5day ${secondfile}
                      cdo setunit,"events" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"CDD5day",o,c,"Number of events of more than 5 consecutive dry days" ${secondfile}

                      rm ${indexfile}_etccdi
                      ;;

                    CWD)
                      secondfile="CWD5day_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo etccdi_cwd -mulc,${prscale} ${pr} ${indexfile}_etccdi
                      cdo selcode,-1 ${indexfile}_etccdi ${indexfile}
                      cdo selcode,-2 ${indexfile}_etccdi ${secondfile}

                      ### metadata for CWD5day
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},CWD5day ${secondfile}
                      cdo setunit,"events" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"CWD5day",o,c,"Number of events of more than 5 consecutive wet days" ${secondfile}

                      rm ${indexfile}_etccdi
                      ;;

                    TXx)
                      cdo ${aggregation_period}max -subc,${K2C} ${tasmax} ${indexfile}
                      ;;

                    TNx)
                      cdo ${aggregation_period}max -subc,${K2C} ${tasmin} ${indexfile}
                      ;;

                    TXn)
                      cdo ${aggregation_period}min -subc,${K2C} ${tasmax} ${indexfile}
                      ;;

                    TNn)
                      cdo ${aggregation_period}min -subc,${K2C} ${tasmin} ${indexfile}
                      ;;

                    TX10p)
                      # Note: In practice, CDO command eca_tx10p:
                      # does not enforce that the variable is really tasmax
                      # and does not check that the threshold is truly a 10th percentile. It only applies a "-le" command per calendar day! 

                      #cdo mulc,100 -yearmean -le ${tasmax} ${maskfile} ${indexfile} 
                      if [[ ${scen} == "historical" ]]; then
                        cdo selyear,1979/2000 ${tasmax} ${index}_tasmax_1979-2000.nc
                        cdo eca_tx10p ${index}_tasmax_1979-2000.nc ${maskfile} ${indexfile} 
                        rm ${index}_tasmax_1979-2000.nc
                      else
                        cdo eca_tx10p ${tasmax} ${maskfile} ${indexfile} 
                      fi
                      ;;
                    TX90p)
                      #cdo mulc,100 -yearmean -ge ${tasmax} ${maskfile} ${indexfile}
                      if [[ ${scen} == "historical" ]]; then
                        cdo selyear,1979/2000 ${tasmax} ${index}_tasmax_1979-2000.nc
                        cdo eca_tx90p ${index}_tasmax_1979-2000.nc ${maskfile} ${indexfile}
                        rm ${index}_tasmax_1979-2000.nc
                      else
                        cdo eca_tx90p ${tasmax} ${maskfile} ${indexfile}
                      fi
                      ;;
                    TN10p)
                      #cdo mulc,100 -yearmean -le ${tasmin} ${maskfile} ${indexfile}
                      if [[ ${scen} == "historical" ]]; then

                        cdo selyear,1979/2000 ${tasmin} ${index}_tasmin_1979-2000.nc
                        cdo eca_tn10p ${index}_tasmin_1979-2000.nc ${maskfile} ${indexfile}
                        rm ${index}_tasmin_1979-2000.nc
                      else
                        cdo eca_tn10p ${tasmin} ${maskfile} ${indexfile}
                      fi
                      ;;
                    TN90p)
                      #cdo mulc,100 -yearmean -ge ${tasmin} ${maskfile} ${indexfile}
                      if [[ ${scen} == "historical" ]]; then
                        cdo selyear,1979/2000 ${tasmin} ${index}_tasmin_1979-2000.nc
                        cdo eca_tn90p ${index}_tasmin_1979-2000.nc ${maskfile} ${indexfile}
                        rm ${index}_tasmin_1979-2000.nc
                      else
                        cdo eca_tn90p ${tasmin} ${maskfile} ${indexfile}
                      fi
                      ;;

                    DTR)
                      cdo ${aggregation_period}mean ${maskfile} ${indexfile}
                      ;;

                    WSDI)
                      secondfile="WSDI6day_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo etccdi_wsdi ${tasmax} ${maskfile} ${indexfile}_all
                      cdo selvar,wsdiETCCDI ${indexfile}_all ${indexfile}
                      cdo selvar,warm_spell_periods_per_time_period ${indexfile}_all ${secondfile}

                      ### metadata for WSDI6day (the second output file)
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},WSDI6day ${secondfile}
                      cdo setunit,"events" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"WSDI6day",o,c,"Number of events with 6 or more consecutive days with TX > 90p" ${secondfile}

                      rm ${indexfile}_all
                      ;;
                    
                    CSDI)
                      secondfile="CSDI6day_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo etccdi_csdi ${tasmin} ${maskfile} ${indexfile}_all
                      cdo selvar,csdiETCCDI ${indexfile}_all ${indexfile}
                      cdo selvar,cold_spell_periods_per_time_period ${indexfile}_all ${secondfile}

                      ### metadata for CSDI6day (the second output file)
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},CSDI6day ${secondfile}
                      cdo setunit,"events" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"CSDI6day",o,c,"Number of events with 6 or more consecutive days with TN < 10p" ${secondfile}

                      rm ${indexfile}_all
                      ;;

                    GSL)
                      if [[ ${datatype} == "ESM_output" ]]; then
                        lsm=/work/bm1404/ClimTip_data/scripts/lsm_${model}_gn.nc
                        if [[ ${model} == "MPI-ESM1-2-HR" && ${scen} == "historical" ]]; then
                          lsm=/work/bm1404/ClimTip_data/scripts/lsm_${model}_gn_historical.nc
                        fi
                      elif [[ ${datatype} == "ESM_biascorrected" ]]; then
                        lsm=/work/bm1404/ClimTip_data/scripts/lsm_${model}_gn.nc
                      elif [[ ${datatype} == "downscaling_MLv2" ]]; then
                        lsm=/work/bm1404/ClimTip_data/scripts/land_sea_mask_ECMWF-ERA5_observation.nc
                      fi

                      cdo eca_gsl ${tas} ${lsm} ${indexfile}_full

                      ## remove first and last year because output is meaningless (cannot detect in year 1 when growing season has started)
                      years=$(cdo -s showyear "${indexfile}_full")
                      set -- $years
                      first_year=$1
                      last_year=${years: -4}                          # keep last 4 digits
                      first_year=`echo ${first_year} | sed 's/ //g'`  # remove blanks
                      last_year=`echo ${last_year} | sed 's/ //g'`    # remove blanks
                      cdo delete,year=${first_year} -delete,year=${last_year} ${indexfile}_full ${indexfile}_all
                      rm -f ${indexfile}_full

                      ## apply lsm  (eca_gsl command above does not mask properly; it just ignores ocean points)
                      cdo ifthen ${lsm} ${indexfile}_all ${indexfile}_all_masked
                      cdo setmissval,nan ${indexfile}_all_masked ${indexfile}_all

                      ### sometimes, the dimensions have changed, perhaps because of different dimension names in the different files (and the lsm file). Repair this here:
                      if [[ ${datatype} == "downscaling_MLv2" ]]; then   # not sure we need the if clause actually
                        ncrename -d .x,longitude -d .y,latitude ${indexfile}_all_masked 2>/dev/null || true
                        ncrename -v .lon,longitude -v .lat,latitude ${indexfile}_all_masked 2>/dev/null || true                 
                        mv ${indexfile}_all_masked ${indexfile}_all
                      fi
                      
                      secondfile="GSS_${aggregation_period}_${model}_${scen}_${rea}_${grid}_${time_span_indexfile}.nc"
                      cdo selvar,thermal_growing_season_length ${indexfile}_all ${indexfile}
                      cdo selvar,day_of_year_of_growing_season_start ${indexfile}_all ${secondfile}

                      ### set varname GSS
                      old_name=`cdo -s showname ${secondfile} | sed 's/ //g'`
                      ncrename -v ${old_name},GSS ${secondfile}

                      ## set unit and longname GSS
                      cdo setunit,"day of year" ${secondfile} ${secondfile}_unit
                      mv ${secondfile}_unit ${secondfile}
                      ncatted -O -a long_name,"GSS",o,c,"Start of growing season" ${secondfile}

                      rm ${indexfile}_all ${indexfile}_all_masked 
                      ;; 

                    tasstd)
                      if [[ ${scen} == "historical" ]]; then
                        cdo selyear,1979/2000 ${tas} ${index}_tas_1979-2000.nc
                        cdo timstd -yearmean ${index}_tas_1979-2000.nc ${indexfile}
                        rm ${index}_tas_1979-2000.nc
                      else
                        cdo timstd -yearmean ${tas} ${indexfile}
                      fi
                      ;;
                      
                    prstd)
                      if [[ ${scen} == "historical" ]]; then
                        cdo selyear,1979/2000 ${pr} ${index}_pr_1979-2000.nc
                        cdo mulc,${prscale} -timstd -yearsum ${index}_pr_1979-2000.nc ${indexfile}
                        rm ${index}_pr_1979-2000.nc            
                      else
                        cdo mulc,${prscale} -timstd -yearsum ${pr} ${indexfile}
                      fi
                      ;;

                    HDD)
                      # convert to °C, then subtract baseline value (15.5°C). Everything below that baseline counts.
                      # Hence change sign and set all negative values to 0.
                      cdo -subc,15.5 -subc,${K2C} ${tas} ${index}_shifted.nc
                      cdo setrtoc,-999,0,0 -mulc,-1 ${index}_shifted.nc ${index}_anomalies.nc
                      cdo yearsum ${index}_anomalies.nc ${indexfile}
                      rm ${index}_anomalies.nc ${index}_shifted.nc
                      ;;
                    CoDD)
                      cdo -subc,22 -subc,${K2C} ${tas} ${index}_shifted.nc
                      cdo setrtoc,-999,0,0 ${index}_shifted.nc ${index}_anomalies.nc
                      cdo yearsum ${index}_anomalies.nc ${indexfile}
                      rm ${index}_anomalies.nc ${index}_shifted.nc
                      ;;
                      
                    #DSL)
                    #  cdo monsum ${pr} pr_monsum.nc 
                    #  cdo ltc,${maskfile} pr_monsum.nc drymonths_mask.nc
                    #  cdo yearsum drymonths_mask.nc ${indexfile}
                    #  rm pr_monsum.nc drymonths_mask.nc
                    #  ;;

                    *)
                    ;;                
                  esac # case

                  ##### metadata for all called indices, except "secondfiles" that have been generated on the side

                  ### set varname
                  old_name=`cdo -s showname ${indexfile} | sed 's/ //g'`
                  ncrename -v ${old_name},${index} ${indexfile}

                  #### set unit and longname

                  record=${dict[${index}]:-"unknown|unknown"}
                  #echo ${record}
                  #exit
                  IFS='|' read unit long_name <<EOF
                    $record
EOF

                  unit="${unit#"${unit%%[![:space:]]*}"}"   # remove leading whitespace
                  unit="${unit%"${unit##*[![:space:]]}"}"   # remove trailing whitespace
                  long_name="${long_name#"${long_name%%[![:space:]]*}"}"
                  long_name="${long_name%"${long_name##*[![:space:]]}"}"

                  #### set the unit:
                  unit_file=`cdo showunit ${indexfile}`
                  unit_file="${unit_file#"${unit_file%%[![:space:]]*}"}"   # remove leading whitespace
                  unit_file="${unit_file%"${unit_file##*[![:space:]]}"}"   # remove trailing whitespace
                  if [[ ! "${unit_file}" == "${unit}" ]]; then
                    #echo "${model}, ${scen}, ${rea}, ${aggregation_period}: ${unit_file} (${unit} was expected)"
                    cdo setunit,"${unit}" ${indexfile} ${indexfile}_unit
                    mv ${indexfile}_unit ${indexfile}
                  fi

                  ## set the long_name:
                  long_name_file=$(ncks -m -v ${index} ${indexfile} | sed -n "s/.*${index}:long_name = \"\(.*\)\".*/\1/p")
                  if [[ ! "${long_name_file}" == "${long_name}" ]]; then
                    #echo "${model}, ${scen}, ${rea}, ${aggregation_period}: ${long_name_file} (${long_name} was expected)"
                    ncatted -O -a long_name,${index},o,c,"${long_name}" ${indexfile}
                  fi

                
                
                fi # file exists
              done # aggregation_period
              rm -f ${maskfile}

            done # index
          done # grid (domain in case of WRF)
        done # rea
      fi # model and scenario exist
    done # scenario
  done # model
done #datatypes

echo ""
echo "exit"

exit