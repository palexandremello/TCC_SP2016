subroutine acum_chuva(matrix,rain_tot,t,x,y,z)
	integer :: t,x,y,z
	real :: matrix(t,x,y), rain_tot(t,x,y)
    

    do i = 0,t        
        
        if (i .gt. 0) then
          
                matrix(j,:,:) = rain_tot(i,:,:) - rain_tot(i-1,:,:) 
                j=j+1           
            else
                matrix(j,:,:) = rain_tot(i,:,:)
                j=j+1


            end if

    
    end do

 RETURN
end subroutine acum_chuva