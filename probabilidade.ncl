
begin

	  start_cpu_time = get_cpu_time()    

wks = gsn_open_wks("pdf","probz")

lonnew = ispan( -4715, -4600, 16 )/100.
latnew = ispan( -2400, -2300, 16 )/100.

nlat = dimsizes(latnew)
nlon = dimsizes(lonnew)

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


cemadendiaria = asciiread("cemadentotal.dat",(/31,nlon,nlat/),"float")
 

cemadendiaria!0 = "time"
cemadendiaria!1 = "lon"
cemadendiaria!2 = "lat"
cemadendiaria&lon = lonnew
cemadendiaria&lat = latnew
cemadendiaria&lat@units = "degrees_north"
cemadendiaria&lon@units = "degrees_east"

printVarSummary(cemadendiaria)

niq = dimsizes(iq)



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

opt@tiMainString = "Chuva diaria"


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


j=0
	do i = 2,ntimes-1,24
	
	if ( i .eq. 74) then

		diario(:,j,:,:) = dim_sum_n(inst(:,74:96,:,:),1)
		break
	else
	
		diario(:,j,:,:) = dim_sum_n(inst(:,i:i+23,:,:),1)
		j=j+1
	end if	
	
	end do


diario!1 = "time"
diario!3 = "lon"
diario!2 = "lat"
diario&lon = lon1(0,:)
diario&lat = lat1(:,0)
diario&lat@units = "degrees_north"
diario&lon@units = "degrees_east"

print(max(diario(:,:,{-24:-23},{-47.15:-46})))
print(max(cemadendiaria))

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

do k = 0,5
	do i = 0,3


		opt@gsnLeftString = "dia"+(8+i)

		opt@cnLinesOn = True	
		
opt@cnLevelSelectionMode = "ManualLevels"
opt@cnMinLevelValF = 0
opt@cnLevelSpacingF = 5
opt@cnLineThicknessF = 5

;	plot = gsn_csm_contour_map(wks,Prob(i,{-24:-23},{-48:-46}),opt)
	plot = gsn_csm_contour_map(wks,diario(k,i,{-24:-23},{-47.15:-46}),opt)
	lnres = True
	lnres@gsLineColor = "Black"
	lnres@gsLineThicknessF = 1.5

	linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

  	draw(plot)
  	frame(wks)


	end do
end do


do i = 0,30

opt@cnLevelSelectionMode = "ManualLevels"
opt@cnMinLevelValF = 0
opt@cnLevelSpacingF = 10

		opt@gsnLeftString = "dia"+(1+i)
		plot = gsn_csm_contour_map(wks,cemadendiaria(time|i,lat|:,lon|:),opt)
			linermsp = gsn_add_shapefile_polylines(wks,plot,filename,lnres)

	draw(plot)
  	frame(wks)

end do


  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")


end
