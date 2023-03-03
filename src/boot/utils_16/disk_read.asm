;;;                                                                                             ;;;
;;; This utility is used to read data from the disk and load it in the memory                   ;;;
;;;                                                                                             ;;;

;;; Read sectors from the disk
read_sectors_from_disk:
    mov         ah, 0x02                        ;; select the operation (read sectors)
    ;mov         al, 1                          ;; read only one sector
    mov         ch, 0                           ;; cylinder 0
    ;mov         cl, 2                          ;; sector from where to start reading
    mov         dh, 0                           ;; head 0
    int         0x13

    cmp         ah, 0                           ;; check if no errors occurs
    je          .reading_end                    ;; jmp to the end

    mov         si, disk_read_error_message     ;; load the error message
    call        print_string                    ;; print the error message
.reading_end:
    ret                                         ;; give back the control to the caller

;;; This is the error message that will be print if an error occurs
disk_read_error_message: 
    db          "Error while reading from disk", 0