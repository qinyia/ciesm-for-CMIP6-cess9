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
				
			if (regrid_ver == "T"):
				datadir=dirs[icase]+"/"+casename[icase]+"_192x288/"
				print("datadir="+datadir)
				outdir="/GFPS8p/cess9/qinyi/CMOR3/mid-data/"+casename[icase]+"/"
				print("outdir="+outdir)
				cmd = 'sh ./002-ncl-ml2pl-params.sh %s %s %s %i %i %i %i %s %s' %(datadir, casename[icase], outdir, int_year[icase], end_year[icase], int_mon[icase], end_mon[icase], vars_plev_in[icase], vars_alev_in[icase])
				os.system(cmd)
			
def only_lonlattime (casename, dirs, int_year, end_year, int_mon, end_mon, var_in):
	for s in casename:
		print("s="+str(s))
		ncase=len(casename)
		print("ncase="+str(ncase))
		
		for icase in range(ncase):
			print("casename[icase]="+casename[icase])
				
			datadir=dirs[icase]+"/"+casename[icase]+"_192x288/"
			print("datadir="+datadir)
			outdir="/GFPS8p/cess9/qinyi/CMOR3/mid-data-1/"+casename[icase]+"/"+var_in+"/"
			print("outdir="+outdir)
			print(var_in)
			cmd = 'sh ./0001.0-process-indirect-vars-lonlattime.sh %s %s %s %i %i %i %i %s' %(datadir, casename[icase], outdir, int_year[icase], end_year[icase], int_mon[icase], end_mon[icase], var_in)
			os.system(cmd)
	
def only_fx (casename, dirs, int_year, end_year, int_mon, end_mon, var_in):
	for s in casename:
		print("s="+str(s))
		ncase=len(casename)
		print("ncase="+str(ncase))
		
		for icase in range(ncase):
			print("casename[icase]="+casename[icase])
				
			datadir=dirs[icase]+"/"+casename[icase]+"_192x288/"
			print("datadir="+datadir)
			outdir="/GFPS8p/cess9/qinyi/CMOR3/mid-data-1/"+casename[icase]+"/"+var_in+"/"
			print("outdir="+outdir)
			print(var_in)
			cmd = 'sh ./0001.1-process-indirect-vars-fx.sh %s %s %s %i %i %i %i %s' %(datadir, casename[icase], outdir, int_year[icase], end_year[icase], int_mon[icase], end_mon[icase], var_in)
			os.system(cmd)
	
def only_lev (casename, dirs, int_year, end_year, int_mon, end_mon, var_in):
	for s in casename:
		print("s="+str(s))
		ncase=len(casename)
		print("ncase="+str(ncase))
		
		for icase in range(ncase):
			print("casename[icase]="+casename[icase])
				
			datadir=dirs[icase]+"/"+casename[icase]+"_192x288/"
			print("datadir="+datadir)
			outdir="/GFPS8p/cess9/qinyi/CMOR3/mid-data-1/"+casename[icase]+"/"+var_in+"/"
			print("outdir="+outdir)
			print(var_in)
			cmd = 'sh ./0001.2-process-indirect-vars-lev.sh %s %s %s %i %i %i %i %s' %(datadir, casename[icase], outdir, int_year[icase], end_year[icase], int_mon[icase], end_mon[icase], var_in)
			os.system(cmd)


def all():
	dir1="/GFPS8p/cess1/se2fv-regrid/rgr_out/"
	casename=["FAMIPC5_g16_acc_nochem_4"]
	dirs=[dir1]
	int_year=[1979]
	end_year=[2014]
	int_mon=[1]
	end_mon=[12]
	regrid_hor="F"
	regrid_ver="T"
	indir_vars = [1,1,0] # lev, fx, Amon-indirect


	ignore_vars			= ['vas','sfcWind','hurs','prsn','sbl','ccb','cct','ci','sci','evspsbl',
						   'fco2antt','fco2fos','fco2nat','mc','o3','o3Clim','co2','co2Clim','ch4','ch4Clim','n2o','n2oClim',
						   'co2mass','co2massClim','ch4global','ch4globalClim','n2oglobal','n2oglobalClim', # Sep 17,2019: I cannot decide the exact meaning of these variables.
						   'rldscs','rsdt','rsutcs', # these also cannot be obtained.
						   ]
	# ['ccb','cct','ci','sci','mc'] -- Sep 17, 2019: these variables could be outputted by adding them in namelist. 
	#print(ignore_vars)


	fx_vars				= ['areacella','sftlf']
	lev_vars			= ['pfull', 'phalf']

	# read input variable names from xlsx file
	file = "./cmvme_cf.cm.gm.hi.om.sc.si_piControl_1_1_CIESM.xlsx"

	if (indir_vars[0] == 0):
		# --- process lev and ilev
		df 					= pd.read_excel(file,sheet_name='Amon')
		for ivar in lev_vars:
			df_var			= df[df['CMOR Name'] == ivar]
			fvar_cmorname	= list(df_var['CMOR Name'])
			print(ivar+"	"+fvar_cmorname[0])
			only_lev(casename, dirs, int_year, end_year, int_mon, end_mon, fvar_cmorname[0])
		exit()

	if(indir_vars[1] == 0):
		# --- process variables without time dimensions: fx
		df_fix				= pd.read_excel(file,sheet_name='fx')
		for ivar in fx_vars:
			df_var				= df_fix[df_fix['Variable Name'] == ivar]
			fvar_cmorname		= list(df_var['Variable Name'])	
			print(ivar+"	"+fvar_cmorname[0])
			only_fx(casename,dirs, int_year, end_year, int_mon, end_mon, fvar_cmorname[0])
		exit()

	if(indir_vars[2] == 0):
		# --- process Amon variables
		df = pd.read_excel(file,sheet_name='Amon')
		df = df[df['CIESM Name'] == 'NAN']

		vars			= list(df['CMOR Name'])
		nvars			= df['CMOR Name'].shape
		print(nvars)

		for ivar in  vars:
			#print(ivar)
			df_cmorname		= df[df['CMOR Name'] == ivar]
			var_cmorname	= list(df_cmorname['CMOR Name'])
			var_Dims		= list(df_cmorname['dimensions'])
			var_Standard	= list(df_cmorname['CF Standard Name'])
			#print(var_Dims)
			#print(type(var_Dims)) -- list
			#print(var_cmorname)

			if (var_cmorname[0] in ignore_vars):
				print(var_cmorname[0]+" will be ingnored!")
			elif (var_Dims[0] == 'longitude latitude plev19 time'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif (var_Dims[0] == 'longitude latitude plev19 time2'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif (var_Dims[0] == 'longitude latitdue alevel time'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif ((var_Dims[0] == 'longitude latitude time') | (var_Dims[0] == 'longitude latitude time height2m') | (var_Dims[0] == 'longitude latitude time height10m')):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
				only_lonlattime(casename,dirs, int_year, end_year, int_mon, end_mon, var_cmorname[0])
			elif (var_Dims[0] == 'longitude latitude alevhalf time'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif (var_Dims[0] == 'longitude latitude alevhalf time2'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif (var_Dims[0] == ' time'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			elif (var_Dims[0] == ' time2'):
				print(ivar+"	"+var_Dims[0]+"		"+var_Standard[0])
			else:
				print(ivar+" is exception! Its CF Standard Name is: "+var_Standard[0]+". Its Dims is:"+var_Dims[0])
		
		exit()

	
# data regrid
	only(casename, dirs, int_year, end_year, int_mon, end_mon, regrid_hor, regrid_ver, vars_plev_in, vars_alev_in)

if __name__ == '__main__':
	all()


