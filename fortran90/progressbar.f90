subroutine progress(init,max)
  implicit none
  integer(kind=4)::j,k,max,init
  integer :: step,done
  character(len=17)::bar="???% |          |"
  step = nint(init * 100 / (1.0 * max))
  done = floor(step / 10.0) ! mark every 10%
  write(*,*) step
    write(unit=bar(1:3),fmt="(i3)")   step
  do k=1,max
    if (k .eq. max) then
        bar(6+k:6+k)=""


    else
        bar(6+k:6+k)=""
    endif
    
  enddo
  ! print the progress bar.
  write(unit=6,fmt="(a1,a1,a17)") '+',char(13), bar
  return
end subroutine progress