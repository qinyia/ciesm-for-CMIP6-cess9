import cmor
from netCDF4 import Dataset
import pandas as pd
import numpy as np
import subprocess
import os

#------------------ qinyi
cmor.setup(
	# inpath has to point to the CMOR 
	# tables path (CMIP6, input4MIPs or otherwise)
	inpath='/home/lyl/WORK1/cesm1_2_1/CMOR3/cmor/TestTables',  
#	netcdf_file_action=cmor.CMOR_REPLACE_4
	netcdf_file_action=cmor.CMOR_APPEND_4
)

cmor.dataset_json("./CMOR_test_CIESM.json")    
  
# Loading this test table overwrites the normal CF checks on valid variable values.
# This is perfect for testing but shouldn't be done when writing real data.
table='CMIP6_Amon.json'
cmor.load_table(table)

casename=["FAMIPC5_f09f09_MG10_amip"]
dirs=["./"]
int_year=[1980]
end_year=[1984]
int_mon=[1]
end_mon=[12]
year=range(int_year[0],end_year[0]+1)
mon=range(int_mon[0],end_mon[0]+1)

ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[0]+'.cam.h0.'+str(year[0])+'-'+str("%02d" % mon[0])+'_plev19.nc'
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
lev=fnc.variables['lev']
nlev=len(lev)

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

# create lev_bnds
lev_bnds=np.zeros((len(lev),bnds),dtype=np.float64)
for ilev in range(0,len(lev)-1):
	lev_diff=0.5*(lev[ilev+1]-lev[ilev])
	lev_bnds[ilev,1]=lev[ilev]+lev_diff
	lev_bnds[ilev+1,0]=lev_bnds[ilev,1] 

lev_bnds[0,0]=lev[0]-0.2*(lev[2]-lev[1])
lev_bnds[nlev-1,1]=lev[nlev-1]+0.2*(lev[nlev-1]-lev[nlev-2])

## for check
#for ilev in range(len(lev)):
#	print(lev_bnds[ilev,0],lev_bnds[ilev,1],lev[ilev])


# read 2D input variable names
f2d=open('./varin2d.txt')
varin2d=f2d.read()
varin2d=varin2d.split( )

# read 3D input variable names
f3d=open('./varin3d.txt')
varin3d=f3d.read()
varin3d=varin3d.split( )
print(varin3d)
print(type(varin3d))

# !!! notion: "coord_vals=time" will report error. 
# !!! should be written as "coord_vals=time[:]".
# !!! this is also the case for other vars (lat, lon, etc).

ntimes=1
# here is where you add your axes
itime = cmor.axis(table_entry= 'time',
                  units= time.units)
#				  length=ntimes)
#                  coord_vals= time[:],
#                  cell_bounds= time_bnds[:,:])
#itime = cmor.axis(table_entry='time',
#     			 units= time.units,
#     			 length=ntime,
#     			 interval='20 minutes')
ilat = cmor.axis(table_entry= 'latitude',
                 units= 'degrees_north',
                 coord_vals= lat[:],
                 cell_bounds= lat_bnds[:,:])
ilon = cmor.axis(table_entry= 'longitude',
                 units= 'degrees_east',
                 coord_vals= lon[:],
                 cell_bounds= lon_bnds[:,:])
ilev = cmor.axis(table_entry= 'plev19',
                 units= 'Pa',
                 coord_vals= lev[:],
                 cell_bounds= lev_bnds[:,:])

axis_ids_2d = [itime,ilat,ilon]
axis_ids_3d = [itime,ilev,ilat,ilon]


# here we create a variable with appropriate name, units and axes
# then we can write the variable along with the data
# finally we close the file and print where it was saved
units2d=['K']
units3d=['K']

varot2d=['ts']
varot3d=['ta']

var2d_ids=np.zeros((len(varin2d)),dtype=int)
var3d_ids=np.zeros((len(varin3d)),dtype=int)
for ivar in range(len(varin2d)):
  var2d_ids[ivar] = cmor.variable(varot2d[ivar],units2d[ivar],axis_ids_2d,original_name=varin2d[ivar])

for ivar in range(len(varin3d)):
  var3d_ids[ivar] = cmor.variable(varot3d[ivar],units3d[ivar],axis_ids_3d,original_name=varin3d[ivar])


################################################

for icase in range(len(casename)):
	print("icase="+str(icase))
	for iyear in year:
		print("iyear="+str(iyear))
		for imon in mon:
			print("imon="+str(imon))
			ncfile='/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/'+casename[icase]+'.cam.h0.'+str(iyear)+'-'+str("%02d" % imon)+'_plev19.nc'
			print(ncfile)
			fnc=Dataset(ncfile,'r')
			vars=fnc.variables.keys()

			# get coordinates
			time=fnc.variables['time']
	
			time_bnds=fnc.variables['time_bnds']
			
			# cmor.write
			# 2D variables
			data2d=np.zeros((len(varin2d),ntime,nlat,nlon),dtype=np.float64)
			for ivar in range(len(varin2d)):
				print(varin2d[ivar])
				# read input 2D data
				data2d[ivar,:,:,:]=fnc.variables[varin2d[ivar]][:]
				cmor.write(var2d_ids[ivar],data2d[ivar,:,:,:],ntimes_passed=1,time_vals=time[:],time_bnds=time_bnds[:])
				#outfile_2d = cmor.close(var2d_ids[ivar], file_name=True)
				#print("File written to: {}".format(outfile_2d))
			
			# 3D variables
			data3d=np.zeros((len(varin3d),ntime,nlev,nlat,nlon),dtype=np.float64)
			for ivar in range(len(varin3d)):
				data3d[ivar,:,:,:,:]=fnc.variables[varin3d[ivar]][:]
				cmor.write(var3d_ids[ivar],data3d[ivar,:,:,:,:],ntimes_passed=1,time_vals=time[:],time_bnds=time_bnds[:])
				#outfile_3d = cmor.close(var3d_ids[ivar], file_name=True)
				#print("File written to: {}".format(outfile_3d))
		
cmor.close()

