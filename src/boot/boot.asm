;;;                                                                                             ;;;
;;; The best Operating System that you could have. The ClopezioOS, made for the best            ;;;
;;; cock inspector eu.                                                                          ;;;
;;;                                                                                             ;;;

    org     0x7c00

;;; The entry of the code
main_code:                                                      ;; the entry point label
    ;;; Set the offset
    cli                                                         ;; clear the interrupts
    mov     ax, 0x00                                            ;; set the segment location to 0x7c0
    mov     ds, ax                                              ;; update the data segment
    mov     es, ax                                              ;; update the extra segment
    mov     ss, ax                                              ;; update the stack segment
    mov     sp, 0x7c00                                          ;; update the stack pointer to 0x7c00
    sti                                                         ;; enable the interrupts

    ;;; Register the interrupts
    mov     word[ss:0x00], handle_zero                          ;; set the interrupt offset
    mov     word[ss:0x02], 0x7c0                                ;; set the interrupt sector

    ;;; Read data from the disk
    mov     al, 1                                               ;; read 2 sectors from the disk
    mov     cl, 2                                               ;; read from the 2nd sector

    xor     bx, bx                                              ;; clear the bx register
    mov     es, bx                                              ;; move bx to es (for buffer pointing)
    mov     bx, new_sector_buffer                               ;; give the buffer address to bx

    call    read_sectors_from_disk                              ;; call the created function

    call    clear_screen                                        ;; clear the screen

    ;;; Test feature
    mov     si, hello_world                                     ;; move the hello world string in the memory
    mov     ah, 00001110b                                       ;; move the color (BGBG FGFG)
    call    print_string_directly_to_vga_memory                 ;; print the string

    jmp     $                                                   ;; LOOP: jmp to the current addr ($)

hello_world:
    db      "Hello World!", 0x0A, 0                             ;; Define the Hello World string

;;; Include the utilities of the boot sector
include     "./utils_16/print_utilities.asm"
include     "./utils_16/disk_read.asm"
include     "./utils_16/interrupts/interrupt_zero.asm"

;;; Fill the sector space with 0
    times   510 - ($ - $$) db 0

;;; Add the boot signature
    dw      0xAA55

;;; The buffer location
new_sector_buffer:

;;; Include the printing utility in the new sector
include     "./utils_16/print_direct_utilities.asm"             ;; load the direct printing utility in the new sector
