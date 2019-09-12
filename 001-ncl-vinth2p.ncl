begin

fn 					= getenv("fn")
fo					= getenv("fo")
vars_str				= getenv("vars")

print(fn)
print(fo)
print(vars_str)

in 					= addfile(fn,"r")
out					= addfile(fo,"c")

vars 					= str_split(vars_str, ",")
print(vars)

do ivar=0,dimsizes(vars)-1
	print(vars(ivar))
	var_tmp				= in->$vars(ivar)$
	P0mb				= in->P0
	P0mb				= P0mb/100.
print(P0mb)
	hyam				= in->hyam
	hybm				= in->hybm
	PS				= in->PS

	;************************************************
	; define other arguments required by vinth2p
	;************************************************
	; type of interpolation: 1 = linear, 2 = log, 3 = loglog
	   interp = 1 
	
	; is extrapolation desired if data is outside the range of PS
	   extrap = False
	
	; create an array of desired pressure levels:
	   pnew = (/100000.,92500,85000,70000,60000,50000,40000,30000,25000,\
                    20000,15000,10000,7000,5000,3000,2000,1000,500,100/)/100.

	;************************************************
	; calculate vars(ivar) on pressure levels
	;************************************************
	; note, the 7th argument is not used, and so is set to 1.
	;************************************************
	varsonP = vinth2p(var_tmp,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
	copy_VarAtts(var_tmp,varsonP)   
	printVarSummary(varsonP)
	varsonP!1		= "plev"
		
	out->$vars(ivar)$ 		= varsonP

;xx = out->$vars(ivar)$
;printVarSummary(xx)
delete(varsonP)

end do ; do ivar=

exit

;************************************************
; plot parameters that do not change
;************************************************
   wks  = gsn_open_wks("png","vert")              ; send graphics to PNG file
   plot = new(3,graphic)                          ; Define plot array 
   r    = True                                    ; plot mods desired
   r@gsnFrame = False                             ; required for panel plots
   r@gsnDraw  = False                             ; required for panel plots
;************************************************
; create individual contour plots
;************************************************
   r@tiMainString= "850 mb"                      ; plot title
   plot(0)=gsn_csm_contour_map(wks,TonP(0,:,:),r)  ; plot temp contours 

   r@tiMainString= "500 mb"                      ; plot title
   plot(1)=gsn_csm_contour_map(wks,TonP(2,:,:),r)  ; plot temp contours

   r@tiMainString= "200 mb"                      ; plot title
   plot(2)=gsn_csm_contour_map(wks,TonP(4,:,:),r)  ; plot temp contours
;***********************************************
   gsn_panel(wks,plot,(/3,1/),False)              ; create panel plots
end



