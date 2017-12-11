
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  start_cpu_time = get_cpu_time()    
 
atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
 files = systemfunc("ls ~/TCC_RODADAS/MEM4/wrfout_d01_2016-*")
nfiles = dimsizes(files)



dados     = addfiles(files,"r")



  wks = gsn_open_wks("pdf","pltCiclo")



soma = new((/97,7/),"float",-99.9)
  soma@_FillValue = -99.9   ; identificação de falta de dados

soma(:,6) = asciiread("cemadeninter.dat",(/97/),"float")

soma2 = new((/97,7/),"float",-99.9)
  soma2@_FillValue = -99.9   ; identificação de falta de dados

lonnew = ispan( -4715, -4615, 16 )/100.
latnew = ispan( -2380, -2310, 16 )/100.


do k = 0,nfiles-1





 ; Get non-convective, convective 
  ; Calculate total precipitation
    rain_exp = wrf_user_getvar(dados[k],"RAINNC",-1)
    rain_con = wrf_user_getvar(dados[k],"RAINC",-1)
    rain_tot = rain_exp + rain_con
      rain_tot@description = "Total precipitado"

   lat2d = wrf_user_getvar(dados[k],"XLAT",0)
   lon2d = wrf_user_getvar(dados[k],"XLONG",0)
   


chuva = rcm2rgrid(lat2d,lon2d,rain_tot,latnew,lonnew,0)


delete(rain_exp)
delete(rain_con)
delete(rain_tot)

chuva!0 = "time"
chuva!2 = "lon"
chuva!1 = "lat"
chuva&lon = lonnew
chuva&lat = latnew
chuva&lat@units = "degrees_north"
chuva&lon@units = "degrees_east"



   re   = 6.37122e06
   rad  = 4.0 * atan(1.0) / 180.0
   con  = re * rad                 
   clat = cos(latnew * rad)      

