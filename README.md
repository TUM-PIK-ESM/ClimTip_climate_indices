# ClimTip_climate_indices
Code for computation of climate indices from netcdf climate model output.

The script is executed to compute indices for climate model simulation output. See the dictionary of indices below, as used in the actual code (ksh shell script). \
The shell script relies on climate data operators (cdo's) and is taylored to the output generated in the ClimTip project. https://www.climate-tipping-points.eu/ \
Also see the documentation of the Earth system model output on zenodo, DOI: 10.5281/zenodo.16784934.

The ClimTip simulations contribute to the TIPMIP model intercomparison; see:
Jones et al., 2026: https://gmd.copernicus.org/articles/19/6941/2026/ \
Winkelmann et al., https://egusphere.copernicus.org/preprints/2025/egusphere-2025-1899/ \
Swingedouw et al., https://egusphere.copernicus.org/preprints/2026/egusphere-2026-1698/

The ClimTip specific setup, the simulations, and the methods are explained in these papers (and some papers cited therein): \
Wood et al. (CO2 forcing construction; called "P-method" in this paper): https://zenodo.org/records/20560921 \
Hess et al. (bias correction and machine learning-based downscaling): https://doi.org/10.48550/arXiv.2609.23149

For technical information on the code, see compute_climate_indices.ksh

The code was written for the ClimTip project by Sebastian Bathiany, Technical University of Munich,
with support from Nikhil Kumar, Uppsala University.

Licence: MIT

DOI of version 1.0: DOI: 10.5281/zenodo.22913257 

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
