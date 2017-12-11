
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;Media na área para acumulado de 12hr

	  start_cpu_time = get_cpu_time()    

	wks = gsn_open_wks("pdf","acumulado12hr_medianaarea0912")
	 
	atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
	cedil = "c~H-13F35~K~FH2~" ; ç
	files = systemfunc("ls ~/TCC_RODADAS/*/wrfout_d01_2016-*")
	nfiles = dimsizes(files)

	filename = "./35MUE250GC_SIR.shp"

	iq = ind(files .eq. "/home/paulo/TCC_RODADAS/MEM1/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM2/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM4/wrfout_d01_2016-03-09_12:00:00".or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM5/wrfout_d01_2016-03-09_12:00:00".or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM6/wrfout_d01_2016-03-09_12:00:00")


	niq = dimsizes(iq)

	opt = True
	opt@gsnAddCyclic = False
	opt@gsnMaximize = True
	opt@gsnDraw = False
	opt@gsnFrame = False  
	opt@mpOutlineOn           = True
	opt@mpDataBaseVersion     = "MediumRes"
	opt@mpOutlineBoundarySets = "AllBoundaries"
	opt@pmTickMarkDisplayMode = "Always"
	opt@mpDataSetName = "Earth..4"
	opt@mpFillColor = -1
	opt@mpMonoFillColor = True
	opt@cnLevelSelectionMode = "ManualLevels"
	opt@cnMinLevelValF = 0
	opt@cnMaxLevelValF = 100
	opt@cnLevelSpacingF = 10

	opt@mpNationalLineThicknessF = 3   
	opt@mpMinLatF = -23.50
	opt@mpMaxLatF = -23
	opt@mpMinLonF = -47.15
	opt@mpMaxLonF = -46

	opt@tiMainString = "Probabilidade Chuva 5mm < x < 10mm"


	dados     = addfiles(files(iq),"r")

	 lat1 = dados[0]->XLAT(0,:,:)
	   lon1 = wrf_user_getvar(dados[0],"XLONG",0)

	times = wrf_user_list_times(dados[0]) 
	ntimes = dimsizes(times)

	dadosEM     = addfiles(files(iq),"r")
	ListSetType (dadosEM,"join")


	    rain_exp = dadosEM[:]->RAINNC
	    rain_con = dadosEM[:]->RAINC
	    rain_tot = rain_exp + rain_con
	    copy_VarCoords(rain_exp,rain_tot)
	    rain_tot@description = "Total precipitado"

 j = 0


diaria = new((/6,4,109,89/),"float")
inst =   new((/6,ntimes,109,89/),"float")
acum12 = new((/6,ntimes/12,109,89/),"float")

acum12=0

;do k = 0,5
j=0
	do c = 0,ntimes-1
		if ( c .gt. 0)
				inst(:,j,:,:) = rain_tot(:,c,:,:) - rain_tot(:,c-1,:,:)
				j=j+1
		else
				inst(:,j,:,:) = rain_tot(:,c,:,:) 
		j=j+1		
		end if

	end do
;end do

printVarSummary(inst)
;
;do k = 0,5
j=0
c=0
	do i = 3,ntimes-1,12

		;print(times(c)+" "+times(c+11))
		
		if ( i .eq. 51 )
				print(times(51)+" "+times(ntimes-1))
				acum12(:,j,:,:) = dim_sum_n(inst(:,51:ntimes-1,:,:),1)
				print(j+"")

				break
		else
			       	 print(times(i)+" "+times(i+11))
				 acum12(:,j,:,:) = dim_sum_n(inst(:,i:i+11,:,:),1)
				print(j+"")				
				 j=j+1		
				
		end if
	end do
;end do


copy_VarCoords(rain_exp,inst)

inst!1 = "time"
inst!3 = "lon"
inst!2 = "lat"
inst&lon = lon1(0,:)
inst&lat = lat1(:,0)
inst&lat@units = "degrees_north"
inst&lon@units = "degrees_east"


acum12!1 = "time"
acum12!3 = "lon"
acum12!2 = "lat"
acum12&lon = lon1(0,:)
acum12&lat = lat1(:,0)
acum12&lat@units = "degrees_north"
acum12&lon@units = "degrees_east"

printVarSummary(acum12)
;  do i = 0,ntimes-1
;opt@gsnLeftString = times(i)
;print(times(i)+"")
;	plot = gsn_csm_contour_map(wks,inst(0,i,:,:),opt)
;draw(plot)
;frame(wks)
	  
 ;  end do


 ;do k = 0,5
  ;  j=0	
;	do i = 3,ntimes-1,24
	
;	if ( i .eq. 75) then

;		diaria(k,j,:,:) = dim_sum_n(inst(k,75:96,:,:),0)
	
;	else
	
;		diaria(k,j,:,:) = dim_sum_n(inst(k,0:i+24,:,:),0)

;	end if	
	
;	end do
;	delete(j)
;	  end do


Prob = new((/ntimes,109,89/),"float")
	
	do k = 0,ntimes-1
			do it = 0,108

			  	do i = 0,88			

					Prob(k,it,i) =  ((num(rain_tot(:,k,it,i) .gt. 25 )/6.))*100.		
					
				end do
		
				
			end do
	end do

