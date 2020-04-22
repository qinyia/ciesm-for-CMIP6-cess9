import cmor
from netCDF4 import Dataset
import pandas as pd
import numpy as np
import subprocess
import os
from pandas import DataFrame, read_csv

#------------------ qinyi
cmor.setup(
	# inpath has to point to the CMOR 
	# tables path (CMIP6, input4MIPs or otherwise)
	inpath='/GPFS/cess9/qinyi/CMOR3/TestTables',
#	netcdf_file_action=cmor.CMOR_REPLACE_4
	netcdf_file_action=cmor.CMOR_APPEND_4
)

cmor.dataset_json("./CMOR_CIESM_atm_historical_601.json")    
#cmor.dataset_json("./CMOR_test_CIESM.json")
  
# Loading this test table overwrites the normal CF checks on valid variable values.
# This is perfect for testing but shouldn't be done when writing real data.
table='CMIP6_Amon.json'
cmor.load_table(table)

casename=["B20TRC5_g16_acc_nochem_4"]
dirs=["./"]
int_year=[1850]
end_year=[2014]
int_mon=[1]
end_mon=[12]
year=range(int_year[0],end_year[0]+1)
mon=range(int_mon[0],end_mon[0]+1)

cutyear=0

#ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[0]+'.cam.h0.'+str(year[0])+'-'+str("%02d" % mon[0])+'_plev19.nc'
ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[0]+"/FillValue/"+casename[0]+'.cam.h0.'+str("%04d" % year[0])+'-'+str("%02d" % mon[0])+'_plev19.nc_FillValue.nc'

print(ncfile)
fnc=Dataset(ncfile,'r')
vars=fnc.variables.keys()

# get coordinates
time=fnc.variables['time']
ntime=len(time)
print(ntime)

time_bnds=fnc.variables['time_bnds']

lat=fnc.variables['lat']
nlat=len(lat)
lon=fnc.variables['lon']
nlon=len(lon)
plev=fnc.variables['plev']
nplev=len(plev)

lev=fnc.variables['lev']
alev=[]
alev = lev[:]/max(lev[:])
nalev=len(alev)

ilev=fnc.variables['ilev']
nilev=len(ilev)

hyam=fnc.variables['hyam']
nhyam=len(hyam)
hyai=fnc.variables['hyai']
nhyai=len(hyai)
hybm=fnc.variables['hybm']
nhybm=len(hybm)
hybi=fnc.variables['hybi']
nhybi=len(hybi)


# create lat_bnds
bnds=2
lat_bnds=np.zeros((len(lat),bnds),dtype=np.float64)
lat_diff=0.5*(lat[1]-lat[0])
for ilat in range(nlat-1):
	lat_bnds[ilat,1]=lat[ilat]+lat_diff
	lat_bnds[ilat+1,0]=lat_bnds[ilat,1] 
	# this above command is very critical! it ensures the following requirement for CF convention:
	# > If adjacent intervals are contiguous, the shared endpoint must be represented indentically in
	# > each instance where it occurs in the boundary variable. For example, if the intervals that
	# > contain grid points lat(i) and lat(i+1) are contiguous, then latbnd(i+1,0) = latbnd(i,1).

lat_bnds[0,0]=lat[0]
lat_bnds[nlat-1,1]=lat[nlat-1]

## for check
#for ilat in range(len(lat)):
#	print(lat_bnds[ilat,0],lat_bnds[ilat,1],lat[ilat])

# create lon_bnds
lon_bnds=np.zeros((len(lon),bnds),dtype=np.float64)
lon_diff=0.5*(lon[1]-lon[0])
for ilon in range(len(lon)):
	lon_bnds[ilon,0]=lon[ilon]-lon_diff
	lon_bnds[ilon,1]=lon[ilon]+lon_diff
#lon_bnds[len(lon)-1,1]=lon[len(lon)-1]
#lon_bnds[0,0]=lon[0]

