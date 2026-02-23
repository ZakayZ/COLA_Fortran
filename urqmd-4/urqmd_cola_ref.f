C ---------------------------------------------------------------------------
C Glue subroutines (merged from bridge). Callable from cola_fortran_generator_impl.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_uinit(io)
      implicit none
      integer io
      call uinit(io)
      return
      end

      subroutine urqmd_cola_get_ebeam_bimp(ebeam_out, bimp_out)
      implicit none
      real*8 ebeam_out, bimp_out
      include 'coms.f'
      ebeam_out = ebeam
      bimp_out = bimp
      return
      end

      subroutine urqmd_cola_init_event
      implicit none
      include 'coms.f'
      call init
      return
      end

      subroutine urqmd_cola_run_cascade
      implicit none
      call urqmd_cola_run_one_event
      return
      end

      subroutine urqmd_cola_get_particle(i, r0v, rxv, ryv, rzv, p0v,
     +     pxv, pyv, pzv, fmassv, itypv, iso3v, np)
      implicit none
      integer i, np, itypv, iso3v
      real*8 r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv
      real*8 pxfull, pyfull, pzfull
      include 'coms.f'
      np = npart
      if (i.lt.1 .or. i.gt.npart) return
      r0v = r0(i)
      rxv = rx(i)
      ryv = ry(i)
      rzv = rz(i)
      fmassv = fmass(i)
      pxfull = px(i) + ffermpx(i)
      pyfull = py(i) + ffermpy(i)
      pzfull = pz(i) + ffermpz(i)
      p0v = sqrt(pxfull**2 + pyfull**2 + pzfull**2 + fmassv**2)
      pxv = pxfull
      pyv = pyfull
      pzv = pzfull
      itypv = ityp(i)
      iso3v = iso3(i)
      return
      end

C ---------------------------------------------------------------------------
C Reference: One-event UrQMD loop from urqmd.f (lines 59-411)
C All file outputs removed (original code in comments).
C Call urqmd_cola_init_event (init) before this.
C Particles returned in coms.f / freezeout.f (file13 format).
C Event metadata in common /urqmd_cola_meta/.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_run_one_event
      implicit none
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

C Event metadata: filled after event (file13-style)
      integer meta_event, meta_npart, meta_ttime
      integer meta_itotcoll, meta_NElColl, meta_iinelcoll
      integer meta_NBlColl, meta_dectag
      integer meta_NHardRes, meta_NSoftRes, meta_NDecRes
      common /urqmd_cola_meta/ meta_event, meta_npart, meta_ttime,
     +     meta_itotcoll, meta_NElColl, meta_iinelcoll,
     +     meta_NBlColl, meta_dectag,
     +     meta_NHardRes, meta_NSoftRes, meta_NDecRes

C start event here (init already called by urqmd_cola_init_event)
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
      if (.not.bf13 .and. CTOption(68).eq.1) call init_resrec

C     eccentricity (init sets nuclei; this computes Glauber observables)
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

C Original: output preparation - write headers to files
Cc     call output(13)
Cc     call output(14)
Cc     call output(15)
Cc     call output(16)
Cc     if(event.eq.1) then
Cc       call output(17)
Cc       call osc_header
Cc       call osc99_header
Cc     endif
Cc     call osc99_event(-1)

C     for CTOption(4)=1 : output of initialization configuration
Cc     if (CTOption(4).eq.1) then
Cc       call file14out(0)
Cc     endif

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
Cc                if (CTOption(62).eq.1) then
Cc                  call prepout
Cc                  call file14out(0)
Cc                  call restore
Cc                endif
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

C Original: intermediate output
Cc        if (mod(steps,outsteps).eq.0 .and. steps.lt.nsteps) then
Cc           if (CTOption(28).eq.2) call spectrans(otime)
Cc           if (CTOption(62).eq.1) call prepout
Cc           call file14out(steps)
Cc           if (CTOption(64).eq.1) then
Cc             call file13out(steps)
Cc           endif
Cc           if (CTOption(62).eq.1) then
Cc             call restore
Cc             call colload
Cc           endif
Cc           if (CTOption(55).eq.1) then
Cc             call osc_vis(steps)
Cc           endif
Cc        endif

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

C Original: final output
Cc     if (CTOption(64).eq.1) call coalescence
Cc     call file13out(nsteps)
Cc     if (CTOption(50).eq.0) then
Cc       call file14out(nsteps)
Cc     endif
Cc     call file16out
Cc     if (CTOption(50).eq.0 .and. CTOption(55).eq.0) then
Cc       call osc_event
Cc     endif
Cc     if (CTOption(50).eq.0 .and. CTOption(55).eq.1) then
Cc       call osc_vis(nsteps)
Cc     endif
Cc     call osc99_event(1)
Cc     call osc99_eoe

