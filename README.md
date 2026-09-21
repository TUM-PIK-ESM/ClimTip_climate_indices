# ClimTip_climate_indices
Code for computation of climate indices from netcdf climate model output

The script is executed to compute indices for climate model simulation output.
It is taylored to the output generated in the ClimTip project. https://www.climate-tipping-points.eu/
The setup, the simulations, and the methods are explained in these papers (and some papers cited therein):
Wood et al.: https://zenodo.org/records/20560921
Hess et al:  
Also see the documentation of the Earth system model output on zenodo, DOI: 10.5281/zenodo.16784934.

Maskfiles (e.g. for masking days fulfilling a criterion) are generated but deleted again automatically.
This shell scipt checks if output files of the climate indices to be computed already exist. In this case, indices are skipped.

This index requires a land-sea mask file: GSL

These indices need a reference simulation to compute percentiles relative to the reference: R95pTOT R99pTOT WSDI TX90p CSDI TN10p TX10p TN90p
We here take 1940-2000 of the historical run. 
Advantage: A sufficiently long period, but with not too much forced trend
Disadvantage: No historical run was done in WRF, hence these indices have not been generated for downscaling_WRF.

Some indices are summary statistics without time resolution. The time aggregation label in these cases is "fx". 
In case of the historical run (a transient simulation), we use 1979-2000 (same time period as used to compare models to ERA5).
For other scenarios, the whole time period is used.


Written for the ClimTip project by Sebastian Bathiany, Technical University of Munich,
with support from Nikhil Kumar, Uppsala University.

Licence: MIT

List of indices:

dict[tas]="K|Near surface temperature"\
dict[tasmin]="K|Daily minimum reference height temperature"\
dict[tasmax]="K|Daily maximum reference height temperature"\
dict[pr]="kg m**-2 s-1|Total precipitation rate"     # downscaling_ML: mm/day,   ERA5: m\
dict[sfcWind]="m s-1|Daily-mean near-surface wind speed"\
dict[rsds]="W m-2|Surface downwelling shortwave radiation"\
dict[rlds]="W m-2|Surface downwelling longwave radiation"\
dict[hurs]="%|Near-surface relative humidity"\
dict[Rx1day]="mm|Maximum 1-day precipitation"\
dict[Rx5day]="mm|Maximum consecutive 5-day precipitation"\
dict[R95pTOT]="mm|Total PRCP when RR > 95p"\
dict[R99pTOT]="mm|Total PRCP when RR > 99p"\
dict[DD]="days|Dry days"\
dict[R10mm]="days|Count of days when PRCP ≥ 10 mm"\
dict[R20mm]="days|Count of days when PRCP ≥ 20 mm"\
dict[CDD]="days|Maximum length of dry spell"\
dict[CWD]="days|Maximum length of wet spell"\
dict[TXx]="°C|Maximum of daily maximum temperature"\
dict[TNx]="°C|Maximum of daily minimum temperature"\
dict[TXn]="°C|Minimum of daily maximum temperature"\
dict[TNn]="°C|Minimum of daily minimum temperature"\
dict[HD]="days|Hot days"\
dict[SU]="days|Summer days"\
dict[TR]="days|Tropical nights"\
dict[FD]="days|Frost days"\
dict[ID]="days|Icing days"\
dict[TX10p]="%|Percentage of cool days"\
dict[TN10p]="%|Percentage of cold nights"\
dict[TX90p]="%|Percentage of warm days"\
dict[TN90p]="%|Percentage of warm nights"\
dict[DTR]="°C|Diurnal temperature range"\
dict[WSDI]="days|Warm spell duration index"\
dict[CSDI]="days|Cold spell duration index"\
dict[GSL]="days|Growing season length"\
dict[tasstd]="°C|Stdev of annual temperature"\
dict[prstd]="mm|Stdev of annual precipitation"\
dict[HDD]="°C|Heating degree days"\
dict[CoDD]="°C|Cooling degree days"
