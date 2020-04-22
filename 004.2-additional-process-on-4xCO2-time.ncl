
fn			= getenv("infile")
fo 			= getenv("outfile")
yyyy		= getenv("yyyy")
mm			= getenv("mm")
dd		  	= getenv("dd")
dd0			= getenv("dd0") ; the day for the previous month to get time_bnds

print(fn)
print(fo)
print("year="+yyyy+"	month="+mm+"	day="+dd)

in			= addfile(fn,"r")

;system("/bin/rm -f " + fo)
out			= addfile(fo,"w")

time		= in->time
time_bnds 	= in->time_bnds
;print(time)

hh    = 24                                  ; array syntax
mn    = 0
sc    = 0

units		= "days since 0001-01-01 00:00:00"
opt = 0
opt@calendar = "noleap"
if (stringtointeger(yyyy).eq.1 .and. stringtointeger(mm).eq.1)then
	time2 = 0
else if(stringtointeger(mm).eq.1)then
	time2		= cd_inv_calendar(stringtointeger(yyyy)-1,stringtointeger(12),stringtointeger(dd),hh,mn,sc,units, opt)
else
	time2		= cd_inv_calendar(stringtointeger(yyyy),stringtointeger(mm)-1,stringtointeger(dd0),hh,mn,sc,units, opt)
end if
end if


time1		= cd_inv_calendar(stringtointeger(yyyy),stringtointeger(mm),stringtointeger(dd),hh,mn,sc,units, opt)
copy_VarAtts(time,time1)
time1!0		= "time"
time1@units = units

time_bnds1		= time_bnds
time_bnds1(:,0)	= (/time2/)
time_bnds1(:,1)	= (/time1/)

print(time+"	"+time_bnds(:,0)+"	"+time_bnds(:,1))
print(time1+"	"+time_bnds1(:,0)+"	"+time_bnds1(:,1))



out->time		= (/time1/)
out->time_bnds	= (/time_bnds1/)

