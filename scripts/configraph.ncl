begin

	atilde = "a~H-13V2F35~D~FV-2H3~" ; ã
	cedil = "c~H-13F35~K~FH2~" ; ç

  cfg = True
  cfg@gsnMaximize = True
  cfg@mpOutlineBoundarySets = "National"
  cfg@mpDataSetName = "Earth..4"
  cfg@mpDataBaseVersion     = "MediumRes"
  cfg@mpOutlineOn           = True
  cfg@mpOutlineSpecifiers   = (/"Brazil:states"/)
  cfg@cnFillOn = True

opt = cfg


opt@mpProjection          = "CylindricalEquidistant"
opt@mpMinLatF = -60
opt@mpMaxLatF = 10.
opt@mpMinLonF =  -80
opt@mpMaxLonF = -30
opt@mpCenterLonF = 315

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
	opt@cnMinLevelValF = 44
	opt@cnMaxLevelValF = 60
	opt@cnLevelSpacingF = 5
	opt@cnLinesOn = False
	opt@lbLabelBarOn = True
	
 cmap     := read_colormap_file("BlAqGrYeOrReVi200")
  cmap(0,:) = (/0,0,0,0/)    ; make first color fully transparent

  opt@cnFillOn             = True
;  opt@cnFillMode           = "RasterFill"
  opt@cnFillPalette        = cmap
  opt@cnLineLabelsOn       = False            ; turn off contour labels
  opt@cnFillOpacityF       = 1.               ; .85 

  opt@tfDoNDCOverlay        = False            ; necessary for correct overlay on map


panel = True
panel@gsnAttachBorderOn = False
panel@gsnPanelLabelBar   = True
panel@gsnMaximize = True
panel@gsnPanelRowSpec = False
panel@gsnPanelCenter = False
panel@gsnPanelFigureStrings= (/"a","b","c","d","e","f"/) ; add strings to panel
panel@gsnPanelBottom   = 0.015
panel@lbLabelBarOn = True      
panel@gsnPanelFigureStringsFontHeightF = 0.01  
panel@pmLabelBarWidthF   = 0.45
panel@lbLabelFontHeightF = 0.015

;=========================================;

	resp = True
        resp@gsLineThicknessF = 3.0
	resp@gsLineColor = "red"

           

opt2 = True
opt2@gsnMaximize = True
opt2@gsnFrame = False

opt2@tiXAxisFont = 0
        opt2@xyDashPatterns = (/ 1.,3.,12.,15.,14.,0.,16./)
opt2@xyExplicitLegendLabels = (/"MEM1", "MEM2","MEM3","MEM4","MEM5","MEM6","Observ"/)
  	opt2@pmLegendDisplayMode    = "Always"   ; Display a legend.
  	opt2@pmLegendWidthF         = 0.12        ; Make it smaller
  	opt2@pmLegendHeightF        = 0.2        ; Make it smaller
  	opt2@pmLegendOrthogonalPosF = -1.35      ; Move into to plot  	
	opt2@pmLegendParallelPosF   = 1.3   ; Move to right
  	opt2@lgPerimOn              = False      ; No legend perimeter.
	opt2@lgLabelFont = 0  	
	opt2@lgLabelFontHeightF     = 0.02
	opt2@lgItemPlacement = "ExplicitPlacement"
                        opt2@lgItemPositions = (/ 0, 0.15, 0.3, 0.45, 0.60/)
	opt2@lgLabelFontThicknessF  = 4
	opt2@tmXBLabelFont = 0 
	opt2@tmXBLabelStride = 1	
	opt2@tmXBLabelFontThicknessF = 4
	opt2@tmXBLabelFontHeightF = 0.01
	opt2@tiXAxisFontHeightF = 0.02
     
	opt2@xyLineThicknessF = 5.

        opt2@tmXTBorderOn = False
        opt2@tmYRBorderOn = False
opt2@tmXTOn = False
        opt2@tmYROn = False
	opt2@tmXBMode= "Explicit"
	opt2@tmXBValues = (/1,3,5,7/)
	opt2@tmXBLabels = (/"09/03 02UTC ","10/03 02UTC","11/03 02UTC","12/03 00UTC"/)

     opt2@xyLineColors = (/ "blue","red","green","orange","purple","yellow","violet"/)

	opt2@tiXAxisFontThicknessF = 4
