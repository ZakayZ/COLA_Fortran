! ---------------------------------------------------------------------------
! C interface: allocate handle (local pointer), init, run, deallocate via c_f_pointer.
! ---------------------------------------------------------------------------
module generator_wrapper
  use, intrinsic :: iso_c_binding
  use cola
  use cola_fortran_generator_impl
  implicit none
  private
contains
  function cola_fortran_FortranGenerator_create(params) bind(C, name="cola_fortran_FortranGenerator_create") result(handle)
    type(c_ptr), intent(in), value :: params
    type(c_ptr) :: handle
    type(ParametersMap) :: pmap
    type(FortranGenerator), pointer :: cls
    if (c_associated(params)) then
      pmap%swigdata%cptr = params
      pmap%swigdata%cmemflags = 0
    else
      pmap = ParametersMap()
    end if
    allocate(cls)
    call cls%init(pmap)
    handle = c_loc(cls)
  end function cola_fortran_FortranGenerator_create

  function cola_fortran_FortranGenerator_run(handle) bind(C, name="cola_fortran_FortranGenerator_run") result(data)
    type(c_ptr), intent(in), value :: handle
    type(c_ptr) :: data
    type(EventData) :: ed
    type(FortranGenerator), pointer :: cls
    call c_f_pointer(handle, cls)
    ed = cls%run()
    data = ed%swigdata%cptr
    ! Transfer ownership to C: Fortran must not delete when ed goes out of scope
    ed%swigdata%cmemflags = 0
  end function cola_fortran_FortranGenerator_run

  subroutine cola_fortran_FortranGenerator_destroy(handle) bind(C, name="cola_fortran_FortranGenerator_destroy")
    type(c_ptr), intent(in), value :: handle
    type(FortranGenerator), pointer :: cls
    call c_f_pointer(handle, cls)
    deallocate(cls)
  end subroutine cola_fortran_FortranGenerator_destroy
end module generator_wrapper
