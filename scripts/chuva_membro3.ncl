begin

	 start_cpu_time = get_cpu_time()    

		atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
		cedil = "c~H-13F35~K~FH2~" ; ç
	
		files = systemfunc("ls ~/TCC_RODADAS/*/wrfout_d01_2016-*") ; LISTANDO TODAS AS SAIDAS
	nfiles = dimsizes(files) 				   ; WRFOUT E CRIANDO UMA VARIAVEL COM O TOTAL DE ARQUIVOS 

	filename = "/home/paulo/TCC_RODADAS/35MUE250GC_SIR.shp" ; associando um shapefile 

	iq = ind(files .eq. "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-08_00:00:00" .or. files .eq. \
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-08_12:00:00" .or. files .eq. \ ;CRIANDO UM VETOR
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-09_00:00:00" .or. files .eq. \ ;COM TODOS OS INDICES
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-09_12:00:00".or. files .eq. \  ; DE TODOS OS WRFOUT
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-10_00:00:00".or. files .eq. \  ; DO DIA 8 AS 00 UTC
			    "/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-10_12:00:00")	
	niq = dimsizes(iq)

		wks = gsn_open_wks("pdf","chuva") ; CRIANDO UMA ÁREA GRÁFICA

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
opt@cnFillOn              = True             ; color plot desired
opt@cnFillMode            = "RasterFill"     ; raster contours
opt@cnLineLabelsOn        = False            ; turn off contour labels
opt                      = wrf_map_resources(dados[0],opt)
;opt@lbOrientation         = "Vertical"       ; default is horizontal


	
  
;  opt@mpGeophysicalLineColor        = "black"    ; So we can see the map
;  opt@mpGeophysicalLineThicknessF   = 10       ; outlines better.
 	
 cmap     := read_colormap_file("BlAqGrYeOrReVi200")
  cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  opt@cnFillOn             = True
  opt@cnFillMode           = "RasterFill"
  opt@cnFillPalette        = cmap
  opt@cnLinesOn            = False            ; turn off contour lines
  opt@cnLineLabelsOn       = False            ; turn off contour labels
  opt@cnFillOpacityF       = 1.               ; .85 

  opt@tfDoNDCOverlay        = True            ; necessary for correct overlay on map

  opt@cnLevelSelectionMode = "ManualLevels"
  opt@cnMaxLevelValF       = 200
  opt@cnMinLevelValF       =  2
  opt@cnLevelSpacingF      =  10
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
		nlat = dimsizes(lat1(:,0))
		nlon = dimsizes(lon1(0,:))
		
		maxlat = max(lat1)
		minlat = min(lat1)

		maxlon = max(lon1)
		minlon = min(lon1)


lon = ispan( -4715, -4615, 16 )/100.
lat = ispan( -2380, -2300, 16 )/100.

xpts = (/ min(lon),min(lon),max(lon),max(lon),min(lon)/)
ypts = (/ min(lat),max(lat),max(lat),min(lat),min(lat)/)

dum = new((/4,6/),graphic)

do it = 0,niq-1

	
		
		times = wrf_user_getvar(dados[it],"times",-1) 
		ntimes = dimsizes(times)

print(ntimes+"")

delete(times)
delete(ntimes)
end do


		


opt@mpMinLatF = minlat
opt@mpMaxLatF = maxlat
opt@mpMinLonF = minlon
opt@mpMaxLonF = maxlon

		 
		dadosEM     = addfiles(files(iq),"r")
		ListSetType (dadosEM,"cat")

    		rain_exp = dadosEM[:]->RAINNC
    		rain_con = dadosEM[:]->RAINC
    		rain_tot = rain_exp + rain_con
    		copy_VarCoords(rain_exp,rain_tot)
    		rain_tot@description = "Total precipitado"

	inst =   new((/niq,97,nlat,nlon/),"float")
			diario = new((/4,109,89/),"float")
			wrf12  = new((/niq,8,nlat,nlon/),"float")
			painel =new((/niq,8/),graphic)

j=0

	do i = 0,401		
		
		if ( i .le. 96) then
		
			if ( i .gt. 96) then
		
				inst(0,j,:,:) = rain_tot(i,:,:) - rain_tot(i-1,:,:)	
				j=j+1			
			else
				inst(0,j,:,:) = rain_tot(i,:,:)
				j=j+1


			end if


		end if
	
	end do

		print(max(inst))
		end_cpu_time = get_cpu_time()
		print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")

end

