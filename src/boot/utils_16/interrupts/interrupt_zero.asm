;;;                                                                                             ;;;
;;; This file contains the interrupt number 0x00. This interrupt is called when the             ;;; 
;;; computer tries to divide a number by 0.                                                     ;;;
;;;                                                                                             ;;;

;;; This code handles the interrupt 0
handle_zero:
    pusha                                                       ;; push all the registers

    mov         si, zero_interrupt_message                      ;; move the interrupt message in the si register
    call        print_string                                    ;; print the string

    popa                                                        ;; pop all the registers

    iret                                                        ;; return from the interrupt

;;; The interrupt message
zero_interrupt_message:
    db          "Non puoi dividere un numero per 0!", 0
