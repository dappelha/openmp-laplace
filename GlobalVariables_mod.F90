!  Global Constant module. Contains constants and parameters of the simulation
  
Module   GlobalVariables_mod
  ! Define double or can use kind = 8 will have same effect.
  Integer, Parameter :: double=Selected_Real_Kind(p=14,r=100)
  ! Define the size of the grid including boundary points:
  integer :: N=1025 ! interior points is N-2.

  ! Solve in unit square
  Real(kind=double) :: a=0, b=1  !grid boundaries

  ! Jacobi smoothing factor:
  Real(kind=double), Parameter :: omega = 4.0D0/5.0D0
  
  ! Define the relaxation parameters:
  integer, parameter :: niterations=100
  
  ! GLOBAL VARIABLES:
  
  ! FLAGS:
  Logical :: writeflag = .TRUE.! = .true. if we want to save for solutions for plotting
  ! Fundamental constants
  Real(kind=double), Parameter :: pi= 2.0D0*acos(0.0D0)
  
!++++++++++++++                        
  Contains                        
!++++++++++++++
    
Function InitialGuess(x,y) result(ans)
  Implicit None
  Real(kind=double), Intent(in) :: x,y
  Real(kind=double) :: ans
  ans = sin(x*20*pi)*sin(y*20*pi)+sin(x*40*pi)*sin(y*40*pi)
end Function InitialGuess

Function KnownSolution(x,y) result(ans)
  Implicit None
  Real(kind=double), Intent(in) :: x,y
  Real(kind=double) :: ans
  ans = 0
  !ans = (x**2-x**4)*(y**4 -y**2)
end Function KnownSolution

Function RHS(x,y) result(ans)
  Implicit None
  Real(kind=double), Intent(in) :: x,y
  Real(kind=double) :: ans
  ans = 0
  !ans = 2.D0*((1.D0-6.D0*x**2)*y**2*(1.D0-y**2) &
  !     & + (1.D0-6.D0*y**2)*x**2*(1.D0-x**2))
end Function RHS

End Module  GlobalVariables_mod
