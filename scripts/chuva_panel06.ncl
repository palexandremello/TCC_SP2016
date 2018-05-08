loadscript("configraph.ncl")

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin

      start_cpu_time = get_cpu_time()    


atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
files = systemfunc("ls $HOME/TCC_RODADAS/MEM*/wrfout_d01_2016-03-09_12:*")
nfiles = dimsizes(files)


filename = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"



dados     = addfiles(files,"r")
ListSetType(dados,"join")
 

Times = dados[0]->Times                    ; Times(Time, DateStrLen)    (type character)
tempo = round(wrf_times_c(Times,0),3)
nTimes = dimsizes(tempo)
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
        rainExp = wrf_user_getvar(dados,"RAINNC",-1)
        rainCon = wrf_user_getvar(dados,"RAINC",-1)
        rainTot = rainExp + rainCon
        rainTot@description = "Total precipitado"

delete(rainCon)
delete(rainExp)
   
   ;INST(MEMBROS,TEMPO,LAT,LON)   
inst = new( (/dimsizes(rainTot(:,0,0,0)), dimsizes(rainTot(0,:,0,0)), dimsizes(rainTot(0,0,:,0)),\
              dimsizes(rainTot(0,0,0,:)) /),"float")

; SOMA(NTEMPO,MEMBROS+OBS)
soma = new( (/(dimsizes(rainTot(0,:,0,0))/6)-1,dimsizes(rainTot(:,0,0,0))+1 /),"float")

acum06 = new( (/dimsizes(rainTot(:,0,0,0)), (dimsizes(rainTot(0,:,0,0))/6)-1, dimsizes(rainTot(0,0,:,0)),\
              dimsizes(rainTot(0,0,0,:)) /),"float")

acum06= 0

if (str_concat(t(0,8:9)) .eq. "08" .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-08 00:00:00"
wks = gsn_open_wks("pdf","rain06_0800")


acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acumInd,0:18)+"")

f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0800.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0800.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


    else if (str_concat(t(0,8:9)) .eq. "08" \
             .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-08 12:00:00"
wks = gsn_open_wks("pdf","rain06_0812")

acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acumInd,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0812.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0812.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


      else if (str_concat(t(0,8:9)) .eq. "09" \
               .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-09 00:00:00"
wks = gsn_open_wks("pdf","rain06_0900")

acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acumInd,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0900.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0900.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

          
            else if (str_concat(t(0,8:9)) .eq. "09" \
                      .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-09 12:00:00"
wks = gsn_open_wks("pdf","rain06_0912")

acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acumInd,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0912.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0912.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


                  else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-10 00:00:00"
wks = gsn_open_wks("pdf","rain06_1000")

acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acumInd,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_1000.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_1000.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      

                      else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "12" ) then

wks = gsn_open_wks("pdf","rain06_1012")

            units = "hours since 2016-03-10 12:00:00"
            acumInd = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
            print(t(acumInd,0:18)+"")
            f=systemfunc("ls $HOME/TCC_SP2016/cemaden_"+\
                         "acumulados/acum06_1012.dat")

            dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_"+\
                             "acumulados/acum06_1012.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      
                        end if

                    end if


              end if

                  

      end if

      end if

      end if

        


    do i = 0,dimsizes(inst(0,:,0,0))-1  ; do -> 4 até NTEMPO       
        
        if (i .gt. 0) then
          ; write branch
       
                inst(:,j,:,:) = rainTot(:,i,:,:) - rainTot(:,i-1,:,:) 
                j=j+1           
            else
                inst(:,j,:,:) = rainTot(:,i,:,:)
                j=j+1


            end if

    
    end do

    delete(rainTot)


j=0
    do i = 4,dimsizes(inst(0,:,0,0))-1,6  ; do -> 4 até NTEMPO       


        if (i .eq. acumInd) then

    
                print(t(acumInd,0:18)+"  "+t(nTimes-1,0:18)+"")
                acum06(:,j,:,:) = dim_sum_n(inst(:,acumInd:nTimes-1,:,:),1) 
                break
         else
    

                print(t(i,0:18)+"  "+t(i+5,0:18)+"")
                print(i+" "+(i+5))         
               acum06(:,j,:,:) = dim_sum_n(inst(:,i:i+5,:,:),1) 
                j=j+1  
        end if

    
    end do

delete(inst)



acum06!0 = "MEMBROS"
acum06!1 =  "tempo"
acum06!2 =  "lat"
acum06!3 =   "lon"
acum06&tempo = ispan(0,dimsizes(acum06(0,:,0,0))-1,1)
acum06&lat = lat2d(:,0)
acum06&lon = lon2d(0,:)
acum06&lat@units = "degrees_north"
acum06&lon@units = "degrees_east"
acum06@lat2d = lat2d
acum06@lon2d = lon2d



graph = new((/  dimsizes(acum06(:,0,0,0)), 4 /), graphic)

opt@cnMinLevelValF = 1
opt@cnMaxLevelValF = 50
opt@cnLevelSpacingF = 4

do j = 0, dimsizes(acum06(:,0,0,0))-1
  

  p = 0  
  do i = 0, dimsizes(acum06&tempo)-1

    
    if ( i .ge.  dimsizes(acum06&tempo)-5 \
           .and. i .le. dimsizes(acum06&tempo)-2  ) then 

            print("membro = "+(j+1)+" Time = "+i)
             graph(j,p) = gsn_csm_contour_map(wks,acum06(j,i,:,:),opt)
             p=p+1    
    end if



    end do
end do

dum = new((/4,dimsizes( acum06(:,0,0,0) ),4/),graphic) ; VARIAVEL GRAFICA (LINHAS_DO_QUADRADO,MEMBROS,TEMPO)

delete(acum06)

do i = 0,3
  do v = 0,5    
        do c = 0,3

              dum(c,v,i) =gsn_add_polyline(wks,graph(v,i),xpts(c:c+1),ypts(c:c+1),resp)
      
        end do  
  end do
end do

panel@gsnPanelFigureStrings= (/"mem1","mem2","mem3","mem4","mem5","mem6"/) ; add strings to panel

            gsn_panel(wks, graph(:,0), (/2,3/), panel)
            gsn_panel(wks, graph(:,1), (/2,3/), panel)


            gsn_panel(wks, graph(:,2), (/2,3/), panel)
            gsn_panel(wks, graph(:,3), (/2,3/), panel)


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end

