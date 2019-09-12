
;experiment_id			= (/"historical"/)
;experiment_id_old		= (/"B20TRC5_g16_acc_nochem_2"/)
experiment_id			= (/"piControl"/)
experiment_id_old		= (/"PIC_g16_acc_nochem_1"/)

var_id				= (/"cl","hur"/)
var_id_old			= (/"CLOUD","RELHUM"/)
;version				= (/"v20190910"/)
version				= (/"v20190911"/)
grid				= (/"gr"/)
;year				= (/"185001-185212"/)
;year				= (/"000101-000112"/)
year				= (/"040101-045012"/)

pick_time			= (/0,7/)
;pick_time_old			= (/"1850-01","1850-08"/)
pick_time_old			= (/"0701-01","0701-08"/)
pick_lev			= (/950,800,500,300,50/)
pick_lev_id			= (/0,5,10,15,20,25/)

fdir2				= "/GPFS/cess1/se2fv-regrid/rgr_out/"+experiment_id_old+"_192x288/"
print(fdir2)

do ivar=0,dimsizes(var_id)-1
	wks		= gsn_open_wks("pdf","./figure/post_check_"+experiment_id+"_"+var_id(ivar))
	plot	= new(2,graphic)

	res		= True
	res@gsnFrame	= False
	res@gsnDraw		= False
	res@cnFillOn	= True



	fdir1			= "/GPFS/cess9/qinyi/CMOR3/CMIP6/CMIP6/CMIP/THU/CIESM/"+experiment_id+"/r1i1p1f1/Amon/"+var_id(ivar)+"/"+grid+"/"+version+"/"
	fname1			= var_id(ivar)+"_Amon_CIESM_"+experiment_id+"_r1i1p1f1_"+grid+"_"+year+".nc"
	
	f1			= addfile(fdir1+fname1,"r")
	do itime = 0,dimsizes(pick_time)-1

if(var_id(ivar).eq."hur")then
		do ilev = 0,dimsizes(pick_lev)-1
			; --- read CMIP6 data
			vartmp			= f1->$var_id(ivar)$(pick_time(itime),{pick_lev(ilev)*100},:,:)
;			vartmp@_FillValue	= 9.96921e+36
			;printVarSummary(vartmp)
			printMinMax(vartmp,True)

			; --- read raw data
			fname2			= experiment_id_old+".cam.h0."+pick_time_old(itime)+".nc"
			f2			= addfile(fdir2+fname2,"r")
			vartmp_old		= f2->$var_id_old(ivar)$(0,{pick_lev(ilev)},:,:)
			;printVarSummary(vartmp_old)
			printMinMax(vartmp_old,True)

			; --- spatial correlation
			rb = pattern_cor(vartmp, vartmp_old, 1.0, 1)    ; no weighting, uncentered
			print("pick_lev="+pick_lev(ilev)+"	rb="+rb)

			; --- plot
			res@gsnRightString	= pick_time_old(itime)
			res@gsnCenterString	= var_id(ivar)+", "+var_id_old(ivar)+" cor="+sprintf("%5.2f",rb)

			symMinMaxPlt ((/vartmp,vartmp_old/),20,False,res) 

			res@gsnLeftString	= "CMIP6_"+pick_lev(ilev)+" hPa"
			plot(0)	= gsn_csm_contour_map_ce(wks,vartmp,res)
			res@gsnLeftString	= "RAWDATA_"+pick_lev(ilev)+" hPa"
			plot(1)	= gsn_csm_contour_map_ce(wks,vartmp_old,res)
			gsn_panel(wks,plot,(/2,1/),False)
		end do ; do ilev=
else
		do ilev = 0,dimsizes(pick_lev_id)-1
			; --- read CMIP6 data
			vartmp			= f1->$var_id(ivar)$(pick_time(itime),29-pick_lev_id(ilev),:,:)
;			vartmp@_FillValue	= 9.96921e+36
			;printVarSummary(vartmp)
			printMinMax(vartmp,True)

			; --- read raw data
			fname2			= experiment_id_old+".cam.h0."+pick_time_old(itime)+".nc"
			f2			= addfile(fdir2+fname2,"r")
			vartmp_old		= f2->$var_id_old(ivar)$(0,pick_lev_id(ilev),:,:)
			;printVarSummary(vartmp_old)
			printMinMax(vartmp_old,True)

			; --- spatial correlation
			rb = pattern_cor(vartmp, vartmp_old, 1.0, 1)    ; no weighting, uncentered
			print("pick_lev_id="+pick_lev_id(ilev)+"	rb="+rb)

			symMinMaxPlt ((/vartmp,vartmp_old/),20,False,res) 
			; --- plotting
			res@gsnRightString	= pick_time_old(itime)
			res@gsnCenterString	= var_id(ivar)+", "+var_id_old(ivar)+" cor="+sprintf("%5.2f",rb)

			res@gsnLeftString	= "CMIP6_"+pick_lev_id(ilev)+" hPa"
			plot(0)	= gsn_csm_contour_map_ce(wks,vartmp,res)
			res@gsnLeftString	= "RAWDATA_"+pick_lev_id(ilev)+" hPa"
			plot(1)	= gsn_csm_contour_map_ce(wks,vartmp_old,res)

			gsn_panel(wks,plot,(/2,1/),False)
		end do ; do ilev=

end if

end do ; do itime=
	
delete(vartmp)
end do ; do ivar=
