loadscript("configraph.ncl")

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin

	  start_cpu_time = get_cpu_time()    

wks = gsn_open_wks("pdf","PROB")

atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
files = systemfunc("ls $HOME/TCC_RODADAS/MEM*/wrfout_d01_2016-03-10_00:*")
nfiles = dimsizes(files)


filename = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"

ini=(/0.1,10,20, 30,40/)
fin=(/10,20,30,40,50/)



dados     = addfiles(files,"r")
ListSetType(dados,"join")
 

Times = dados[0]->Times                    ; Times(Time, DateStrLen)    (type character)
tempo = round(wrf_times_c(Times,0),3)
ntimes = dimsizes(tempo)
lat2d = wrf_user_getvar(dados[0],"XLAT",0)
lon2d = wrf_user_getvar(dados[0],"XLONG",0)

t = wrf_user_getvar(dados[0], "Times", -1)

lon = ispan( -4715, -4615, 16 )/100.
lat = ispan( -2400, -2300, 16 )/100.

j=0

; Get non-convective, convective 
      ; Calculate total precipitation
        rain_exp = wrf_user_getvar(dados,"RAINNC",-1)
        rain_con = wrf_user_getvar(dados,"RAINC",-1)
        rain_tot = rain_exp + rain_con
        rain_tot@description = "Total precipitado"

delete(rain_con)
delete(rain_exp)
   
   ;INST(MEMBROS,TEMPO,LAT,LON)   
inst = new( (/dimsizes(rain_tot(:,0,0,0)), dimsizes(rain_tot(0,:,0,0)), dimsizes(rain_tot(0,0,:,0)),\
              dimsizes(rain_tot(0,0,0,:)) /),"float")

; SOMA(NTEMPO,MEMBROS+OBS)
soma = new( (/dimsizes(rain_tot(0,:,0,0))/12,dimsizes(rain_tot(:,0,0,0))+1 /),"float")

acum12 = new( (/dimsizes(rain_tot(:,0,0,0)), dimsizes(rain_tot(0,:,0,0))/12, dimsizes(rain_tot(0,0,:,0)),\
              dimsizes(rain_tot(0,0,0,:)) /),"float")

acum12= 0

if (str_concat(t(0,8:9)) .eq. "08" .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-08 00:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")

f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0800.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0800.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


    else if (str_concat(t(0,8:9)) .eq. "08" \
             .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-08 12:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0812.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0812.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


      else if (str_concat(t(0,8:9)) .eq. "09" \
               .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-09 00:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0900.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0900.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

          
            else if (str_concat(t(0,8:9)) .eq. "09" \
                      .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-09 12:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0912.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0912.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


                  else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-10 00:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_1000.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_1000.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      

                      else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-10 12:00:00"

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_1012.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_1012.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      
                        end if

                    end if


              end if

                  

      end if

      end if

      end if

 		


    do i = 0,dimsizes(inst(0,:,0,0))-1  ; do -> 1 até NTEMPO       
        
        if (i .gt. 0) then
          ; write branch
       
                inst(:,j,:,:) = rain_tot(:,i,:,:) - rain_tot(:,i-1,:,:) 
                j=j+1           
            else
                inst(:,j,:,:) = rain_tot(:,i,:,:)
                j=j+1


            end if

    
    end do

    delete(rain_tot)


j=0
    do i = 4,dimsizes(inst(0,:,0,0))-1,12  ; do -> 1 até NTEMPO       


        if (i .eq. acum_ind) then

    
                print(t(acum_ind,0:18)+"  "+t(ntimes-1,0:18)+"")
                acum12(:,j,:,:) = dim_sum_n(inst(:,acum_ind:ntimes-1,:,:),1) 
                break
         else
    

                print(t(i,0:18)+"  "+t(i+11,0:18)+"")
                print(i+" "+(i+11))         
               acum12(:,j,:,:) = dim_sum_n(inst(:,i:i+11,:,:),1) 
                j=j+1  
        end if

    
    end do

delete(inst)



Prob = prob_forecasting_2limits(acum12,ini,fin)

delete(acum12)

Prob!0 = "limites"
Prob!1 =  "tempo"
Prob!2 =  "lat"
Prob!3 =   "lon"
Prob&lat = lat2d(:,0)
Prob&lon = lon2d(0,:)
Prob@lat2d = lat2d
Prob@lon2d = lon2d
Prob&lat@units = "degrees_north"
Prob&lon@units = "degrees_east"


do i = 0,dimsizes(ini)-1


    do k = 0,dimsizes(Prob(0,:,0,0))-1

opt@tiMainString = "["+ini(i)+":"+fin(i)+")"

        if ( k .ge. 2 .and. k .le. 3 ) then

        plot = gsn_csm_contour_map(wks,Prob(i,k,:,:),opt)

        draw(plot)
        frame(wks)
      else
        print("nao plotando "+k)
      end if

    end do 
end do





  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
