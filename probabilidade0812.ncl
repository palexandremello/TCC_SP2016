
begin

	 start_cpu_time = get_cpu_time()    

		atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
		cedil = "c~H-13F35~K~FH2~" ; ç
	
	files = systemfunc("ls ~/TCC_RODADAS/*/wrfout_d01_2016-*") ; LISTANDO TODAS AS SAIDAS
	nfiles = dimsizes(files) 				   ; WRFOUT E CRIANDO UMA VARIAVEL COM O TOTAL DE ARQUIVOS 

	filename = "./35MUE250GC_SIR.shp" ; associando um shapefile 

	iq = ind(files .eq. "/home/paulo/TCC_RODADAS/MEM1/wrfout_d01_2016-03-08_12:00:00" .or. files .eq. \
			    "/home/paulo/TCC_RODADAS/MEM2/wrfout_d01_2016-03-08_12:00:00" .or. files .eq. \ ;CRIANDO UM VETOR
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-08_12:00:00" .or. files .eq. \ ;COM TODOS OS INDICES
			    "/home/paulo/TCC_RODADAS/MEM4/wrfout_d01_2016-03-08_12:00:00".or. files .eq. \  ; DE TODOS OS WRFOUT
			    "/home/paulo/TCC_RODADAS/MEM5/wrfout_d01_2016-03-08_12:00:00".or. files .eq. \  ; DO DIA 8 AS 00 UTC
			    "/home/paulo/TCC_RODADAS/MEM6/wrfout_d01_2016-03-08_12:00:00")	
	niq = dimsizes(iq)

		wks = gsn_open_wks("pdf","prob812") ; CRIANDO UMA ÁREA GRÁFICA

;=========================================================
; CRIAND COORDENADA DE TEMPO ;
coordtemp = new((/4464/),"integer")
coordtemp = ispan(0,4463,1)

 units = "hours since 2016-03-01 00:00:0.0"
        coordtemp@units = units
        coordtemp@long_name = "tempo"
        coordtemp!0 = "tempo"
;=======================================================

;CONVERTENDO TODA COORDENADA DE TEMPO

	utc_date = cd_calendar(coordtemp,0)
	year  = tointeger(utc_date(:,0))
	month = tointeger(utc_date(:,1))
	day   = tointeger(utc_date(:,2))
	hour  = tointeger(utc_date(:,3))
	minute = tointeger(utc_date(:,4))
	seconds = utc_date(:,5)

			date_str = sprinti("%0.4i", year)+ "-" + \ ; CRIANDO UMA STRING COM ANO-MES-DIA H-M-S
			sprinti("%0.2i",month)+ "-" +sprinti("%0.2i",day)+ " " + sprinti("%0.2i",hour) + \ ; CRIANDO UMA STRING COM ANO-MES-DIA H-M-S
                        ":"+ sprinti("%0.2i",minute) ; CRIANDO UMA STRING COM ANO-MES-DIA H-M-S


; COORDENADAS QUE INDICAM A GRADE DO MODELO QUE SERÁ INTERPOLADA
; COM RESOLUÇÃO DE 16 KM

lonnew = ispan( -4715, -4600, 16 )/100. ; CRIANDO VETOR LON
latnew = ispan( -2400, -2300, 16 )/100. ; CRIANDO VETOR LAT


nlat = dimsizes(latnew)
nlon = dimsizes(lonnew)
; ===============================================================; 


cemadendiaria = asciiread("cemaden12h.dat",(/62,nlon,nlat/),"float")
 

cemadendiaria!0 = "time"
cemadendiaria!1 = "lon"
cemadendiaria!2 = "lat"
cemadendiaria&lon = lonnew
cemadendiaria&lat = latnew
cemadendiaria&lat@units = "degrees_north"
cemadendiaria&lon@units = "degrees_east"

printVarSummary(cemadendiaria)




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

opt@mpNationalLineThicknessF = 3   
opt@mpMinLatF = -23.80
opt@mpMaxLatF = -23.10
opt@mpMinLonF = -47.15
opt@mpMaxLonF = -46.15

