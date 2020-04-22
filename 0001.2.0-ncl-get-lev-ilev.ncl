begin

fn 					= getenv("infile")
fo					= getenv("outfile")
vars				= getenv("vars")

if(isfilepresent(fo)) then
 	system("/bin/rm -rf " + fo)
end if

print(fn)
print(fo)

in 					= addfile(fn,"r")
out					= addfile(fo,"c")

print(vars)

time				= in->time

time_bnds			= new((/dimsizes(time),2/),typeof(time))
time_bnds(:,0)		= time-31
time_bnds(:,1)		= time
time_bnds!0			= "time"
time_bnds&time		= time&time
time_bnds!1			= "nbnd"
time_bnds&nbnd		= (/1,2/)
delete_VarAtts(time_bnds, -1)
time_bnds@long_name	= "time interval endpoints"

if(vars.eq."pfull")then
	P0					= in->P0
	hyam				= in->hyam
	hybm				= in->hybm
	PS					= in->PS
	printVarSummary(PS)

	out->hyam			= hyam
	out->hybm			= hybm

end if
	
if(vars.eq."phalf")then
	P0					= in->P0
	hyam				= in->hyai
	hybm				= in->hybi
	PS					= in->PS

	out->hyai			= hyam
	out->hybi			= hybm

end if

printVarSummary(P0)
printVarSummary(PS)


pm = pres_hybrid_ccm(PS,P0,hyam,hybm) 
copy_VarCoords(PS,pm(:,0,:,:))
copy_VarCoords(hyam,pm(0,:,0,0))
printVarSummary(pm)
printMinMax(pm,True)

out->$vars$ 		= pm
out->P0				= P0
out->PS				= PS
out->time_bnds		= time_bnds

delete([/P0,PS,hyam,hybm,pm/])

end



