
;experiment_id			= (/"historical"/)
;experiment_id_old		= (/"B20TRC5_g16_acc_nochem_2"/)
experiment_id			= (/"piControl"/)
experiment_id_old		= (/"PIC_g16_acc_nochem_1"/)

var_id					= (/"rlus","rsus","rsuscs","rtmt"/)
version					= (/"v20190921"/) ;(/"v20190917"/)
grid					= (/"gr"/)

type					= (/"Amon"/)

year					= (/"000101-000103"/)

do ivar=0,dimsizes(var_id)-1
	wks		= gsn_open_wks("pdf","./figure/post_check_"+experiment_id+"_"+var_id(ivar)+"_"+version)

	res		= True
;	res@gsnFrame	= False
;	res@gsnDraw		= False
	res@cnFillOn	= True

	fdir1			= "/GPFS/cess9/qinyi/CMOR3/CMIP6-1/CMIP6/CMIP/THU/CIESM/"+experiment_id+"/r1i1p1f1/"+type+"/"+var_id(ivar)+"/"+grid+"/"+version+"/"
	fname1			= var_id(ivar)+"_"+type+"_CIESM_"+experiment_id+"_r1i1p1f1_"+grid+"_"+year+".nc"
	
	f1				= addfile(fdir1+fname1,"r")

	vartmp			= f1->$var_id(ivar)$(0,:,:)

	printMinMax(vartmp,True)
	;print(vartmp&lon)
	;print(vartmp&lat)

	; --- plot
	res@gsnCenterString	= var_id(ivar)

	res@gsnLeftString	= "CMIP6_output"
	plot	= gsn_csm_contour_map_ce(wks,vartmp,res)

delete(vartmp)
end do ; do ivar=
