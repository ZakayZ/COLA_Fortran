C ---------------------------------------------------------------------------
C Bridge between URQMD and COLA Fortran wrapper.
C Provides subroutines to set params, init event, run cascade, get particle data.
C Per UrQMD manual: output uses px+ffermpx (frozen Fermi); cascade must run.
C ---------------------------------------------------------------------------
      subroutine urqmd_cola_set_params(ap_in, at_in, zp_in, zt_in,
     &     ebeam_in, bimp_in, seed_in, nsteps_in, dtimestep_in, eos_in,
     &     nev_in, tottime_in, outtime_in, pbeam_in, srt_in,
     &     srtmin_in, srtmax_in, nsrt_in, pbmin_in, pbmax_in, npb_in,
     &     bmin_in, bmax_in, imp_random_in,
     &     pro_special_in, spityp_p_in, spiso3_p_in,
     &     tar_special_in, spityp_t_in, spiso3_t_in,
     &     box_in, lbox_in, edens_in, solid_in, para_in,
     &     cdt_in)
      implicit none
      include 'coms.f'
      include 'inputs.f'
      include 'options.f'
      include 'boxinc.f'
      integer ap_in, at_in, zp_in, zt_in, seed_in, nsteps_in, eos_in
      integer nev_in, nsrt_in, npb_in, imp_random_in
      integer pro_special_in, spityp_p_in, spiso3_p_in
      integer tar_special_in, spityp_t_in, spiso3_t_in
      integer box_in, solid_in, para_in
      real*8 ebeam_in, bimp_in, dtimestep_in
      real*8 tottime_in, outtime_in, pbeam_in, srt_in
      real*8 srtmin_in, srtmax_in, pbmin_in, pbmax_in
      real*8 bmin_in, bmax_in, lbox_in, edens_in, cdt_in

      Ap = ap_in
      At = at_in
      Zp = zp_in
      Zt = zt_in
      ebeam = ebeam_in
      bimp = bimp_in
      bdist = bimp_in
      bmin = 0.d0
      nevents = 1
      if (nev_in.gt.0) nevents = nev_in
      nsteps = nsteps_in
      if (nsteps.le.0) nsteps = 200
      prspflg = 0
      trspflg = 0
      srtflag = 0
      boxflag = 0
      eos = eos_in
      event = 1
      CTOption(5) = 0
      dtimestep = dtimestep_in
      if (dtimestep.le.0.d0) dtimestep = 0.2d0
      outsteps = nsteps
C     tim: tottime, outtime (fm/c)
      if (tottime_in.gt.0.d0) nsteps =
     &     int(0.01d0 + tottime_in/dtimestep)
      if (outtime_in.gt.0.d0) outsteps =
     &     int(0.01d0 + outtime_in/dtimestep)
C     cdt: timestep
      if (cdt_in.gt.0.d0) dtimestep = cdt_in
C     plb / ecm / ENE
      if (pbeam_in.ge.0.d0) then
        srtflag = 2
        pbeam = pbeam_in
      endif
      if (srt_in.gt.0.d0) then
        srtflag = 1
        srtmin = srt_in
        srtmax = srt_in
        nsrt = 1
        ecm = srt_in
      endif
      if (srtmin_in.gt.0.d0.and.srtmax_in.gt.0.d0) then
        srtflag = 1
        srtmin = srtmin_in
        srtmax = srtmax_in
        if (nsrt_in.gt.0) nsrt = nsrt_in
        ecm = srtmin
      endif
      if (pbmin_in.ge.0.d0.and.pbmax_in.ge.0.d0) then
        srtflag = 2
        pbmin = pbmin_in
        pbmax = pbmax_in
        if (npb_in.gt.0) npb = npb_in
        pbeam = pbmin
      endif
C     imp / IMP
      if (bmax_in.ge.0.d0) then
        bdist = bmax_in
        bmin = bmin_in
        if (imp_random_in.ne.0) CTOption(5) = 1
      endif
C     PRO: special projectile
      if (pro_special_in.ne.0) then
        prspflg = 1
        spityp(1) = spityp_p_in
        spiso3(1) = spiso3_p_in
        Ap = 1
      endif
C     TAR: special target
      if (tar_special_in.ne.0) then
        trspflg = 1
        spityp(2) = spityp_t_in
        spiso3(2) = spiso3_t_in
        At = 1
      endif
C     box: infinite-matter box
      if (box_in.ne.0.and.lbox_in.gt.0.d0) then
        boxflag = 1
        mbox = 0
        lbox = lbox_in
        lboxhalbe = lbox/2.d0
        lboxd = lbox*2.d0
        if (edens_in.ge.0.d0) then
          edens = edens_in
          edensflag = 1
        else
          edens = 0.d0
          edensflag = 0
        endif
        solid = solid_in
        para = para_in
      endif
C     uinit(1) skips cascinit; init needs PT_* from cascinit for getnucleus
      if (boxflag.eq.0) then
        if (prspflg.eq.0) call cascinit(Zp, Ap, 1)
        if (At.gt.0.and.trspflg.eq.0) call cascinit(Zt, At, 2)
      endif