C Fill event metadata (file13-style)
      meta_event = event
      meta_npart = npart
      if (CTOption(64).eq.1) meta_npart = npartcoal
      meta_ttime = int(nsteps*dtimestep+0.01)
      meta_itotcoll = ctag - dectag
      meta_iinelcoll = meta_itotcoll - NBlColl - NElColl
      meta_NBlColl = NBlColl
      meta_NElColl = NElColl
      meta_dectag = dectag
      meta_NHardRes = NHardRes
      meta_NSoftRes = NSoftRes
      meta_NDecRes = NDecRes

C Particles returned in coms.f / freezeout.f (file13 format).
C Use urqmd_cola_get_meta for event metadata.
C Use urqmd_cola_get_particle_file13 for file13-style particles (lstcoll.ge.-1).
      return
      end

C ---------------------------------------------------------------------------
C Get event metadata (file13-style). Call after urqmd_cola_run_one_event.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_get_meta(ev, np, ttime, itot, iel, iinel,
     +     nbl, ndec, nhr, nsr, ndr)
      implicit none
      integer ev, np, ttime, itot, iel, iinel, nbl, ndec, nhr, nsr, ndr
      integer meta_event, meta_npart, meta_ttime
      integer meta_itotcoll, meta_NElColl, meta_iinelcoll
      integer meta_NBlColl, meta_dectag
      integer meta_NHardRes, meta_NSoftRes, meta_NDecRes
      common /urqmd_cola_meta/ meta_event, meta_npart, meta_ttime,
     +     meta_itotcoll, meta_NElColl, meta_iinelcoll,
     +     meta_NBlColl, meta_dectag,
     +     meta_NHardRes, meta_NSoftRes, meta_NDecRes
      ev = meta_event
      np = meta_npart
      ttime = meta_ttime
      itot = meta_itotcoll
      iel = meta_NElColl
      iinel = meta_iinelcoll
      nbl = meta_NBlColl
      ndec = meta_dectag
      nhr = meta_NHardRes
      nsr = meta_NSoftRes
      ndr = meta_NDecRes
      return
      end

C ---------------------------------------------------------------------------
C Get particle i in file13 format (lstcoll.ge.-1 only).
C Production: r0,rx,ry,rz, p0,px,py,pz. Freeze-out: fr0,frx,fry,frz, fp0,fpx,fpy,fpz.
C Returns 1 if particle written to file13, 0 otherwise. np = count of file13 particles.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_get_particle_file13(i, r0v,rxv,ryv,rzv,
     +     p0v,pxv,pyv,pzv, fmassv, itypv, iso3v, chgv, lclv, nclv, orv,
     +     fr0v,frxv,fryv,frzv, fp0v,fpxv,fpyv,fpzv, np, ok)
      implicit none
      include 'coms.f'
      include 'options.f'
      include 'freezeout.f'
      integer i, np, itypv, iso3v, chgv, lclv, nclv, orv, ok
      real*8 r0v,rxv,ryv,rzv, p0v,pxv,pyv,pzv, fmassv
      real*8 fr0v,frxv,fryv,frzv, fp0v,fpxv,fpyv,fpzv
      real*8 pxfull, pyfull, pzfull
      integer j, k

      np = 0
      do j = 1, npart
         if (lstcoll(j).ge.-1) np = np + 1
      enddo

      ok = 0
      if (i.lt.1) return
      k = 0
      do j = 1, npart
         if (lstcoll(j).lt.-1) goto 90
         k = k + 1
         if (k.eq.i) then
            r0v = r0(j)
            rxv = rx(j)
            ryv = ry(j)
            rzv = rz(j)
            fmassv = fmass(j)
            pxfull = px(j) + ffermpx(j)
            pyfull = py(j) + ffermpy(j)
            pzfull = pz(j) + ffermpz(j)
            p0v = sqrt(pxfull**2 + pyfull**2 + pzfull**2 + fmassv**2)
            pxv = pxfull
            pyv = pyfull
            pzv = pzfull
            itypv = ityp(j)
            iso3v = iso3(j)
            chgv = charge(j)
            lclv = lstcoll(j)
            nclv = ncoll(j)
            orv = mod(origin(j), 100)
            if (ncoll(j).eq.0) then
               fr0v = r0(j)
               frxv = rx(j)
               fryv = ry(j)
               frzv = rz(j)
               fp0v = p0v
               fpxv = pxv
               fpyv = pyv
               fpzv = pzv
            else
               fr0v = frr0(j)
               frxv = frrx(j)
               fryv = frry(j)
               frzv = frrz(j)
               fp0v = frp0(j)
               fpxv = frpx(j)
               fpyv = frpy(j)
               fpzv = frpz(j)
            endif
            ok = 1
            return
         endif
 90      continue
      enddo
      return
      end
