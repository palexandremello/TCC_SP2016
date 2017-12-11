begin

	 start_cpu_time = get_cpu_time()    

		atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
		cedil = "c~H-13F35~K~FH2~" ; ç
	
		files = systemfunc("ls ~/TCC_RODADAS/*/wrfout_d01_2016-*") ; LISTANDO TODAS AS SAIDAS
	nfiles = dimsizes(files) 				   ; WRFOUT E CRIANDO UMA VARIAVEL COM O TOTAL DE ARQUIVOS 

	filename = "/home/paulo/TCC_RODADAS/35MUE250GC_SIR.shp" ; associando um shapefile 

	iq = ind(files .eq. "/home/paulo/TCC_RODADAS/MEM1/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \
			    "/home/paulo/TCC_RODADAS/MEM2/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \ ;CRIANDO UM VETOR
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-09_12:00:00" .or. files .eq. \ ;COM TODOS OS INDICES
			    "/home/paulo/TCC_RODADAS/MEM4/wrfout_d01_2016-03-09_12:00:00".or. files .eq. \  ; DE TODOS OS WRFOUT
			    "/home/paulo/TCC_RODADAS/MEM5/wrfout_d01_2016-03-09_12:00:00".or. files .eq. \  ; DO DIA 8 AS 00 UTC
			    "/home/paulo/TCC_RODADAS/MEM6/wrfout_d01_2016-03-09_12:00:00")	
	niq = dimsizes(iq)

		wks = gsn_open_wks("pdf","chuva0912") ; CRIANDO UMA ÁREA GRÁFICA

dados     = addfiles(files(iq),"r")

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
opt@mpNationalLineThicknessF = 5  
opt@cnLinesOn             = False            ; turn off contour lines
;opt@cnFillMode            = "RasterFill"     ; raster contours
opt@cnLineLabelsOn        = False            ; turn off contour labels
opt                      = wrf_map_resources(dados[0],opt)
;opt@lbOrientation         = "Vertical"       ; default is horizontal


	
  
;  opt@mpGeophysicalLineColor        = "black"    ; So we can see the map
;  opt@mpGeophysicalLineThicknessF   = 10       ; outlines better.
 	
 cmap     := read_colormap_file("default")
 cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  	opt@cnFillOn             = True
 	; opt@cnFillMode           = "RasterFill"
  	opt@cnFillPalette        = cmap
  	opt@cnLinesOn            = False            ; turn off contour lines
  	opt@cnLineLabelsOn       = False            ; turn off contour labels
  	opt@cnFillOpacityF       = 1.               ; .85 
  	opt@tfDoNDCOverlay        = True            ; necessary for correct overlay on map
  	opt@cnLevelSelectionMode = "ManualLevels"
  	opt@cnMaxLevelValF       = 200
  	opt@cnMinLevelValF       =  25
  	opt@cnLevelSpacingF      =  50
	opt@cnNoDataLabelOn = True
	opt@cnNoDataLabelString = " " 
	opt@tiXAxisFontThicknessF = 4
;---------------------------------------------
	opt@tmXBMajorThicknessF = 4
	opt@tmBorderThicknessF = 4
;-------------Configuração para o eixo y------------
	opt@tmYLMinorOn = False
	opt@tmYLLabelFontHeightF = 0.03
	opt@tmYLLabelFont = 0 
	opt@tmYLLabelFontThicknessF = 4
	opt@tiYAxisFontHeightF = 0.05
;---------------------------------------------
	opt@tiYAxisFont = 0
	opt@tiYAxisFontThicknessF = 4
;---------------------------------------------
	opt@tmYLMajorThicknessF = 4


;-===============================================

	
	opt@tmXBMinorOn = False
	opt@tmXBLabelFontHeightF = 0.03
	opt@tmXBLabelFont = 0 
	opt@tmXBLabelFontThicknessF = 4
	opt@tmXBMajorThicknessF = 4



	
		lat1 = dados[0]->XLAT(0,:,:)
   		lon1 = wrf_user_getvar(dados[0],"XLONG",0)
		times = wrf_user_getvar(dados[0],"times",-1) 
		ntimes = dimsizes(times)
		nlat = dimsizes(lat1(:,0))
		nlon = dimsizes(lon1(0,:))
		maxlat = max(lat1)
		minlat = min(lat1)
		maxlon = max(lon1)
		minlon = min(lon1)