C     Set random seed for reproducibility (seed_in>0: fixed, <=0: auto from time)
      ranseed = seed_in
      call sseed(ranseed)
      return
      end

      subroutine urqmd_cola_set_bpt(ibox, ityp_in, iso3_in, npart_in,
     &     pmax_in)
      implicit none
      include 'boxinc.f'
      integer ibox, ityp_in, iso3_in, npart_in
      real*8 pmax_in
      if (ibox.ge.1.and.ibox.le.bptmax) then
        bptityp(ibox) = ityp_in
        bptiso3(ibox) = iso3_in
        bptpart(ibox) = npart_in
        bptpmax(ibox) = pmax_in
        if (mbox.lt.ibox) mbox = ibox
        edensflag = 0
      endif
      return
      end

      subroutine urqmd_cola_set_bpe(ibox, ityp_in, iso3_in, npart_in)
      implicit none
      include 'boxinc.f'
      integer ibox, ityp_in, iso3_in, npart_in
      if (ibox.ge.1.and.ibox.le.bptmax) then
        bptityp(ibox) = ityp_in
        bptiso3(ibox) = iso3_in
        bptpart(ibox) = npart_in
        bptpmax(ibox) = 0.d0
        if (mbox.lt.ibox) mbox = ibox
        edensflag = 1
      endif
      return
      end

      subroutine urqmd_cola_set_stb(ityp_in)
      implicit none
      include 'options.f'
      integer ityp_in
      if (nstable.lt.maxstables) then
        nstable = nstable + 1
        stabvec(nstable) = ityp_in
      endif
      return
      end

      subroutine urqmd_cola_set_ctparam(i, val)
      implicit none
      include 'options.f'
      integer i
      real*8 val
      if (i.ge.1.and.i.le.numctp) CTParam(i) = val
      return
      end

      subroutine urqmd_cola_set_ctoption(i, ival)
      implicit none
      include 'options.f'
      integer i, ival
      if (i.ge.1.and.i.le.numcto) CTOption(i) = ival
      return
      end

      subroutine urqmd_cola_set_input_file(path)
      use, intrinsic :: iso_c_binding
      implicit none
      character*(*), intent(in) :: path
      character(len=6, kind=c_char) :: name
      character(len=512, kind=c_char) :: path_c
      integer(c_int) :: ierr
      interface
        function setenv_c(n, v, o) bind(c, name="setenv")
          use iso_c_binding
          integer(c_int) :: setenv_c
          character(kind=c_char), intent(in) :: n(*), v(*)
          integer(c_int), value :: o
        end function
      end interface
      name = "ftn09" // c_null_char
      path_c = trim(path) // c_null_char
      ierr = setenv_c(name, path_c, 1)
      return
      end

      subroutine urqmd_cola_uinit(io)
      implicit none
      integer io
      call uinit(io)
      return
      end

      subroutine urqmd_cola_get_ebeam_bimp(ebeam_out, bimp_out)
      implicit none
      include 'coms.f'
      real*8 ebeam_out, bimp_out
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

C     Run cascade propagation (colload, getnext, cascstep, scatter loop).
C     Performs final decay of unstable particles (like pure UrQMD) before return.
      subroutine urqmd_cola_run_cascade
      implicit none
      include 'coms.f'
      include 'options.f'
      include 'colltab.f'
      include 'newpart.f'
      integer steps, k, i, ii, ocharge, ncharge
      integer cti1sav, cti2sav, it1, it2, stidx, CTOsave
      real*8 st, xdummy
      logical isstable

      time = 0.d0
      acttime = 0.d0

      do 20 steps = 1, nsteps
         if (CTOption(16).ne.0) goto 103
         call colload
         if (nct.le.0) goto 102

 101     k = 0
 100     call getnext(k)
         if (k.eq.0) goto 102
         st = cttime(k) - acttime
         call cascstep(acttime, st)
         acttime = cttime(k)

         cti1sav = cti1(k)
         cti2sav = cti2(k)
         ocharge = charge(cti1(k))
         if (cti2(k).gt.0) ocharge = ocharge + charge(cti2(k))
         it1 = ityp(cti1(k))
         if (cti2(k).gt.0) it2 = ityp(cti2(k))

         call scatter(cti1(k), cti2(k), ctsigtot(k), ctsqrts(k),
     &        ctcolfluc(k))

         if (CTOption(17).eq.0) then
            if (nexit.eq.0) then
               if (cti1(k).ne.cti1sav.or.cti2(k).ne.cti2sav) then
                  cti1(k) = cti1sav
                  cti2(k) = cti2sav
               endif
               call collupd(cti1(k), 1)
               if (cti2(k).gt.0) call collupd(cti2(k), 1)
            else
               ncharge = 0
               do 30 i = 1, nexit
                  ncharge = ncharge + charge(inew(i))
                  call collupd(inew(i), 1)
 30            continue
               do 55 ii = 1, nsav
                  call collupd(ctsav(ii), 1)
 55            continue
               nsav = 0
            endif
         else
            call colload
         endif

         if (CTOption(17).eq.0) goto 100
         goto 101

 102     continue
 103     continue
         time = time + dtimestep
         call cascstep(acttime, time - acttime)
         acttime = time
 20   continue
C     Final decay of unstable particles (matches pure UrQMD before file16out)
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
 44         continue
            if (.not.isstable) then
               call scatter(i, 0, 0.d0, fmass(i), xdummy)
               if (dectime(i).lt.1.d30) goto 41
            endif
         endif
         if (i.lt.npart) goto 40
         CTOption(10) = CTOsave
      endif
      return
      end

      subroutine urqmd_cola_get_particle(i, r0v, rxv, ryv, rzv, p0v,
     &     pxv, pyv, pzv, fmassv, itypv, iso3v, np)
      implicit none
      include 'coms.f'
      integer i, np
      real*8 r0v, rxv, ryv, rzv, p0v, pxv, pyv, pzv, fmassv
      integer itypv, iso3v
      real*8 pxfull, pyfull, pzfull

C     Per UrQMD manual: output always uses px+ffermpx (frozen Fermi default)
      np = npart
      if (i .ge. 1 .and. i .le. npart) then
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
      endif
      return
      end