# create plev_bnds
plev_bnds=np.zeros((len(plev),bnds),dtype=np.float64)
for iplev in range(0,len(plev)-1):
	plev_diff=0.5*(plev[iplev+1]-plev[iplev])
	plev_bnds[iplev,1]=plev[iplev]+plev_diff
	plev_bnds[iplev+1,0]=plev_bnds[iplev,1] 

plev_bnds[0,0]=plev[0]-0.2*(plev[2]-plev[1])
plev_bnds[nplev-1,1]=plev[nplev-1]+0.2*(plev[nplev-1]-plev[nplev-2])

## for check
#for iplev in range(len(plev)):
#	print(plev_bnds[iplev,0],plev_bnds[iplev,1],plev[iplev])

# create alev_bnds
alev_bnds=np.zeros((len(alev),bnds),dtype=np.float64)
for ialev in range(0,len(alev)-1):
	alev_diff=0.5*(alev[ialev+1]-alev[ialev])
	alev_bnds[ialev,1]=alev[ialev]+alev_diff
	alev_bnds[ialev+1,0]=alev_bnds[ialev,1] 

alev_bnds[0,0]=alev[0]-0.2*(alev[2]-alev[1])
alev_bnds[nalev-1,1]=alev[nalev-1]#+0.2*(alev[nalev-1]-alev[nalev-2])

## for check
#for ialev in range(len(alev)):
#	print(alev_bnds[ialev,0],alev_bnds[ialev,1],alev[ialev])

# create hyam_bnds
hyam_bnds=np.zeros((len(hyam),bnds),dtype=np.float64)

hyam_bnds[0,0]=hyam[0]-0.2*(hyam[1]-hyam[0])
hyam_bnds[0,1]=hyam[0]+0.5*(hyam[1]-hyam[0])
hyam_bnds[1,0]=hyam_bnds[0,1]

for ihyam in range(1,len(hyam)-1):
	if (hyam[ihyam+1] < hyam[ihyam]) & (hyam[ihyam-1] < hyam[ihyam]): # deal with the maximum value
		print("max hyam index=", ihyam)
		hyam_diff=0.5*(hyam[ihyam]-hyam[ihyam-1])
	else:
		hyam_diff=0.5*(hyam[ihyam+1]-hyam[ihyam])

	hyam_bnds[ihyam,1]=hyam[ihyam]+hyam_diff
	hyam_bnds[ihyam+1,0]=hyam_bnds[ihyam,1] 

hyam_bnds[nhyam-1,1]=hyam[nhyam-1]+0.2*(hyam[nhyam-1]-hyam[nhyam-2])

## for check
#for ihyam in range(len(hyam)):
#	print(hyam_bnds[ihyam,0],hyam[ihyam],hyam_bnds[ihyam,1])


# create hybm_bnds
hybm_bnds=np.zeros((len(hybm),bnds),dtype=np.float64)

hybm_bnds[0,0]=hybm[0]-0.2*(hybm[1]-hybm[0])
hybm_bnds[0,1]=hybm[0]+0.5*(hybm[1]-hybm[0])
hybm_bnds[1,0]=hybm_bnds[0,1]

for ihybm in range(1,len(hybm)-1):
	if (hybm[ihybm+1] < hybm[ihybm]) & (hybm[ihybm-1] < hybm[ihybm]): # deal with the maximum value
		print("max hybm index=", ihybm)
		hybm_diff=0.5*(hybm[ihybm]-hybm[ihybm-1])
	else:
		hybm_diff=0.5*(hybm[ihybm+1]-hybm[ihybm])

	hybm_bnds[ihybm,1]=hybm[ihybm]+hybm_diff
	hybm_bnds[ihybm+1,0]=hybm_bnds[ihybm,1] 

hybm_bnds[nhybm-1,1]=hybm[nhybm-1]+0.2*(hybm[nhybm-1]-hybm[nhybm-2])

## for check
#for ihybm in range(len(hybm)):
#	print(hybm_bnds[ihybm,0],hybm[ihybm],hybm_bnds[ihybm,1])