lon = ispan( -4715, -4615, 16 )/100.
lat = ispan( -2400, -2300, 16 )/100.

xpts = (/ min(lon),min(lon),max(lon),max(lon),min(lon)/)
ypts = (/ min(lat),max(lat),max(lat),min(lat),min(lat)/)

dum = new((/4,6/),graphic)



opt@mpMinLatF = minlat
opt@mpMaxLatF = maxlat
opt@mpMinLonF = minlon
opt@mpMaxLonF = maxlon

		 
		dadosEM     = addfiles(files(iq),"r")
		ListSetType (dadosEM,"join")

    		rain_exp = dadosEM[:]->RAINNC
    		rain_con = dadosEM[:]->RAINC
    		rain_tot = rain_exp + rain_con
    		copy_VarCoords(rain_exp,rain_tot)
    		rain_tot@description = "Total precipitado"


			
			inst =   new((/niq,ntimes,nlat,nlon/),"float")
			diario = new((/4,109,89/),"float")
			wrf12  = new((/niq,ntimes/12,nlat,nlon/),"float")
			painel =new((/niq,8/),graphic)
	
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


i=0
j=0

printVarSummary(inst)
print(ntimes)
; WRF12 VARIAVEL QUE RECEBERÁ O ACUMULADO DE 12 EM 12H DE TODOS OS 6 MEMBROS DAS 8 OOUTC


do i = 3,ntimes-1,12
			           		

	

           		if ( i .eq. 51) then


		 	print(times(51)+" to "+times(ntimes-1))
			
			wrf12(:,j,:,:) = dim_sum_n(inst(:,51:ntimes-1,:,:),1)	
			print(i+" "+(i+11))
			print(j+"")	 
			break
			
			else
	
				;print("membro"+(l))	
		  		   print(times(i)+" to "+times(i+11))	
				   print(i+" "+(i+11))
				;   print(j+"")
				wrf12(:,j,:,:) = dim_sum_n(inst(:,i:i+11,:,:),1)
				print(j+"")
				j=j+1

			end if	
		
		end do

print(max(wrf12))
print(ntimes)
delete(rain_tot)
delete(rain_exp)
delete(rain_con)

wrf12!1 = "time"
wrf12!3 = "lon"
wrf12!2 = "lat"
wrf12&lon = lon1(0,:)
wrf12&lat = lat1(:,0)
wrf12&lat@units = "degrees_north"
wrf12&lon@units = "degrees_east"

opt@mpShapeMode  = "FreeAspect"
opt@vpHeightF = 0.8

opt@lbLabelBarOn = False


lnres = True
	lnres@gsLineColor = "Black"
	lnres@gsLineThicknessF = 1.5

k=0
m=0
i=0

	

do l = 0,niq-1 ; do que irá variar os membros (6 membors)

k=0
j=0
i=0		

