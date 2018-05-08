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


filename = "$HOME/TCC_SP2016/SP_munproj/35MUE250GC_SIR.shp"

ini=(/0,  3, 5, 10,  20/)
fin=(/3 , 5, 10, 20, 40/)



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
soma = new( (/(dimsizes(rain_tot(0,:,0,0))/6)-1,dimsizes(rain_tot(:,0,0,0))+1 /),"float")

acum06 = new( (/dimsizes(rain_tot(:,0,0,0)), (dimsizes(rain_tot(0,:,0,0))/6)-1, dimsizes(rain_tot(0,0,:,0)),\
              dimsizes(rain_tot(0,0,0,:)) /),"float")

acum06= 0

if (str_concat(t(0,8:9)) .eq. "08" .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-08 00:00:00"
wks = gsn_open_wks("pdf","ETS06__0800")


acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")

f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0800.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0800.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


    else if (str_concat(t(0,8:9)) .eq. "08" \
             .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-08 12:00:00"
wks = gsn_open_wks("pdf","ETS06__0812")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0812.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0812.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


      else if (str_concat(t(0,8:9)) .eq. "09" \
               .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-09 00:00:00"
wks = gsn_open_wks("pdf","ETS06__0900")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0900.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0900.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

          
            else if (str_concat(t(0,8:9)) .eq. "09" \
                      .and. str_concat(t(0,11:12)) .eq. "12" ) then

units = "hours since 2016-03-09 12:00:00"
wks = gsn_open_wks("pdf","ETS06__0912")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_0912.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_0912.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")


                  else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "00" ) then

units = "hours since 2016-03-10 00:00:00"
wks = gsn_open_wks("pdf","ETS06__1000")

acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
print(t(acum_ind,0:18)+"")
f=systemfunc("ls $HOME/TCC_SP2016/cemaden_acumulados/acum06_1000.dat")

dim = systemfunc("wc $HOME/TCC_SP2016/cemaden_acumulados/acum06_1000.dat | awk '{print $1 FS $8}'")

soma(:,dimsizes(soma(0,:))-1) = asciiread(f, (/toint(dim)/),"float")

                      

                      else if (str_concat(t(0,8:9)) .eq. "10" \
                          .and. str_concat(t(0,11:12)) .eq. "12" ) then

wks = gsn_open_wks("pdf","ETS06__1012")

            units = "hours since 2016-03-10 12:00:00"
            acum_ind = ind(cd_inv_calendar(2016, 3, 11, 16, 0, 0, units, 0) .eq. tempo )
            print(t(acum_ind,0:18)+"")
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
    do i = 4,dimsizes(inst(0,:,0,0))-1,6  ; do -> 1 até NTEMPO       


        if (i .eq. acum_ind) then

    
                print(t(acum_ind,0:18)+"  "+t(ntimes-1,0:18)+"")
                acum06(:,j,:,:) = dim_sum_n(inst(:,acum_ind:ntimes-1,:,:),1) 
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
acum06&lat = lat2d(:,0)
acum06&lon = lon2d(0,:)
acum06&lat@units = "degrees_north"
acum06&lon@units = "degrees_east"
acum06@lat2d = lat2d
acum06@lon2d = lon2d

printVarSummary(acum06)
soma(:,0:5) = chuva_medianaarea(acum06,lat,lon,lat2d,lon2d)
somaDois = chuva_medianaareaNOLOOP(acum06,lat,lon,lat2d,lon2d)

soma!0 = "tempo"
soma!1 =  "membros_obs"
soma&tempo = ispan(0,dimsizes(soma(:,0))-1,1)

print(soma&tempo)

;graph = new((/  dimsizes(acum06(:,0,0,0)), dimsizes( acum06(0,:,0,0)) /), graphic)
          
;do j = 0, dimsizes(acum06(:,0,0,0))-1
;  do i = 0, dimsizes( acum06(0,:,0,0) )-1
;      print("membro = "+(j+1)+" Time = "+i)
;      graph(j,i) = gsn_csm_contour_map(wks,acum06(j,i,:,:),opt)
      
;  end do
;end do

delete(acum06)
write_matrix(soma, "7f7.2", False)
write_matrix(somaDois, "7f7.2", False)

 ; gsn_panel(wks, graph, (/3,2/), panel)

plot = gsn_csm_y(wks,transpose(soma),opt2)
plot2 = gsn_csm_y(wks,transpose(somaDois),opt2)

draw(plot)
frame(wks)

draw(plot2)
frame(wks)

Bias = new((/ dimsizes(ini), dimsizes(soma(0,0:5)) /),"float",9.96921e+36 )
ETS06_ = new((/ dimsizes(ini), dimsizes(soma(0,0:5)) /),"float",9.96921e+36 )


do i = 0,dimsizes(soma(0,0:5))-1 ; MEMBROS

  do j = 0,dimsizes(ini)-1
        a=0
        b=0
        c=0
        d=0

  print("membro = "+(i+1))
      do k = 0,dimsizes(soma(:,0))-1
        

     ; print(k .ge.  dimsizes(soma&tempo)-5 .and. k .le. dimsizes(soma&tempo)-2+"")
      print((dimsizes(soma&tempo)-5)+" "+(dimsizes(soma&tempo)-2))
     
      ; SE K > 10 (acumulado 10) e menor que acumulado 13 (6 em 6 horas)

      if ( k .ge.  dimsizes(soma&tempo)-5 \
           .and. k .le. dimsizes(soma&tempo)-2  ) then 

          if( soma(k,i) .ge. ini(j)  .and. soma(k,i) .lt. fin(j) \ 
              .and. soma(k,6) .ge. ini(j)  \ 
              .and. soma(k,6) .lt. fin(j)) then
      
                  a = a+1 ;LEITURA DO A
      
           end if  

            if(.not.(soma(k,6) .ge. ini(j) .and. soma(k,6) .lt. fin(j) ) \
              .and. soma(k,i) .ge. ini(j)  \
              .and. soma(k,i) .lt. fin(j)) then
        
              b = b+1 ;LEITURA DO B
      
            end if

            if(.not. (soma(k,i) .ge. ini(j) .and.soma(k,i) .lt. fin(j)) \ 
               .and. soma(k,6) .ge. ini(j) \
               .and. soma(k,6) .lt. fin(j)) then

              c = c+1 ;LEITURA DO C
            
             end if

            if( .not. ( soma(k,i) .ge. ini(j) .and. soma(k,i) .lt. fin(j) ) \
                .and. .not.  (soma(k,6) .ge. ini(j) \
                .and. soma(k,6) .lt. fin(j) )) then 

              d = d+1  ; LEITURA DO D

            end if

        end if

      end do
      
      ;print(a+" "+b+" "+c+" "+d)
      Bias(j,i) = a+b/where( (a+c) .eq. 0, Bias@_FillValue,(a+c))
      aref = ((a+b)*(a+c))/(dimsizes(soma(:,0)))
      ETS06_(j,i) = (a-aref)/where( (a-aref+b+c) .eq. 0, ETS06_@_FillValue,(a-aref+b+c))

      
          print(ETS06_(j,i)+"")
      
  end do

end do 

    option@tmXBLabels = (/"["+ini(0)+":"+fin(0)+")","["+ini(1)+":"+fin(1)+")"\
                         ,"["+ini(2)+":"+fin(2)+")","["+ini(3)+":"+fin(3)+")"\
                         ,"["+ini(4)+":"+fin(4)+")" /)


plot = gsn_csm_y(wks,transpose(Bias),option)
draw(plot)
frame(wks)


    option@trYMaxF = 1
    
  ;  option@trYMinF = -0.33


plot = gsn_csm_y(wks,transpose(ETS06_),option)
draw(plot)
frame(wks)



  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
