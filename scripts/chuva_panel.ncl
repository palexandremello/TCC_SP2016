loadscript("configraph.ncl")

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin

      start_cpu_time = get_cpu_time()    


atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
files = systemfunc("ls $HOME/TCC_RODADAS/MEM*/wrfout_d01_2016-03-10_12:*")
nfiles = dimsizes(files)


filename = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"



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


xpts = (/ min(lon),min(lon),max(lon),max(lon),min(lon)/)
ypts = (/ min(lat),max(lat),max(lat),min(lat),min(lat)/)




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
wks = gsn_open_wks("pdf","rain_0800")


acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")

f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0800.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0800.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


    else if (str_concat(t(0,8:9)) .eq. "08" \
             .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-08 12:00:00"
wks = gsn_open_wks("pdf","rain_0812")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0812.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0812.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


      else if (str_concat(t(0,8:9)) .eq. "09" \
               .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-09 00:00:00"
wks = gsn_open_wks("pdf","rain_0900")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0900.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0900.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

          
            else if (str_concat(t(0,8:9)) .eq. "09" \
                      .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-09 12:00:00"
wks = gsn_open_wks("pdf","rain_0912")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_0912.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_0912.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


                  else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-10 00:00:00"
wks = gsn_open_wks("pdf","rain_1000")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum12_1000.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum12_1000.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      

                      else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "12" ) then

wks = gsn_open_wks("pdf","rain_1012")

            units = "hours since 2016-03-10 12:00:00"
            acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
            print(t(acum_ind,0:18)+"")
            f=systemfunc("ls $HOME/TCC_SP2016/cemaden_"+\
                         "acumulados/acum12_1012.dat")

            dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_"+\
                             "acumulados/acum12_1012.dat | awk '{print $1 FS $8}'")

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



acum12!0 = "MEMBROS"
acum12!1 =  "tempo"
acum12!2 =  "lat"
acum12!3 =   "lon"
acum12&tempo = ispan(0,dimsizes(acum12(0,:,0,0))-1,1)
acum12&lat = lat2d(:,0)
acum12&lon = lon2d(0,:)
acum12&lat@units = "degrees_north"
acum12&lon@units = "degrees_east"
acum12@lat2d = lat2d
acum12@lon2d = lon2d



graph = new((/  dimsizes(acum12(:,0,0,0)), 2 /), graphic)

opt@cnMinLevelValF = 1
opt@cnMaxLevelValF = 50
opt@cnLevelSpacingF = 9

do j = 0, dimsizes(acum12(:,0,0,0))-1
  

  p = 0  
  do i = 0, dimsizes(acum12&tempo)-1

    
    if ( i .ge.  dimsizes(acum12&tempo)-3 \
           .and. i .le. dimsizes(acum12&tempo)-2  ) then 

            print("membro = "+(j+1)+" Time = "+i)
             graph(j,p) = gsn_csm_contour_map(wks,acum12(j,i,:,:),opt)
             p=p+1    
    end if



    end do
end do

dum = new((/4,dimsizes( acum12(:,0,0,0) ),2/),graphic) ; VARIAVEL GRAFICA (LINHAS_DO_QUADRADO,MEMBROS,TEMPO)

delete(acum12)

do i = 0,1
  do v = 0,5    
        do c = 0,3

              dum(c,v,i) =gsn_add_polyline(wks,graph(v,i),xpts(c:c+1),ypts(c:c+1),resp)
      
        end do  
  end do
end do

panel@gsnPanelFigureStrings= (/"mem1","mem2","mem3","mem4","mem5","mem6"/) ; add strings to panel

            gsn_panel(wks, graph(:,0), (/2,3/), panel)
            gsn_panel(wks, graph(:,1), (/2,3/), panel)


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end