# read 2D input variable names from xlsx file
file = "./cmvme_cf.cm.gm.hi.om.sc.si_piControl_1_1_CIESM.xlsx"
df = pd.read_excel(file,sheet_name='Amon')
df = df[df['CIESM Name'] != 'NAN']
print("df['CIESM Name'].shape=", df['CIESM Name'].shape)

Dims_3d = df[(df['dimensions']=='longitude latitude time') | (df['dimensions']=='longitude latitude time height2m') | (df['dimensions']=='longitude latitude time height10m')]
Dims_4d_plev = df[df['dimensions']=='longitude latitude plev19 time'] # on standard level
Dims_4d_alev = df[df['dimensions']=='longitude latitude alevel time'] # on model level
Dims_4d_ilev = df[df['dimensions']=='longitude latitude alevhalf time'] # on model half level
Dims_lev = df[df['dimensions']=='longitude latitude alevel time2']
Dims_ilev = df[df['dimensions']=='longitude latitude alevhalf time2']

varin3d			= list(Dims_3d['CIESM Name'])
varin4d_plev 	= list(Dims_4d_plev['CIESM Name'])
varin4d_alev 	= list(Dims_4d_alev['CIESM Name'])
varin4d_ilev	= list(Dims_4d_ilev['CIESM Name'])
varin_lev		= list(Dims_lev['CIESM Name'])
varin_ilev		= list(Dims_ilev['CIESM Name'])

nvar			= len(varin3d+varin4d_plev+varin4d_alev+varin4d_ilev+varin_lev+varin_ilev)
print("tota variable number=",nvar)

varot3d			= list(Dims_3d['CMOR Name'])
varot4d_plev 	= list(Dims_4d_plev['CMOR Name'])
varot4d_alev 	= list(Dims_4d_alev['CMOR Name'])
varot4d_ilev	= list(Dims_4d_ilev['CMOR Name'])
varot_ilev		= list(Dims_ilev['CMOR Name'])

units3d			= list(Dims_3d['units'])
units4d_plev	= list(Dims_4d_plev['units'])
units4d_alev	= list(Dims_4d_alev['units'])
units4d_ilev	= list(Dims_4d_ilev['units'])
units_lev		= list(Dims_lev['units'])
units_ilev		= list(Dims_ilev['units'])

positives3d			= list(Dims_3d['CIESM positives'])
positives4d_plev	= list(Dims_4d_plev['CIESM positives'])
positives4d_alev	= list(Dims_4d_alev['CIESM positives'])
positives4d_ilev	= list(Dims_4d_ilev['CIESM positives'])
positives_lev		= list(Dims_lev['CIESM positives'])
positives_ilev		= list(Dims_ilev['CIESM positives'])

# !!! notion: "coord_vals=time" will report error. 
# !!! should be written as "coord_vals=time[:]".
# !!! this is also the case for other vars (lat, lon, etc).

# here is where you add your axes
itime = cmor.axis(table_entry= 'time',
                  units= time.units)
ilat = cmor.axis(table_entry= 'latitude',
                 units= 'degrees_north',
                 coord_vals= lat[:],
                 cell_bounds= lat_bnds[:,:])
ilon = cmor.axis(table_entry= 'longitude',
                 units= 'degrees_east',
                 coord_vals= lon[:],
                 cell_bounds= lon_bnds[:,:])
iplev = cmor.axis(table_entry= 'plev19',
                 units= 'Pa',
                 coord_vals= plev[:]*100.,
                 cell_bounds= plev_bnds[:,:]*100.)

ialev = cmor.axis(table_entry= "standard_hybrid_sigma",
                    units='1',
                    coord_vals=alev[:],
                    cell_bounds=alev_bnds[:])

axis_ids_2d 	= [itime,ilat,ilon]
axis_ids_plev_3d = [itime,iplev,ilat,ilon]
axis_ids_alev_3d = [itime, ialev, ilat, ilon]

