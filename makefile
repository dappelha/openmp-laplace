comp=xlf

ifeq '${comp}' 'pgi'
	# PGI compiler
	F90=pgf90
	CC=pgcc
	CUDAFLAGS= -Mcuda=cc70,nordc,maxregcount:64,ptxinfo -fast -Mfprelaxed -L/usr/local/cuda/lib64 -lnvToolsExt
	F90FLAGS=-O3 -mp 
	CUDAFLAGS+= -acc
	LINKFLAGS = -ta=tesla:pinned
else
	# xlcuf compiler
	F90=xlf_r
	CC=xlc_r
	CUDAFLAGS= -qcuda -qtgtarch=sm_70 -W@,"-v,--maxrregcount=64" -lnvToolsExt
	CUDAFLAGS+= -qcheck -qsigtrap
	F90FLAGS=-g1 -O3 -qhot=novector -qsimd=auto -qarch=pwr9 -qtune=pwr9 -qsmp=omp -qoffload #-lomp
endif



build: driver.o GlobalVariables_mod.o nvtx_mod.o
	${F90} -o ${comp}test.exe driver.o GlobalVariables_mod.o ../nvtx/nvtx_mod.o ${F90FLAGS} ${CUDAFLAGS} ${LINKFLAGS}

driver.o: driver.F90 GlobalVariables_mod.o nvtx_mod.o
	${F90} -c -o driver.o driver.F90 ${F90FLAGS} ${CUDAFLAGS}

nvtx_mod.o: ../nvtx/nvtx_mod.F90
	${F90} -c -o ../nvtx/nvtx_mod.o ../nvtx/nvtx_mod.F90 ${F90FLAGS} ${CUDAFLAGS}

GlobalVariables_mod.o: GlobalVariables_mod.F90
	${F90} -c -o GlobalVariables_mod.o GlobalVariables_mod.F90 ${F90FLAGS} ${CUDAFLAGS}


clean:
	rm -f ${comp}test.exe *.o *.lst *.mod ../nvtx/*.o