if ( l .ge. 0 .and. l .le. 2 ) then ; entre o membro 1 e 3 irá

    opt@tmXBOn         = False ; destivar o eixo da borda X (longitude)
	

	
		do i = 3,ntimes-1,12 ; plotando os gráficos acumulados de 12 em 12 UTC



			if  ( i .eq. 51) then ; quando k = 87, não irá plotar mais nada

				
					opt@tiMainString = ""
		                         ;"Membro"+(m+1)
					painel(l,4) = gsn_csm_contour_map(wks,wrf12(l,4,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,4),filename,lnres)
			
				;	draw(plot)
  				;	frame(wks)
					break

				else ; enquanto k diferente de 87, continuará plotando gráficos

		 	if ( l .ge. 1 .and. l .le. 2 ) then ; condição necessária para tirar Y Left do mapa			
		  
				opt@tmYLOn = False ; desativará nos gráficos 2 e 3 o eixo da esquerda Y
					
					opt@tiMainString = "";times(i)+" to "+times(i+11)
				         ;"Membro"+(m+1)
					painel(l,k) = gsn_csm_contour_map(wks,wrf12(l,k,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,k),filename,lnres)
				

				;	draw(plot)

  				;	frame(wks)
					

					print(times(i)+" to "+times(i+11))
					print(k+"")			
					k=k+1
					
		else ; irá adicionar Y Left nos mapas 

				opt@tmYLOn = True ; Se a condição é falsa, ativará os eixos da esquerda de Y
				opt@tmXBLabelFontHeightF = 0.05
					
					opt@tiMainString = "";times(i)+" to "+times(i+11)
				      ;   ;"Membro"+(m+1)
					painel(l,k) = gsn_csm_contour_map(wks,wrf12(l,k,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,k),filename,lnres)
				

				;	draw(plot)
  				;	frame(wks)

					print(times(i)+" to "+times(i+11))
					print(k+"")			
					k=k+1
			


				end if


			end if


		end do

	else 
	
	opt@tmYLOn = False ; se a condição do IF maior for falsa
	opt@tmXBOn = True  ; desativará eixo esquerdo Y e ativará o eixo da borda X
  	opt@vpWidthF  = 0.68
	opt@tmXBLabelFontHeightF = 0.05

		do i = 3,ntimes-1,12



			if  ( i .eq. 51) then ; quando k = 87, não irá plotar mais nada

					;opt@cnLevelSelectionMode = "ManualLevels"
					;opt@cnMinLevelValF = 0
					;opt@cnLevelSpacingF = 10
					;opt@tiMainString = ""
					opt@tiMainString = ""
		                      ;  opt@gsnRightString = "" ;"Membro"+(m+1)
					painel(l,4) = gsn_csm_contour_map(wks,wrf12(l,4,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,4),filename,lnres)
			
				;	draw(plot)
  				;	frame(wks)
					break

				else ; enquanto k diferente de 87, continuará plotando gráficos

					
			if ( l .eq. 3) then ; quando o loop principal for igual ao membro 4

			opt@tmYLOn = True ; irá ativar o eixo da esquerda Y					

					
					opt@tiMainString = "";times(i)+" to "+times(i+11)
				     ;   opt@gsnRightString = "" ;"Membro"+(m+1)
					painel(l,k) = gsn_csm_contour_map(wks,wrf12(l,k,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,k),filename,lnres)
				

				;	draw(plot)
  				;	frame(wks)

					print(times(i)+" to "+times(i+11))
					print(k+"")			
					k=k+1





			else ; se a condição for falsa, irá plotar o eixo esquerdo Y para os membros diferentes de 4


					opt@tiMainString = "";times(i)+" to "+times(i+11)
				       ;  ;"Membro"+(m+1)
					painel(l,k) = gsn_csm_contour_map(wks,wrf12(l,k,:,:),opt)
					linemap = gsn_add_shapefile_polylines(wks,painel(l,k),filename,lnres)
				

				;	draw(plot)
  				;	frame(wks)

					print(times(i)+" to "+times(i+11))
					print(k+"")			
					k=k+1

			end if

				end if




		end do

	


	end if

		m=m+1
		delete(k)
		delete(i)
		delete(j)  


	end do

; configurações do painel
panel = True
panel@gsnAttachBorderOn = False
panel@gsnPanelLabelBar   = True
panel@gsnMaximize = True
panel@gsnPanelRowSpec = False
panel@gsnPanelCenter = False
panel@gsnPanelFigureStrings= (/"a","b","c","d","e","f"/) ; add strings to panel
panel@gsnPanelBottom   = 0.05
;panel@lbLabelBarOn = False      
panel@gsnPanelFigureStringsFontHeightF = 0.01  
panel@pmLabelBarWidthF   = 0.9
panel@lbLabelFontHeightF = 0.03

;=========================================;

	resp = True
        resp@gsLineThicknessF = 3.0
	resp@gsLineColor = "red"

; plotando a minha área de estudo RMSP		
do v = 0,5		
			do c = 0,3

        			dum(c,v) =gsn_add_polyline(wks,painel(v,2),xpts(c:c+1),ypts(c:c+1),resp)
      			end do  
end do		
; irá plotar um quadrado nas 6 configurações diferentes de mesma inicialização 8/03 00UTC


			gsn_panel(wks, (/painel(0,2),painel(1,2),painel(2,2),painel(3,2),painel(4,2),painel(5,2)/), (/2,3/), panel)		


			end_cpu_time = get_cpu_time()
		        print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")

end