ierr = cmor.zfactor(zaxis_id=ialev,
                    zfactor_name='a',
                    axis_ids=[ialev, ],
                    zfactor_values=hyam[:],
                    zfactor_bounds=hyam_bnds[:])
ierr = cmor.zfactor(zaxis_id=ialev,
                    zfactor_name='b',
                    axis_ids=[ialev, ],
                    zfactor_values=hybm[:],
                    zfactor_bounds=hybm_bnds[:])
P0=100000
ierr = cmor.zfactor(zaxis_id=ialev,
                    zfactor_name='p0',
                    units='Pa',
                    zfactor_values=P0)
ips = cmor.zfactor(zaxis_id=ialev,
                   zfactor_name='ps',
                   axis_ids=[itime, ilat, ilon],
                   units='Pa')

var3d_ids=np.zeros((len(varin3d)),dtype=int)
var4d_plev_ids=np.zeros((len(varin4d_plev)),dtype=int)
var4d_alev_ids=np.zeros((len(varin4d_alev)),dtype=int)

for ivar in range(len(varin3d)):
	if str(positives3d[ivar]) == "nan":
		var3d_ids[ivar] = cmor.variable(str(varot3d[ivar]),str(units3d[ivar]),axis_ids_2d,original_name=str(varin3d[ivar]))
	else:
		var3d_ids[ivar] = cmor.variable(str(varot3d[ivar]),str(units3d[ivar]),axis_ids_2d,positive=str(positives3d[ivar]),original_name=str(varin3d[ivar]))
		

for ivar in range(len(varin4d_plev)):
	if str(positives4d_plev[ivar]) == "nan":
		var4d_plev_ids[ivar] = cmor.variable(str(varot4d_plev[ivar]),str(units4d_plev[ivar]),axis_ids_plev_3d,original_name=str(varin4d_plev[ivar]))
	else:
		var4d_plev_ids[ivar] = cmor.variable(str(varot4d_plev[ivar]),str(units4d_plev[ivar]),axis_ids_plev_3d,positive=str(positives4d_plev[ivar]),original_name=str(varin4d_plev[ivar]))


for ivar in range(len(varin4d_alev)):
	if str(positives4d_alev[ivar]) == "nan":
		var4d_alev_ids[ivar] = cmor.variable(str(varot4d_alev[ivar]),str(units4d_alev[ivar]),axis_ids_alev_3d,original_name=str(varin4d_alev[ivar]))
	else:
		var4d_alev_ids[ivar] = cmor.variable(str(varot4d_alev[ivar]),str(units4d_alev[ivar]),axis_ids_alev_3d,positive=str(positives4d_alev[ivar]),original_name=str(varin4d_alev[ivar]))


################################################

# 2D variables
data2d=np.zeros((len(varin3d),ntime,nlat,nlon),dtype=np.float64)

for ivar in range(len(varin3d)):
	for icase in range(len(casename)):
		for iyear in year:
			for imon in mon:
				print("icase=, iyear=, imon=",str(icase), str(iyear), str(imon))
	#			ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[icase]+'.cam.h0.'+str(iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
				ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[icase]+'/FillValue/'+casename[0]+'.cam.h0.'+str("%04d" % iyear)+'-'+str("%02d" % imon)+'_plev19.nc_FillValue.nc'
	
				print(ncfile)
				fnc=Dataset(ncfile,'r')
				vars=fnc.variables.keys()
	
				# get coordinates
				time_in=fnc.variables['time']
#				time=fnc.variables['time']
				time=time_in[:]-365*cutyear
#				time=time_in
	
				time_bnds_in=fnc.variables['time_bnds']
#				time_bnds=fnc.variables['time_bnds']
				time_bnds=time_bnds_in[:]-365*cutyear
#				time_bnds=time_bnds_in
			
				# cmor.write
				# read input 2D data
				print(str(varin3d[ivar]))
				data2d[ivar,:,:,:]=fnc.variables[str(varin3d[ivar])][:]
				print(time)
				cmor.write(var3d_ids[ivar],data2d[ivar,:,:,:],ntimes_passed=1,time_vals=time[:],time_bnds=time_bnds[:])
				#outfile_2d = cmor.close(var3d_ids[ivar], file_name=True)
				#print("File written to: {}".format(outfile_2d))
			
