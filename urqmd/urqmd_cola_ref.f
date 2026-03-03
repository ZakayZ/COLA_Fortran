C ---------------------------------------------------------------------------
C Glue subroutines callable from cola_fortran_generator_impl.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_uinit
      implicit none

      include 'coms.f'
      include 'comres.f'
      include 'options.f'
      include 'colltab.f'
      include 'inputs.f'
      include 'newpart.f'
      include 'boxinc.f'

      call uinit(0)
      return
      end

      subroutine urqmd_cola_disable_outputs
      implicit none
      include 'options.f'
      bf13 = .true.
      bf14 = .true.
      bf15 = .true.
      bf16 = .true.
      bf19 = .true.
      bf20 = .true.
      return
      end

      subroutine urqmd_cola_generate_tables(tabpath, ok)
      implicit none
      character*(*) tabpath
      logical ok
      integer ios
      character*77 tname

      tname = tabpath
      if (tname(1:4).eq.'    ') tname = 'tables.dat'

C     If an old file exists, remove it so uinit/loadwtab regenerates it.
      open (unit=75, iostat=ios, file=tname, form='unformatted',
     .      status='old')
      if (ios.eq.0) then
         close (unit=75, status='delete')
      endif

      call uinit(0)

      open (unit=75, iostat=ios, file=tname, form='unformatted',
     .      status='old')
      if (ios.eq.0) then
         close (unit=75, status='keep')
         ok = .true.
      else
         ok = .false.
      endif
      return
      end

C ---------------------------------------------------------------------------
C Mimic file14out but write particle records to COLA EventParticles.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_file14out_to_parts(timestep, parts)
      use cola
      implicit none
      integer timestep
      type(EventParticles), intent(inout) :: parts
      type(Particle) :: p
      type(LorentzVector) :: mom, pos
      integer i, pdgid, pdg
      real*8 p0v, pxv, pyv, pzv
      include 'coms.f'
      include 'options.f'

      ! if (CTOption(41).eq.0) then
      do 10 i = 1, npart
         pdg = pdgid(ityp(i), iso3(i))
         p = Particle()
         call p%set_pdgCode(pdg)
         call p%set_pClass(ParticleClass_PRODUCED)
         p0v = p0(i)
         pxv = px(i) + ffermpx(i)
         pyv = py(i) + ffermpy(i)
         pzv = pz(i) + ffermpz(i)
         mom = LorentzVector(p0v, pxv, pyv, pzv)
         call p%set_momentum(mom)
         pos = LorentzVector(r0(i), rx(i), ry(i), rz(i))
         call p%set_position(pos)
         call parts%push_back(p)
 10   continue
      return
      end

C ---------------------------------------------------------------------------
C Reference one-event UrQMD loop copied from urqmd.f and adapted:
C file writes removed/commented out, event state kept in memory.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_run_one_event(ebeam_out, bimp_out, np,
     &     parts)
      use cola
      implicit none
      real*8 ebeam_out, bimp_out
      integer np
      type(EventParticles), intent(inout) :: parts
      include 'coms.f'
      include 'comres.f'
      include 'options.f'
      include 'colltab.f'
      include 'inputs.f'
      include 'newpart.f'
      include 'boxinc.f'
      include 'freezeout.f'
C
      integer i,j,k,steps,ii,ocharge,ncharge, it1,it2
      real*8 sqrts,otime,xdummy,st
      logical isstable
      integer stidx,CTOsave
      real*8 Ekinbar, Ekinmes, ESky2, ESky3, EYuk, ECb, EPau
      common /energies/ Ekinbar, Ekinmes, ESky2, ESky3, EYuk, ECb, EPau
      integer cti1sav,cti2sav
      real*8 thydro_start,thydro,nucrad
      logical lhydro

      event = 1
      time = 0.0
      lhydro = .true.

C     initialize random number generator (per event)
      if (.not.firstseed .and. (.not.fixedseed)) then
         ranseed = -(1*abs(ranseed))
         call sseed(ranseed)
      else
         firstseed = .false.
      endif

C     Init resonance reconstruction (only f13)
      if (.not.bf13.and.CTOption(68).eq.1) then
       call init_resrec
      endif

C     eccentricity (init sets nuclei; this computes Glauber observables)
      call init
      call init_eccentricity

      if (CTOption(40).ne.0 .and. (.not.success)) return

C     hydro switch
      if (CTOption(45).eq.1) then
         thydro_start = CTParam(65)*2.d0*nucrad(Ap)*sqrt(2.d0*emnuc/
     &        ebeam)
         if (thydro_start.lt.CTParam(63)) then
            thydro_start = CTParam(63)
         endif
      endif

      if (CTOption(40).ne.0) time = acttime

C     output preparation
      ! call output(13)
      ! call output(14)
      ! call output(15)
      ! call output(16)
      ! if (event.eq.1) then
      !    call output(17)
      !    call osc_header
      !    call osc99_header
      ! endif
      ! call osc99_event(-1)

C     for CTOption(4)=1 : output of initialization configuration
      ! if (CTOption(4).eq.1) call file14out(0)
      if (CTOption(4).eq.1) call urqmd_cola_file14out_to_parts(0, parts)

C     participant/spectator model
      if (CTOption(28).ne.0) call rmspec(0.5d0*bimp,-(0.5d0*bimp))

      otime = outsteps*dtimestep
      steps = 0

