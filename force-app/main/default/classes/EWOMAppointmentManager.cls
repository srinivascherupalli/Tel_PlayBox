/*
 *   Description : This class exposes EWOM Slot Availability(Appointment Manager) related operations to required controllers
 *
*/
public with sharing class EWOMAppointmentManager {
    private static EWOMAppointmentManager singleton = new EWOMAppointmentManager ( );
    private EWOMAppointmentManager(){}
    
    public static EWOMAppointmentManager getInstance( ) {
      return singleton;
    }
    /**
    * Method to fetch the Slot Availability result for Site
    * @params SlotApptRequestDTO
    * @return SlotApptResponseDTO
    */
    
    public static AppointmentSlotResponseDTO searchAppointment(AppointmentSlotRequestDTO request) {
        return EWOMAppointmentService.searchAppointment(request);
    }

    /**
    * Method to fetch the Slot Availability result for Site
    * @params AppointmentReserveRequestDTO
    * @return HttpResponse
    */
    
    public static HttpResponse reserveAppointment(AppointmentReserveRequestDTO request, String slotId) {
        return EWOMAppointmentService.reserveAppointment(request, slotId);
    }
     /**
    * Method to fetch the Slot Availability result for Reschedule Appointment for Site  
    * @params AppointmentRescheduleRequestDTO
    * @return AppointmentSlotResponseDTO
    */
    
    public static AppointmentSlotResponseDTO searchRescheduleAppointment(AppointmentRescheduleRequestDTO request, String appointmentId) {
        return EWOMAppointmentService.searchRescheduleAppointment(request,appointmentId);
    }
    
    /**
    * Method to reserve slot for Reschedule Appointment for Site  
    * @params AppointmentReserveRequestDTO, Slot Id, Appointment Id
    * @return HttpResponse
    */
    
    public static HttpResponse reserveRescheduleAppointment(AppointmentReserveRequestDTO request, String slotId, String appointmentId) {
        return EWOMAppointmentService.reserveRescheduleAppointment(request, slotId, appointmentId);
    }
    
    //Edge-10652...
    public static AppointmentSlotResponseDTO searchRebookAppointment(AppointmentRescheduleRequestDTO request, String appointmentId) {
        return EWOMAppointmentService.searchRebookAppointment(request,appointmentId);
    }
    
    public static HttpResponse reserveRebookAppointment(AppointmentReserveRequestDTO request, String slotId, String appointmentId) {
        return EWOMAppointmentService.reserveRebookAppointment(request, slotId, appointmentId);
    }
}