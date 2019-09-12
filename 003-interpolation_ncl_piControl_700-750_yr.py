from netCDF4 import Dataset
import pandas as pd
import numpy as np
import subprocess
import os

#----------------------------------------
#------------------ qinyi
def only (casename, dirs, int_year, end_year, int_mon, end_mon, regrid_hor, regrid_ver, vars_plev_in, vars_alev_in):
	for s in casename:
		print("s="+str(s))
		ncase=len(casename)
		print("ncase="+str(ncase))
		
		for icase in range(ncase):
			print("casename[icase]="+casename[icase])

    ### Part 1: regrid from SE to FV grid for all monthly dataset
			if (regrid_hor == "T" ): # ---- need to double check when using ne30 data
				workdir="/GPFS/cess1/se2fv-regrid/scripts/"
				## modify start
				src_dir=dirs[icase]+"/"+casename[icase]+"/run/"
				print(src_dir)
				## modify end
				out_dir="/GPFS/cess1/se2fv-regrid/rgr_out/"+casename[icase]+"_192x288/"
				
				print(out_dir)
				print(int_year[icase])
				print(end_year[icase])
				os.system('sh '+workdir+'/002_ncremap_files_params.sh '+workdir+' '+casename+' '+src_dir+' '+out_dir)
				
			if (regrid_ver == "T"):
				datadir=dirs[icase]+"/"+casename[icase]+"_192x288/"
				print("datadir="+datadir)
				outdir="/GPFS/cess9/qinyi/CMOR3/mid-data/"+casename[icase]+"/"
				print("outdir="+outdir)
				cmd = 'sh ./002-ncl-ml2pl-params.sh %s %s %s %i %i %i %i %s %s' %(datadir, casename[icase], outdir, int_year[icase], end_year[icase], int_mon[icase], end_mon[icase], vars_plev_in[icase], vars_alev_in[icase])
				os.system(cmd)
			
def all():
	dir1="/GPFS/cess1/se2fv-regrid/rgr_out/"
	casename=["PIC_g16_acc_nochem_1"]
	dirs=[dir1]
	int_year=[701]
	end_year=[750]
	int_mon=[1]
	end_mon=[12]
	regrid_hor="F"
	regrid_ver="T"

	ncase=len(casename)
	print(ncase)

	# read input variable names from xlsx file
	file = "./cmvme_cf.cm.gm.hi.om.sc.si_piControl_1_1_CIESM.xlsx"
	df = pd.read_excel(file,sheet_name='Amon')
	df = df[df['CIESM Name'] != 'NAN']
	print(df['CIESM Name'].shape)
	
	Dims_3d = df[(df['dimensions']=='longitude latitude time') | (df['dimensions']=='longitude latitude time height2m') | (df['dimensions']=='longitude latitude time height10m')]
	Dims_4d_plev = df[df['dimensions']=='longitude latitude plev19 time']
	Dims_4d_alev = df[df['dimensions']=='longitude latitude alevel time']
	Dims_4d_ilev = df[df['dimensions']=='longitude latitude alevhalf time']
	Dims_alev = df[df['dimensions']=='longitude latitude alevel time2']
	Dims_ilev = df[df['dimensions']=='longitude latitude alevhalf time2']
	
	varin3d			= list(Dims_3d['CIESM Name'])
	varin4d_plev 	= list(Dims_4d_plev['CIESM Name'])
	varin4d_alev 	= list(Dims_4d_alev['CIESM Name'])
	varin4d_ilev 	= list(Dims_4d_ilev['CIESM Name'])
	varin_alev		= list(Dims_alev['CIESM Name'])
	varin_ilev		= list(Dims_ilev['CIESM Name'])

	vars_plev		= [] # on plev 19 standard level
	vars_alev		= [] # only on model own level
	vars_plev		= varin4d_plev 
	vars_alev		= varin3d + varin4d_alev + varin4d_ilev + varin_alev + varin_ilev

	
	# unicode to string --- only for python 2.7
	for ivar in range(len(vars_plev)):
		vars_plev[ivar]	= str(vars_plev[ivar])

	for ivar in range(len(vars_alev)):
		vars_alev[ivar]	= str(vars_alev[ivar])

	print(vars_plev)
	print(vars_alev)

	# join all list elements into one string and separate them by ","
	str1 = ','.join(vars_plev)
	print(str1)
	print(type(str1))

	str2 = ','.join(vars_alev)

	vars_plev_in=[str1]
	vars_alev_in=[str2]
	print(vars_plev_in)


# data regrid
	only(casename, dirs, int_year, end_year, int_mon, end_mon, regrid_hor, regrid_ver, vars_plev_in, vars_alev_in)

if __name__ == '__main__':
	all()