C     loop over all timesteps
      do 20 steps = 1, nsteps
         if (eos.ne.0) then
            do 23 j = 1, npart
               r0_t(j) = r0(j)
               rx_t(j) = rx(j)
               ry_t(j) = ry(j)
               rz_t(j) = rz(j)
 23         continue
         endif

         acttime = time
         if (CTOption(16).ne.0) goto 103

         call colload
         if (nct.gt.0) then

 101        continue
            k = 0
 100        continue
            call getnext(k)
            if (k.eq.0) goto 102

            if (CTOption(45).eq.1) then
               if (cttime(k).gt.thydro_start .and. lhydro) then
                  if (CTOption(62).eq.1) then
                     call prepout
                     ! call file14out(0)
                     call urqmd_cola_file14out_to_parts(0, parts)
                     call restore
                  endif
                  st = thydro_start - acttime
                  call cascstep(acttime,st)
                  acttime = thydro_start
                  lhydro = .false.
                  if (CTOption(50).eq.1) return
                  if (thydro.gt.1.d-8 .or. CTOption(48).eq.1) then
                     call colload
                     goto 101
                  endif
               endif
            endif

            st = cttime(k) - acttime
            call cascstep(acttime,st)
            acttime = cttime(k)

            if (cti2(k).gt.0 .and.
     .          abs(sqrts(cti1(k),cti2(k))-ctsqrts(k)).gt.1d-3) then
               write(6,*) ' ***(E) wrong collision update (col) ***'
            else if (cti2(k).eq.0 .and.
     .          abs(fmass(cti1(k))-ctsqrts(k)).gt.1d-3) then
               write(6,*) ' *** main(W) wrong collision update (decay)'
            endif

            ocharge = charge(cti1(k))
            if (cti2(k).gt.0) ocharge = ocharge + charge(cti2(k))
            it1 = ityp(cti1(k))
            if (cti2(k).gt.0) it2 = ityp(cti2(k))

            cti1sav = cti1(k)
            cti2sav = cti2(k)
            call scatter(cti1(k),cti2(k),ctsigtot(k),ctsqrts(k),
     &           ctcolfluc(k))

            if (CTOption(17).eq.0) then
               if (nexit.eq.0) then
                  if (cti1(k).ne.cti1sav .or. cti2(k).ne.cti2sav) then
                     cti1(k) = cti1sav
                     cti2(k) = cti2sav
                  endif
                  call collupd(cti1(k),1)
                  if (cti2(k).gt.0) call collupd(cti2(k),1)
               else
                  ncharge = 0
                  do 30 i = 1, nexit
                     ncharge = ncharge + charge(inew(i))
                     call collupd(inew(i),1)
 30               continue
                  do 55 ii = 1, nsav
                     call collupd(ctsav(ii),1)
 55               continue
                  nsav = 0
               endif
            else
               call colload
            endif

            if (CTOption(17).eq.0) goto 100
            goto 101

 102        continue
         endif

 103     continue
         time = time + dtimestep
         call cascstep(acttime,time-acttime)

         if (eos.ne.0) then
            do 24 j = 1, npart
               r0(j) = r0_t(j)
               rx(j) = rx_t(j)
               ry(j) = ry_t(j)
               rz(j) = rz_t(j)
 24         continue
            call proprk(time,dtimestep)
         endif

C     perform output if desired
         if (mod(steps,outsteps).eq.0 .and. steps.lt.nsteps) then
            if (CTOption(28).eq.2) call spectrans(otime)
            if (CTOption(62).eq.1) call prepout
            ! call file14out(steps)
            call urqmd_cola_file14out_to_parts(steps, parts)
C           if (CTOption(64).eq.1) call file13out(steps)
            if (CTOption(62).eq.1) then
               call restore
               call colload
            endif
C           if (CTOption(55).eq.1) call osc_vis(steps)
         endif
 20   continue

C     final decay of unstable particles
      acttime = time
      if (CTOption(18).eq.0) then
         i = 0
         nct = 0
         actcol = 0
         CTOsave = CTOption(10)
         CTOption(10) = 1
 40      continue
         i = i + 1
         if (dectime(i).lt.1.d30) then
 41         continue
            isstable = .false.
            do 44 stidx = 1, nstable
               if (ityp(i).eq.stabvec(stidx)) isstable = .true.
 44         enddo
            if (.not.isstable) then
               call scatter(i,0,0.d0,fmass(i),xdummy)
               if (dectime(i).lt.1.d30) goto 41
            endif
         endif
         if (i.lt.npart) goto 40
         CTOption(10) = CTOsave
      endif
      if (CTOption(64).eq.1) call coalescence

C     Match pure UrQMD: file13out, file14out, file16out (same execution order)
      ! call file13out(nsteps)
      if (CTOption(50).eq.0) then
      !  call file14out(nsteps)
         call urqmd_cola_file14out_to_parts(nsteps, parts)
      endif
      ! call file16out
      ! if (CTOption(50).eq.0.and.CTOption(55).eq.0) call osc_event
      ! if (CTOption(50).eq.0.and.CTOption(55).eq.1) call osc_vis(nsteps)
      ! call osc99_event(1)
      ! call osc99_eoe

      ebeam_out = ebeam
      bimp_out = bimp
      np = npart
      return
      end