;---------------------------------------------
	opt2@tmXBMajorThicknessF = 4
	opt2@tmBorderThicknessF = 4
;-------------Configuração para o eixo y------------
	opt2@tmYLMinorOn = False
	opt2@tmYLLabelFontHeightF = 0.03
       ; opt2@tmXBLabelFontHeightF = 0.015
	opt2@tmYLLabelFont = 0 
	opt2@tmYLLabelFontThicknessF = 4
;	opt2@tiXAxisFontHeightF = 0.001
;---------------------------------------------
	opt2@tiYAxisFont = 0
	opt2@tiYAxisFontThicknessF = 4
;---------------------------------------------
	opt2@tmYLMajorThicknessF = 4
	opt2@tiXAxisString = "Horas" 
	opt2@tiYAxisString = "Precipita"+cedil+atilde+"o (mm)" 

	; opt2@tiYAxisFontHeightF = 0.01


    option = True
    option@tiXAxisString = "mm" 
        option@xyDashPatterns = (/ 16.,14.,12.,9.,3,0 /)
    option@xyExplicitLegendLabels = (/"MEM1","MEM2","MEM3","MEM4","MEM5","MEM6"/)
    
    option@pmLegendDisplayMode    = "Always"   ; Display a legend.
    option@pmLegendWidthF         = 0.12        ; Make it smaller
    option@pmLegendHeightF        = 0.2        ; Make it smaller
    option@pmLegendOrthogonalPosF = -1.35      ; Move into to plot      
    option@pmLegendParallelPosF   =  0.9      ; Move to right
    option@lgPerimOn              = False      ; No legend perimeter.
    option@lgLabelFont = 0      
    option@lgLabelFontHeightF     = 0.0225
    option@lgItemPlacement = "ExplicitPlacement"
         option@xyLineColors = (/ "blue","red","green","orange","purple","yellow","violet"/)

    ;option@lgItemPositions = (/ 0, 0.2, 0.4, 0.6, 0.8, 1, 1.2/)
    option@lgLabelFontThicknessF  = 4
        option@tmXTOn = False
        option@tmYROn = False
;Configuração para  eixo x
    option@tmXBLabelFont = 0 
    option@tmXBLabelStride = 2  
    option@tmXBLabelFontThicknessF = 2
    option@tmXBLabelFontHeightF = 0.020
    option@tiXAxisFontHeightF = 0.05
;---------------------------------------------
    option@tiXAxisFont = 0
    option@tiXAxisFontThicknessF = 4
;---------------------------------------------
    option@tmXBMajorThicknessF = 4
    option@tmBorderThicknessF = 4
;-------------Configuração para o eixo y------------
    option@tmYLMinorOn = False
    option@tmYLLabelFontHeightF = 0.03
    option@tmYLLabelFont = 0 
    option@tmYLLabelFontThicknessF = 2
    option@tiYAxisFontHeightF = 0.05
;---------------------------------------------
    option@tiYAxisFont = 0
    option@tiYAxisFontThicknessF = 2
;---------------------------------------------
    option@tmYLMajorThicknessF = 2
;---------------------------------------------  

    option@xyLineThicknessF = 2

        option@tmXTBorderOn = False
        option@tmYRBorderOn = False
    option@tmXBMode= "Explicit"
    option@tmXBValues = (/0,1,2,3,4,5,6/)
    option@tmXBLabels = (/">= 0.1",">= 5",">= 10",">= 20",">= 30",">= 50",">= 100" /)
    ;option@trYMaxF = 1.
        option@gsnMaximize = True
        option@gsnFrame = False
        option@gsnDraw = False



panelxy = True
panelxy@gsnAttachBorderOn = False

panelxy@gsnMaximize = True
panelxy@gsnPanelRowSpec = False
panelxy@gsnPanelCenter = False
panelxy@gsnPanelBottom   = 0.015
;panel@lbLabelBarOn = False      
panelxy@gsnPanelFigureStringsFontHeightF = 0.01  
panelxy@pmLabelBarWidthF   = 0.45
panelxy@lbLabelFontHeightF = 0.015

print("===================================================")
print("Configurações padrões : configraph.ncl")
print("===================================================")

print("Configurando...")

if (.not.(ismissing(get_script_prefix_name() )) ) then
print("Configurações carregada com sucesso") 
else
  print("Erro na configuração padrão")
  status_exit(42)
end if

print("===================================================")
end
