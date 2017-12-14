loadscript("configraph.ncl")
external PROGRESSBAR "./progressbar.so"
external Prev_conjuto "./sum_area.so"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
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
 
   lat1 = dados[0]->XLAT(0,:,:)
   lon1 = wrf_user_getvar(dados[0],"XLONG",0)
k=0


Times = dados[0]->Times                    ; Times(Time, DateStrLen)    (type character)
tempo = round(wrf_times_c(Times,0),3)
ntimes = dimsizes(tempo)

ETS = new((/ntimes,109,89/),"float")
chuva = new((/dimsizes(files),ntimes,109,89/),"float")	

lonnew = ispan( -4715, -4615, 16  )/100.
latnew = ispan( -2350, -2450, 16  )/100.

j=0




 		; Get non-convective, convective 
  		; Calculate total precipitation
    		rain_exp = wrf_user_getvar(dados[k],"RAINNC",-1)
    		rain_con = wrf_user_getvar(dados[k],"RAINC",-1)
    		rain_tot = rain_exp + rain_con
      		rain_tot@description = "Total precipitado"

    
inst = new( (/dimsizes(rain_tot(:,0,0)), dimsizes(rain_tot(0,:,0)), dimsizes(rain_tot(0,0,:)) /), \
           "float")
   		
      lat2d = wrf_user_getvar(dados[k],"XLAT",0)
  		 lon2d = wrf_user_getvar(dados[k],"XLONG",0)

    do i = 0,dimsizes(inst(:,0,0))-1        
        
        if (i .gt. 0) then
          ; write branch
       
                inst(j,:,:) = rain_tot(i,:,:) - rain_tot(i-1,:,:) 
                j=j+1           
            else
                inst(j,:,:) = rain_tot(i,:,:)
                j=j+1


            end if

    
    end do


;    PROGRESSBAR::progress(k,dimsizes(files))
     Prev_conjuto::acum_chuva(inst,rain_tot,dimsizes(rain_tot(:,0,0)), dimsizes(rain_tot(0,:,0)), dimsizes(rain_tot(0,0,:)),1)




  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")
exit()
j=0


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



copy_VarCoords(rain_exp(0,:,:,:),Prob)


Prob!0 = "time"
Prob!2 = "lon"
Prob!1 = "lat"
Prob&lon = lon1(0,:)
Prob&lat = lat1(:,0)
Prob&lat@units = "degrees_north"
Prob&lon@units = "degrees_east"


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
