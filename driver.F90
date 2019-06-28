program main

  use GlobalVariables_mod
  !use nvtx_mod
  use omp_lib

  implicit none

  ! v is the solution vector. Solving Av=f, but A stencil is hard coded.
  real(kind=double), allocatable :: Vold(:,:), Vnew(:,:), f(:,:), exact(:,:)
  real(kind=double), allocatable :: Jerror(:)
  ! mesh that solutions lives on (tab is 1D, mat is kron product with tab data)
  real(kind=double), allocatable :: xtab(:),xmat(:,:),ymat(:,:)
  real(kind=double) :: x,y ! scalar temp values of x and y.

  real(kind=double) :: h, hh

  ! Timing variables
  real(kind=8) :: t1, t2, T, mem

  integer :: ierr, i, j, p

  
  ! calculate problem size in GB
  mem = 8*real(N*N,kind=8)/real(1024*1024*1024,kind=8)

  !write(*,fmt) "Array size: ", real(8*N*1D-9), " GB"
  print*, "****Laplace OpenMP example****"
  write(*,'(A,F8.4,A)') "Array size: ", mem , " GB "

  ! setup
  allocate( Vold(N,N) )
  allocate( Vnew(N,N) )
  allocate( f(N,N) )
  allocate( exact(N,N) )
  allocate( Jerror(niterations) )
  

  ! create coordinate matrices from coordinate vectors (similar to numpy meshgrid)
  Allocate(xtab(N))
  Allocate(xmat(N,N),ymat(N,N))
  h = (b-a)/(N-1)
  hh = h*h
  xtab = [(h*j, j = 0,N-1)]
  xmat = Spread(xtab,DIM=1,NCOPIES=N)
  ymat = Spread(xtab,DIM=2,NCOPIES=N)

  ! **** Initialize ****
  
  t1 = omp_get_wtime()

  ! Populate the initial guess, the known solution, the RHS, etc.
  do j = 1,N
     do i = 1, N
        x = xmat(i,j)
        y = ymat(i,j)
        ! starting guess for iteration:
        Vold(i,j) = InitialGuess(x,y)
        ! For testing can solve a known problem.
        exact(i,j) = KnownSolution(x,y)
        ! RHS:
        f(i,j) = RHS(x,y)
     enddo
  enddo

  t2 = omp_get_wtime()
  print *, "initialize time: ", t2-t1

  ! ***** Jacobi Iterations *****
  write(*,'(A,T30,A,T40,A)') "Iteration", "Time", "Error"

  do p = 1, niterations
     t1 = omp_get_wtime()  
     ! Jacobi on interior points
     do j = 2, N-1
        do i = 2, N-1
           Vnew(i,j)=0.25_double*(hh*f(i,j)+ &
                Vold(i-1,j) + Vold(i+1,j) +&
                Vold(i,j-1) + Vold(i,j+1))
        enddo
     enddo
     ! Weighted jacobi
     Vnew = (1-omega)*Vold + omega*Vnew
     ! Compute the max norm of the error at each iteration, e = exact-v
     Jerror(p) = maxval(abs(exact-Vnew))
     Vold = Vnew
     t2 = omp_get_wtime()
     write(*,'(I4,T30,E8.3,T40,E8.3)') p, t2-t1, Jerror(p)
  enddo



  print*, "completed"

end program main
