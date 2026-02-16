! ---------------------------------------------------------------------------
! C interface: allocate handle (local pointer), init, run, deallocate via c_f_pointer.
! ---------------------------------------------------------------------------
module converter_wrapper
  use, intrinsic :: iso_c_binding
  use cola
  use cola_fortran_converter_impl
  implicit none
  private
contains
  function cola_fortran_FortranConverter_create(params) bind(C, name="cola_fortran_FortranConverter_create") result(handle)
    type(c_ptr), intent(in), value :: params
    type(c_ptr) :: handle
    type(ParametersMap) :: pmap
    type(FortranConverter), pointer :: cls
    if (c_associated(params)) then
      pmap%swigdata%cptr = params
      pmap%swigdata%cmemflags = 0
    else
      pmap = ParametersMap()
    end if
    allocate(cls)
    call cls%init(pmap)
    handle = c_loc(cls)
  end function cola_fortran_FortranConverter_create

  subroutine cola_fortran_FortranConverter_run(handle, data) bind(C, name="cola_fortran_FortranConverter_run")
    type(c_ptr), intent(in), value :: handle
    type(c_ptr), intent(in), value :: data
    type(EventData) :: ed
    type(FortranConverter), pointer :: cls
    ed%swigdata%cptr = data
    ed%swigdata%cmemflags = 0
    call c_f_pointer(handle, cls)
    call cls%run(ed)
  end subroutine cola_fortran_FortranConverter_run

  subroutine cola_fortran_FortranConverter_destroy(handle) bind(C, name="cola_fortran_FortranConverter_destroy")
    type(c_ptr), intent(in), value :: handle
    type(FortranConverter), pointer :: cls
    call c_f_pointer(handle, cls)
    deallocate(cls)
  end subroutine cola_fortran_FortranConverter_destroy
end module converter_wrapper