# 3D variables
data3d_plev=np.zeros((len(varin4d_plev),ntime,nplev,nlat,nlon),dtype=np.float64)
for ivar in range(len(varin4d_plev)):
	for icase in range(len(casename)):
		for iyear in year:
			for imon in mon:
				print("icase=, iyear=, imon=",str(icase), str(iyear), str(imon))
	#			ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[icase]+'.cam.h0.'+str(iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
#				ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[0]+'.cam.h0.'+str("%04d" % iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
				ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[icase]+'/FillValue/'+casename[0]+'.cam.h0.'+str("%04d" % iyear)+'-'+str("%02d" % imon)+'_plev19.nc_FillValue.nc'

				print(ncfile)
				fnc=Dataset(ncfile,'r')
				vars=fnc.variables.keys()
	
				# get coordinates
				time_in=fnc.variables['time']
#				time=fnc.variables['time']
				time=time_in[:]-365*cutyear
	
				time_bnds_in=fnc.variables['time_bnds']
#				time_bnds=fnc.variables['time_bnds']
				time_bnds=time_bnds_in[:]-365*cutyear
	
				print(str(varin4d_plev[ivar]))
				data3d_plev[ivar,:,:,:,:]=fnc.variables[str(varin4d_plev[ivar])][:]
				cmor.write(var4d_plev_ids[ivar],data3d_plev[ivar,:,:,:,:],ntimes_passed=1,time_vals=time[:],time_bnds=time_bnds[:])
				#outfile_3d = cmor.close(var4d_plev_ids[ivar], file_name=True)
				#print("File written to: {}".format(outfile_3d))

#### NOTION: Because writing PS encounters time_bnds overlap problem, I move the time loop into the variable loop.
#### hint from Dong Li: https://www.gitmemory.com/issue/PCMDI/cmor/510/508966586

data3d_alev=np.zeros((len(varin4d_alev),ntime,nalev,nlat,nlon),dtype=np.float64)

for ivar in range(len(varin4d_alev)):
	for icase in range(len(casename)):
		print("icase="+str(icase))
		for iyear in year:
			print("iyear="+str(iyear))
			for imon in mon:
				print("icase=, iyear=, imon=",str(icase), str(iyear),str(imon))
#				ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[icase]+'.cam.h0.'+str(iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
#				ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[0]+'.cam.h0.'+str("%04d" % iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
				ncfile='/GPFS/cess9/qinyi/CMOR3/mid-data/'+casename[icase]+'/FillValue/'+casename[0]+'.cam.h0.'+str("%04d" % iyear)+'-'+str("%02d" % imon)+'_plev19.nc_FillValue.nc'


				print(ncfile)
				fnc=Dataset(ncfile,'r')
				vars=fnc.variables.keys()
				
				# get coordinates
				time_in=fnc.variables['time']
#				time=fnc.variables['time']
				time=time_in[:]-365*cutyear
				
				time_bnds_in=fnc.variables['time_bnds']
#				time_bnds=fnc.variables['time_bnds']
				time_bnds=time_bnds_in[:]-365*cutyear
				
				
				data3d_alev[ivar,:,:,:,:]=fnc.variables[str(varin4d_alev[ivar])][:]
				PS = fnc.variables['PS']
				
				cmor.write(var4d_alev_ids[ivar],data3d_alev[ivar,:,:,:,:],ntimes_passed=1,time_vals=time[:],time_bnds=time_bnds[:])
				cmor.write(ips, PS[:], ntimes_passed=1, time_vals=time[:], time_bnds=time_bnds[:], store_with=var4d_alev_ids[ivar])

				#outfile_3d = cmor.close(var4d_alev_ids[ivar], file_name=True)
				#print("File written to: {}".format(outfile_3d))

cmor.close()

