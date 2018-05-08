loadscript("configraph.ncl")

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin

      start_cpu_time = get_cpu_time()    


atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
cedil = "c~H-13F35~K~FH2~" ; ç
files = systemfunc("ls $HOME/TCC_RODADAS/MEM*/wrfout_d01_2016-03-08_00:*")
nfiles = dimsizes(files)


fileName = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"



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
              dimsizes(rainTot(0,0,0,:)) /),"double")

; SOMA(NTEMPO,MEMBROS+OBS)
soma = new( (/dimsizes(rainTot(0,:,0,0))/24,dimsizes(rainTot(:,0,0,0))+1 /),"double")

rainDay = new( (/dimsizes(rainTot(:,0,0,0)), dimsizes(rainTot(0,:,0,0))/24, dimsizes(rainTot(0,0,:,0)),\
              dimsizes(rainTot(0,0,0,:)) /),"double")

rainDay= 0


        


    do i = 0,dimsizes(inst(0,:,0,0))-1  ; do -> 1 até NTEMPO       
        
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
    do i = 4,dimsizes(inst(0,:,0,0))-1,24  ; do -> 1 até NTEMPO       


        if (i .eq. 76) then

    
                ;print(t(acum_ind,0:18)+"  "+t(nTimes-1,0:18)+"")
                ;rainDay(:,j,:,:) = dim_sum_n(inst(:,acum_ind:nTimes-1,:,:),1) 
                ;break
         else
    

                print(t(i,0:18)+"  "+t(i+23,0:18)+"")
                print(i+" "+(i+23))         
               rainDay(:,j,:,:) = dim_sum_n(inst(:,i:i+23,:,:),1) 
                j=j+1  
        end if

    
    end do

delete(inst)



rainDay!0 = "MEMBROS"
rainDay!1 =  "tempo"
rainDay!2 =  "lat"
rainDay!3 =   "lon"
rainDay&tempo = ispan(0,dimsizes(rainDay(0,:,0,0))-1,1)
rainDay&lat = lat2d(:,0)
rainDay&lon = lon2d(0,:)
rainDay&lat@units = "degrees_north"
rainDay&lon@units = "degrees_east"
rainDay@lat2d = lat2d
rainDay@lon2d = lon2d

exit()

graph = new((/  dimsizes(rainDay(:,0,0,0)), 4 /), graphic)

opt@cnMinLevelValF = 1
opt@cnMaxLevelValF = 50
opt@cnLevelSpacingF = 4

do j = 0, dimsizes(rainDay(:,0,0,0))-1
  

  p = 0  
  do i = 0, dimsizes(rainDay&tempo)-1

    
    if ( i .ge.  dimsizes(rainDay&tempo)-5 \
           .and. i .le. dimsizes(rainDay&tempo)-2  ) then 

            print("membro = "+(j+1)+" Time = "+i)
             graph(j,p) = gsn_csm_contour_map(wks,rainDay(j,i,:,:),opt)
             p=p+1    
    end if



    end do
end do

dum = new((/4,dimsizes( rainDay(:,0,0,0) ),4/),graphic) ; VARIAVEL GRAFICA (LINHAS_DO_QUADRADO,MEMBROS,TEMPO)

delete(rainDay)

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