opt@tiMainString = "Acumulado 12hr"


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

			Prob = new((/ntimes,109,89/),"float")
			inst =   new((/6,ntimes,109,89/),"float")
			diario = new((/6,4,109,89/),"float")
			wrf12  = new((/6,ntimes/12,109,89/),"float")
			wrf6  = new((/6,ntimes/6,109,89/),"float")
j=0
	do c = 0,ntimes-1,1


		if ( c .gt. 0) then

				inst(:,j,:,:) = rain_tot(:,c,:,:) - rain_tot(:,c-1,:,:) 
		j=j+1

		else

				inst(:,j,:,:) = rain_tot(:,c,:,:) 
				
		j=j+1		
		end if

	end do

delete(rain_tot)
delete(rain_exp)
delete(rain_con)

j=0
	do i = 2,ntimes-1,24
	

		if ( i .eq. 74) then
			
		
		print(times(74)+" "+times(ntimes-1))

				diario(:,j,:,:) = dim_sum_n(inst(:,74:ntimes-1,:,:),1)

				break
			else
			
	print(times(i)+" "+times(i+23))

	
				diario(:,j,:,:) = dim_sum_n(inst(:,i:i+23,:,:),1)
		
				j=j+1
		end if	
	
	end do



; ======================================================================================================
i=0
j=0

; WRF12 VARIAVEL QUE RECEBERÁ O ACUMULADO DE 12 EM 12H DE TODOS OS 6 MEMBROS DAS 8 OOUTC

		do i = 3,ntimes-1,12
			           		
				
			if ( i .eq. 75) then


		 	print(times(75)+" to "+times(ntimes-1))
			print(i+" "+(i+11))
			wrf12(:,j,:,:) = dim_sum_n(inst(:,75:ntimes-1,:,:),1)	
				 
			break
			
			else
	
				;print("membro"+(l))	
		  		   print(times(i)+" to "+times(i+11))	
				   print(i+" "+(i+11))
				   ;print(j+"")
				wrf12(:,j,:,:) = dim_sum_n(inst(:,i:i+11,:,:),1)
		
				j=j+1
			end if	

		
		end do
; ==========================================================================================	

; ======================================================================================================
i=0
j=0
i=0
; WRF12 VARIAVEL QUE RECEBERÁ O ACUMULADO DE 6 EM 6H DE TODOS OS 6 MEMBROS DAS 8 OOUTC

		do i = 3,ntimes-1,6
			           		
				
			if ( i .eq. 81) then


		  	print(times(81)+" to "+times(ntimes-1))
			
			wrf6(:,j,:,:) = dim_sum_n(inst(:,81:ntimes-1,:,:),1)	
				 
			break
			
			else
	
				;print("membro"+(l))	
		  	       ; print(times(i)+" to "+times(i+5))	
				   print(i+" "+(i+5))
				  ; print(j+"")
				wrf6(:,j,:,:) = dim_sum_n(inst(:,i:i+5,:,:),1)
		
				j=j+1
			end if	

		
		end do
; ==========================================================================================	



; ==========================================================================================
diario!1 = "time"
diario!3 = "lon"
diario!2 = "lat"
diario&lon = lon1(0,:)
diario&lat = lat1(:,0)
diario&lat@units = "degrees_north"
diario&lon@units = "degrees_east"

wrf12!1 = "time"
wrf12!3 = "lon"
wrf12!2 = "lat"
wrf12&lon = lon1(0,:)
wrf12&lat = lat1(:,0)
wrf12&lat@units = "degrees_north"
wrf12&lon@units = "degrees_east"


wrf6!1 = "time"
wrf6!3 = "lon"
wrf6!2 = "lat"
wrf6&lon = lon1(0,:)
wrf6&lat = lat1(:,0)
wrf6&lat@units = "degrees_north"
wrf6&lon@units = "degrees_east"

; ==========================================================================================

;print(max(diario(:,:,{-24:-23},{-47.15:-46})))

print(max(cemadendiaria))
print(max(wrf12(:,:,{-24:-23},{-47.15:-46})))
print(max(wrf6(:,:,{-24:-23},{-47.15:-46})))


;	do k = 0,ntimes-1
;			do it = 0,108

;			  	do i = 0,88			
;
;					Prob(k,it,i) =  ((num(rain_tot(:,k,it,i) .gt. 5 )/6.))*100.		
;					
;				end do
;		
;				
;			end do
;	end do