dlon = lonnew(2) - lonnew(1)
dlat = latnew(4) - latnew(3)


   dx   = con * dlon * clat        ; dx at each latitude
   dy   = con * dlat               ; dy is constant
   dydx = dy * dx  

   wgt  = new((/dimsizes(latnew), dimsizes(lonnew)/), typeof(chuva))

   wgt  = conform(wgt, dydx, 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(dados[k],"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file
print(ntimes)

opt = True
opt@gsnAddCyclic = False
opt@gsnMaximize = True
opt@mpDataBaseVersion     = "MediumRes"
opt@pmTickMarkDisplayMode = "Always"
opt@mpNationalLineThicknessF = 3   
opt@mpMinLatF = -23.80
opt@mpMaxLatF = -23.10
opt@mpMinLonF = -47.15
opt@mpMaxLonF = -46.15
opt@mpDataSetName = "Earth..4"
	opt@tiMainString = "Chuva hour"
	       

j = 0

	do i = 0,ntimes-1

 opt@gsnLeftString = times(i)



	if (i .gt. 0)
		chuvainst = chuva(i,:,:) - chuva(i-1,:,:)
		copy_VarCoords(chuva(i,:,:),chuvainst)
		
		;map_mask  = gsn_csm_contour_map(wks,chuvainst,opt)	
	

   soma(j,k) = wgt_areaave2(chuvainst, wgt, 0)  ; => qSum(ntim, klev)
j=j+1

	else

		;map_mask  = gsn_csm_contour_map(wks,chuva(i,:,:),opt)	

   soma(j,k) = wgt_areaave2(chuva(i,:,:), wgt, 0)  ; => qSum(ntim, klev)

j=j+1

	end if



	end do 


delete(chuva)
delete(times)
end do

opt2 = True
opt2@gsnMaximize = True
opt2@gsnFrame = False

opt2@tiXAxisFont = 0
        opt2@xyDashPatterns = (/ 1.,3.,12.,15.,14.,0.,16./)
opt2@xyExplicitLegendLabels = (/"8/00", "8/12","9/00","9/12","10/00","10/12","Observ"/)
  	opt2@pmLegendDisplayMode    = "Always"   ; Display a legend.
  	opt2@pmLegendWidthF         = 0.12        ; Make it smaller
  	opt2@pmLegendHeightF        = 0.2        ; Make it smaller
  	opt2@pmLegendOrthogonalPosF = -1.35      ; Move into to plot  	
	opt2@pmLegendParallelPosF   = 1.3   ; Move to right
  	opt2@lgPerimOn              = False      ; No legend perimeter.
	opt2@lgLabelFont = 0  	
	opt2@lgLabelFontHeightF     = 0.02
	opt2@lgItemPlacement = "ExplicitPlacement"
                        opt2@lgItemPositions = (/ 0, 0.15, 0.3, 0.45, 0.60/)
	opt2@lgLabelFontThicknessF  = 4
	opt2@tmXBLabelFont = 0 
	opt2@tmXBLabelStride = 1	
	opt2@tmXBLabelFontThicknessF = 4
	opt2@tmXBLabelFontHeightF = 0.012
	opt2@tiXAxisFontHeightF = 0.03
     
	opt2@xyLineThicknessF = 5.

        opt2@tmXTBorderOn = False
        opt2@tmYRBorderOn = False
opt2@tmXTOn = False
        opt2@tmYROn = False
	opt2@tmXBMode= "Explicit"
	opt2@tmXBValues = (/0,24,48,72,96/)
	opt2@tmXBLabels = (/"08/03 00UTC", "09/03 00UTC ", "10/03 00UTC ","11/03 00UTC ","12/03 00UTC"/)

     opt2@xyLineColors = (/ "blue","red","green","orange","purple","yellow","violet"/)

	opt2@tiXAxisFontThicknessF = 4
;---------------------------------------------
	opt2@tmXBMajorThicknessF = 4
	opt2@tmBorderThicknessF = 4
;-------------Configuração para o eixo y------------
	opt2@tmYLMinorOn = False
	opt2@tmYLLabelFontHeightF = 0.03
	opt2@tmYLLabelFont = 0 
	opt2@tmYLLabelFontThicknessF = 4
	opt2@tiYAxisFontHeightF = 0.05
;---------------------------------------------
	opt2@tiYAxisFont = 0
	opt2@tiYAxisFontThicknessF = 4
;---------------------------------------------
	opt2@tmYLMajorThicknessF = 4
	opt2@tiXAxisString = "Horas" 
	opt2@tiYAxisString = "Precipita"+cedil+atilde+"o (mm)" 

 opt2@tiYAxisFontHeightF = 0.03
    
soma2(:,0) = soma(:,0)
soma2(:,6) = soma(:,6)

do i = 0,84

soma2(i+12,1) = soma(i,1)

end do

do i = 0,72
soma2(i+24,2) = soma(i,2)
end do

do i = 0,60
soma2(i+36,3) = soma(i,3)
end do

do i = 0,48
soma2(i+48,4) = soma(i,4)
end do

do i = 0,36
soma2(i+60,5) = soma(i,5)
end do

write_matrix(soma2,"9f7.2",False)

rainpose = transpose(soma2)

  plot = gsn_csm_y(wks,rainpose,opt2)


frame(wks)

;ind96 = ind(soma2(:,0) .eq. max(soma2(:,0)))

;ind72 = ind(soma2(:,1) .eq. max(soma2(:,1)))-24

;ind42 = ind(soma2(:,2) .eq. max(soma2(:,2)))

;indobs = ind(soma2(:,3) .eq. max(soma2(:,3)))

 ; times96 = wrf_user_getvar(dados[0],"times",-1)  ; get all times in the file

;print("PICO OBSERVADO")
;print(times96(indobs)+"")
    


;times72 = wrf_user_getvar(dados[1],"times",-1)  ; get all times in the file


;print("PICO 72 HORAS")
;print(times72(ind72)+"")
    

 ; times42 = wrf_user_getvar(dados[2],"times",-1)  ; get all times in the file

;print(ind96+" "+ind72+" "+ind42+" "+indobs)
;print(max(soma2(:,0))+" "+max(soma2(:,1))+" "+max(soma2(:,2))+" "+max(soma2(:,3)))

  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
