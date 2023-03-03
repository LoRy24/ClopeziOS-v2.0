;;;                                                                                             ;;;
;;; The printing utility. Used to print data in 16 bits mode. Used by the Boot Loader to print  ;;;
;;; things                                                                                      ;;;
;;;                                                                                             ;;;

;;; The print char utility. Used to print a char using the video service (0x10) interrupt.
;;; Uses the tty mode
print_char:
    mov         ah, 0x0E                        ;; TTY mode (by video service)
    mov         bx, 0                           ;; clear BX
    int         0x10                            ;; call the interrupt

    ret                                         ;; give back the control to the caller

;;; This function prints a string to the screen. It should be put in the 'si' register
print_string:   
.p_loop:                                        ;; define the loop
    lodsb                                       ;; load the value pointed in si to al

    cmp         al, 0                           ;; compare al with the end character (0)
    je          .p_loop_end                     ;; give back the control and end the loop

    call        print_char                      ;; call the print char utility
    jmp         .p_loop                         ;; go back to the start of the loop

.p_loop_end:        
    ret                                         ;; give back the control to the caller

;;; Print a new line character (\n). Uses the print_char function
print_newline_character:
    mov         si, new_line_string             ;; mov the newline sequence in SI
    call        print_string                    ;; call the print string function

    ret                                         ;; give back the control to the caller 

;;; This definition represent the new line sequence. 0xD = carriage_return, 0xA = newline
new_line_string:
    ;;;         n_l  c_r  null
    db          0xD, 0xA, 0x00              