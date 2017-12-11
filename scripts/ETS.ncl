loadscript("configraph.ncl")
external PROGRESSBAR "./cprogressbar.so"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin

	  start_cpu_time = get_cpu_time()    

wks = gsn_open_wks("pdf","$HOME/TCC_SP2016/saidas_graph/ETS_08")

atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
files = systemfunc("ls $HOME/TCC_RODADAS/MEM*/wrfout_d01_2016-03-08_00:*")
nfiles = dimsizes(files)


filename = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"

ini=(/0,5,10,15,20,25,30/)
fin=(/5,10,15,20,25,30,35/)



dados     = addfiles(files,"r")

printVarSummary(dados)
exit()
 lat1 = dados[0]->XLAT(0,:,:)
   lon1 = wrf_user_getvar(dados[0],"XLONG",0)

times = wrf_user_list_times(dados[0]) 



ETS = new((/ntimes,109,89/),"float")
chuva = new((/dimsizes(files),ntimes,109,89/),"float")	

lonnew = ispan( -4715, -4600, 16  )/100.
latnew = ispan( -2350, -2300, 16  )/100.

j=0

do k = 0,dimsizes(files)-1


 		; Get non-convective, convective 
  		; Calculate total precipitation
    		rain_exp = wrf_user_getvar(dados[k],"RAINNC",-1)
    		rain_con = wrf_user_getvar(dados[k],"RAINC",-1)
    		rain_tot = rain_exp + rain_con
      		rain_tot@description = "Total precipitado"

   		lat2d = wrf_user_getvar(dados[k],"XLAT",0)
  		 lon2d = wrf_user_getvar(dados[k],"XLONG",0)

		;chuva(j,:,:,:) = rcm2rgrid(lat2d,lon2d,rain_tot,latnew,lonnew,0)
j=j+1

	delete(rain_exp)
	delete(rain_con)
	delete(rain_tot)

	
    PROGRESSBAR::progress(k,dimsizes(files))


end do
exit()
	chuva!0 = "time"
		chuva!2 = "lon"
		chuva!1 = "lat"
		chuva&lon = lonnew
		chuva&lat = latnew
		chuva&lat@units = "degrees_north"
		chuva&lon@units = "degrees_east"
printVarSummary(chuva)

exit

do c = 0,6
	
	do k = 0,ntimes-1
			do it = 0,108

			  	do i = 0,88			

			;if( Pall(i,1,k) .ge. ini(j)  .and. Pall(i,1,k) .lt. fin(j) .and. pall(i,2,k) .ge. ini(j)  .and. pall(i,2,k) \
			;.lt. fin(j) ) then
					
					print(max(ETS))
				end do
		
				
			end do
	end do
end do

copy_VarCoords(rain_exp(0,:,:,:),Prob)


Prob!0 = "time"
Prob!2 = "lon"
Prob!1 = "lat"
Prob&lon = lon1(0,:)
Prob&lat = lat1(:,0)
Prob&lat@units = "degrees_north"
Prob&lon@units = "degrees_east"

;do i = 0,ntimes-1


;		opt@gsnLeftString = times(i)

;		opt@cnLinesOn = True
		

		
;		opt@cnLevelSelectionMode = "ManualLevels"
;		opt@cnMinLevelValF = 0
;		opt@cnMaxLevelValF = 100
;		opt@cnLevelSpacingF = 10
;
;		plot = gsn_csm_contour_map(wks,Prob(i,{-24:-23},{-48:-46}),opt)
;
;lnres = True
;lnres@gsLineColor = "Black"
;lnres@gsLineThicknessF = 1.5

;linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

 ; draw(plot)
 ; frame(wks)


;end do


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