copy_VarCoords(rain_exp(0,:,:,:),Prob)

   lat2d = wrf_user_getvar(dados[0],"XLAT",0)
   lon2d = wrf_user_getvar(dados[0],"XLONG",0)
   
   lonEM = ispan( -4715, -4615, 16 )/100.
   latEM = ispan( -2380, -2300, 16 )/100.

  rain_totEM = dim_avg_n_Wrap(rain_tot,0)
  rain_totESP= dim_stddev_n_Wrap(rain_tot,0)
chuvaEM = rcm2rgrid(lat2d,lon2d,rain_totEM,latEM,lonEM,0)



delete(rain_exp)
delete(rain_con)
delete(rain_tot)


chuvaEM!0 = "time"
chuvaEM!2 = "lon"
chuvaEM!1 = "lat"
chuvaEM&lon = lonEM
chuvaEM&lat = latEM
chuvaEM&lat@units = "degrees_north"
chuvaEM&lon@units = "degrees_east"


Prob!0 = "time"
Prob!2 = "lon"
Prob!1 = "lat"
Prob&lon = lon1(0,:)
Prob&lat = lat1(:,0)
Prob&lat@units = "degrees_north"
Prob&lon@units = "degrees_east"




soma = new((/ntimes/12,7/),"float",-99.9)
  soma@_FillValue = -99.9   ; identificação de falta de dados
soma(:,6) = asciiread("acum12_0912.dat",(/ntimes/12/),"float")

soma2 = new((/ntimes/12,7/),"float",-99.9)
  soma2@_FillValue = -99.9   ; identificação de falta de dados

lonnew = ispan( -4715, -4615, 16  )/100.
latnew = ispan( -2400, -2300, 16  )/100.


do k = 0,niq-1





 ; Get non-convective, convective 
  ; Calculate total precipitation
    rain_exp = wrf_user_getvar(dados[k],"RAINNC",-1)
    rain_con = wrf_user_getvar(dados[k],"RAINC",-1)
    rain_tot = rain_exp + rain_con
      rain_tot@description = "Total precipitado"

   lat2d = wrf_user_getvar(dados[k],"XLAT",0)
   lon2d = wrf_user_getvar(dados[k],"XLONG",0)
   


chuva = rcm2rgrid(lat2d,lon2d,acum12(k,:,:,:),latnew,lonnew,0)


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
dlat = latnew(2) - latnew(1)


   dx   = con * dlon * clat        ; dx at each latitude
   dy   = con * dlat               ; dy is constant
   dydx = dy * dx  

   wgt  = new((/dimsizes(latnew), dimsizes(lonnew)/), typeof(chuva))

   wgt  = conform(wgt, dydx, 0)


	       

j = 0

	do i = 0,4

 
	;if (i .gt. 0)
	;	chuvainst = chuva(i,:,:) - chuva(i-1,:,:)
	;	chuvaEMinst = chuvaEM(i,:,:) - chuvaEM(i-1,:,:)
	;	copy_VarCoords(chuva(i,:,:),chuvainst)
	;copy_VarCoords(chuvaEM(i,:,:),chuvaEMinst)

		;map_mask  = gsn_csm_contour_map(wks,chuvaEMinst,opt)	
print(i+"")	

   soma(i,k) = wgt_areaave2(chuva(i,:,:), wgt, 0)  ; => qSum(ntim, klev)

   j=j+1

	;else

		;map_mask  = gsn_csm_contour_map(wks,chuvaEM(i,:,:),opt)	

;   soma(j,k) = wgt_areaave2(chuva(i,:,:), wgt, 0)  ; => qSum(ntim, klev)

;j=j+1

;	end if



	end do 


delete(chuva)

end do

;map = gsn_csm_map(wks,opt) 


;do i = 0,ntimes-1


		;opt@gsnLeftString = times(i)

		;opt@cnLinesOn = True
		

;	plot = gsn_csm_contour_map(wks,Prob(i,{-24:-23},{-48:-46}),opt)
  
lnres = True
lnres@gsLineColor = "Black"
lnres@gsLineThicknessF = 1.5

;linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

 ; draw(plot)
  ;frame(wks)


;end do


opt2 = True
opt2@gsnMaximize = True
opt2@gsnFrame = False

opt2@tiXAxisFont = 0
        opt2@xyDashPatterns = (/ 1.,3.,12.,15.,14.,0.,16./)
opt2@xyExplicitLegendLabels = (/"MEM1", "MEM2","MEM3","MEM4","MEM5","MEM6","Observ"/)
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
	opt2@tmXBValues = (/0,1,2,3,4/)
	opt2@tmXBLabels = (/"10/03 02UTC", "10/03 14UTC ", "11/03 02UTC ","11/03 14UTC","12/03 00UTC"/)

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

write_matrix(soma,"7f7.2",False)


rainpose = transpose(soma)

  plot = gsn_csm_y(wks,rainpose,opt2)

frame(wks)

  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
