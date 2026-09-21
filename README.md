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