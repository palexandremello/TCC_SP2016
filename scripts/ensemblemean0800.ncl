
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	  start_cpu_time = get_cpu_time()    

	wks = gsn_open_wks("pdf","ENSEMBLE_08")
	 
	atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
	cedil = "c~H-13F35~K~FH2~" ; ç
	files = systemfunc("ls ~/TCC_RODADAS/*/wrfout_d01_2016-*")
	nfiles = dimsizes(files)

	filename = "./35MUE250GC_SIR.shp"

	iq = ind(files .eq. "/home/paulo/TCC_RODADAS/MEM1/wrfout_d01_2016-03-08_00:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM2/wrfout_d01_2016-03-08_00:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM3/wrfout_d01_2016-03-08_00:00:00" .or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM4/wrfout_d01_2016-03-08_00:00:00".or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM5/wrfout_d01_2016-03-08_00:00:00".or. files .eq. \
	"/home/paulo/TCC_RODADAS/MEM6/wrfout_d01_2016-03-08_00:00:00")


	niq = dimsizes(iq)

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

  rain_totEM = dim_avg_n_Wrap(rain_tot,0)

 j = 0
diaria = new((/6,4,109,89/),"float")
instEM =   new((/ntimes,109,89/),"float")
acum12 = new((/ntimes/12,109,89/),"float")

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
	opt@cnLevelSelectionMode = "ManualLevels"
	opt@cnMinLevelValF = 25
	opt@cnMaxLevelValF = 200
	opt@cnLevelSpacingF = 50
	opt@cnLinesOn = False

	opt@cnFillOn = True

	opt@mpNationalLineThicknessF = 3   
	opt                      = wrf_map_resources(dados[0],opt)
 cmap     := read_colormap_file("BlAqGrYeOrReVi200")
  cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  opt@cnFillOn             = True
  opt@cnFillMode           = "RasterFill"
  opt@cnFillPalette        = cmap
  opt@cnLinesOn            = False            ; turn off contour lines
  opt@cnLineLabelsOn       = False            ; turn off contour labels
  opt@cnFillOpacityF       = 1.               ; .85 

  opt@tfDoNDCOverlay        = True            ; necessary for correct overlay on map


	
do k = 0,5
j=0
	do c = 0,ntimes-1
		if ( c .gt. 0)
				instEM(j,:,:) = rain_totEM(c,:,:) - rain_totEM(c-1,:,:)
				j=j+1
		else
				instEM(j,:,:) = rain_totEM(c,:,:) 
		j=j+1		
		end if

	end do
end do


instEM!0 = "time"
instEM!2 = "lon"
instEM!1 = "lat"
instEM&lon = lon1(0,:)
instEM&lat = lat1(:,0)
instEM&lat@units = "degrees_north"
instEM&lon@units = "degrees_east"



i=0
j=0
	do i = 3,ntimes-1,12

		;print(times(c)+" "+times(c+11))
		
		if ( i .eq. 87 )
				print(times(87)+" "+times(ntimes-1))
				acum12(j,:,:) = dim_sum_n(instEM(87:ntimes-1,:,:),0)
				print(j+"")

				break
		else
			       	 print(times(i)+" "+times(i+11))
				 acum12(j,:,:) = dim_sum_n(instEM(i:i+11,:,:),0)
				print(j+"")				
				 j=j+1		
				
		end if
	end do



acum12!0 = "time"
acum12!2 = "lon"
acum12!1 = "lat"
acum12&lon = lon1(0,:)
acum12&lat = lat1(:,0)
acum12&lat@units = "degrees_north"
acum12&lon@units = "degrees_east"

painel12 = new(ntimes/12,graphic)

do i = 0,6

opt@lbLabelBarOn = False

		;opt@gsnLeftString = times(i)

		;opt@cnLinesOn = True
		
	painel12(i) = gsn_csm_contour_map(wks,acum12(i,:,:),opt)
  
  ;draw(painel(i))
 ; frame(wks)


end do

panel = True
panel@gsnAttachBorderOn = False
panel@gsnPanelLabelBar   = True
panel@gsnMaximize = True
panel@gsnPanelRowSpec = False
panel@gsnPanelCenter = False



			gsn_panel(wks,painel12(3:6),(/2,2/), panel)
			;gsn_panel(wks,(/painel12(4),painel12(5), painel12(6)/),(/1,3/),panel)


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