;copy_VarCoords(rain_exp(0,:,:,:),Prob)


;Prob!0 = "time"
;Prob!2 = "lon"
;Prob!1 = "lat"
;Prob&lon = lon1(0,:)
;Prob&lat = lat1(:,0)
;Prob&lat@units = "degrees_north"
;Prob&lon@units = "degrees_east"

;do k = 0,5
;	do i = 0,3


;		opt@gsnLeftString = "dia"+(8+i)

;		opt@cnLinesOn = True	
		
;opt@cnLevelSelectionMode = "ManualLevels"
;opt@cnMinLevelValF = 0
;opt@cnLevelSpacingF = 10
opt@cnLineThicknessF = 5

;	plot = gsn_csm_contour_map(wks,Prob(i,{-24:-23},{-48:-46}),opt)
;	plot = gsn_csm_contour_map(wks,wrf12(k,i,{-24:-23},{-47.15:-46}),opt)
	lnres = True
	lnres@gsLineColor = "Black"
	lnres@gsLineThicknessF = 1.5

;	linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

  ;	draw(plot)
 ; 	frame(wks)


;	end do
;end do

k = 0
j=0
m=0

do l = 0,niq-1

k=0
j=0
i=0

	do i = 3,ntimes-1,12

			if  ( i .eq. 75) then ; quando k = 62, não irá plotar mais nada

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
					opt@tiMainString = "Acumulado 12hr"
					opt@gsnRightString = "Membro"+(m+1)
					opt@gsnLeftString = times(75)+" to "+times(ntimes-1)
					plot = gsn_csm_contour_map(wks,wrf12(l,(ntimes/12)-1,{-24:-23},{-47.15:-46}),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)
					break

				else ; enquanto k diferente de 62, continuará plotando gráficos

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
					opt@gsnRightString = "Membro"+(m+1)
					opt@gsnLeftString = times(i)+" to "+times(i+11)
					plot = gsn_csm_contour_map(wks,wrf12(l,k,{-24:-23},{-47.15:-46}),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)

					print(times(i)+" to "+times(i+11))
					print(k+"")			
					k=k+1
					
			end if

	end do
	m=m+1
	delete(k)
	delete(i)
	delete(j)
end do

k = 0
j=0
m=0

do l = 0,niq-1

k=0
j=0
i=0

	do i = 3,ntimes-1,6

			if  ( i .eq. 81) then ; quando k = 62, não irá plotar mais nada

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
					opt@tiMainString = "Acumulado 6hr"
					opt@gsnRightString = "Membro"+(m+1)
					opt@gsnLeftString = times(81)+" to "+times(ntimes-1)
					plot = gsn_csm_contour_map(wks,wrf6(l,(ntimes/6)-1,{-24:-23},{-47.15:-46}),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)
					break

				else ; enquanto k diferente de 62, continuará plotando gráficos

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
					opt@tiMainString = "Acumulado 6hr"
					opt@gsnRightString = "Membro"+(m+1)
					opt@gsnLeftString = times(i)+" to "+times(i+5)
					plot = gsn_csm_contour_map(wks,wrf6(l,k,{-24:-23},{-47.15:-46}),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)

					print(times(i)+" to "+times(i+5))
					print(k+"")			
					k=k+1
					
			end if

	end do
	m=m+1
	delete(k)
	delete(i)
	delete(j)
end do

end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


exit
	k = 0

	do i = 3,743,12

			if  ( k .eq. 62) then ; quando k = 62, não irá plotar mais nada

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
					opt@gsnLeftString = date_str(i)+" to "+date_str(i+11)
					plot = gsn_csm_contour_map(wks,cemadendiaria(time|61,lat|:,lon|:),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)
					break

				else ; enquanto k diferente de 62, continuará plotando gráficos

					opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					opt@cnLevelSpacingF = 10
			
					opt@gsnLeftString = date_str(i)+" to "+date_str(i+11)
					plot = gsn_csm_contour_map(wks,cemadendiaria(time|k,lat|:,lon|:),opt)
					linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

					draw(plot)
  					frame(wks)

					print(date_str(i)+" to "+date_str(i+11))
					print(k+"")			
					k=k+1

			end if

	end do



  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
