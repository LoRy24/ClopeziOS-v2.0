;;;                                                                                             ;;;
;;; This utility contains some code that should be used to print something into the screen      ;;;
;;; by accessing to the vga memory                                                              ;;;
;;;                                                                                             ;;;

;;;
;;; NOTES:
;;;     / VGA MEMORY WITH COLORS: START: 0xB8000 & END: 0xB8FA0, LAST BYTE: 0xB8F9F
;;;     / RESOLUTION: 80×25
;;;

;;;
;;; Print a character put in the register
;;; Params:
;;;       / al = The character to print
;;;       / ah = The color of the character
;;;
print_char_with_vga_memory_access:
    mov     edx, 0xB8000                                        ;; move in the edx register the vga memory address
    
    ;; Add the line offset
    mov     ebx, line_pointer                                   ;; move in ebx the line pointer address
    mov     ecx, [ebx]                                          ;; move the value of the pointer in ecx

.line_offset_loop: 
    cmp     ecx, 0                                              ;; compare ecx to 0
    je      .line_offset_loop_end                               ;; jump to the end of the loop
    
    sub     ecx, 1                                              ;; remove from ecx the value 1
    add     edx, 160                                            ;; add 160 bytes to the address

    jmp     .line_offset_loop                                   ;; make the loop

.line_offset_loop_end:

    ;;; Add the cursor offset
    mov     ebx, cursor_pointer                                 ;; move the cursor pointer address in ebx
    mov     ecx, [ebx]                                          ;; move the pointed value in ebx to ecx

.cursor_offset_loop:
    cmp     ecx, 0                                              ;; compare ecx to 0
    je      .cursor_offset_loop_end                             ;; jump to the end of the loop

    sub     ecx, 1                                              ;; remove from ecx 1
    add     edx, 2                                              ;; add 2 to the vga memory address

    jmp     .cursor_offset_loop                                 ;; make the loop

.cursor_offset_loop_end:

    ;;; Print the character
    mov     byte[edx], al                                       ;; move the letter to the first byte
    inc     edx                                                 ;; increase the vga pointer

    mov     byte[edx], ah                                       ;; move the color to the second byte
    inc     edx                                                 ;; increase the vga pointer

    ;; Increase by one the pointer
    call    increase_pointer_by_one                             ;; increase the printing pointer

    ret                                                         ;; give back the control to the caller

;;;
;;; Increase the screen printing position. This routine is better because it will automaticly 
;;; scroll the screen when needed. This code contains some sub routines that should not be 
;;; directly called
;;;
increase_pointer_by_one:
    pusha                                                       ;; push all the 16 bits registers to the stack
    pushad                                                      ;; push the 32 bits registers

    ;;; Check if the cursor pointer is pointing to 80   
    mov     eax, cursor_pointer                                 ;; load the cursor pointer
    mov     ebx, [eax]                                          ;; move the pointed value to ebx
    cmp     ebx, 79                                             ;; compare the loaded value to 79
    je      .increase_pointer_by_one_increase_line              ;; if it is, increase the line

    mov     ecx, [eax]                                          ;; move the pointed value to ecx
    add     ecx, 1                                              ;; increase the cursor pointer
    mov     dword[eax], ecx                                     ;; save the update in the memory

.increase_pointer_by_one_step_two:
    popad                                                       ;; restore all the 32 bits registers
    popa                                                        ;; restore the 16 bits registers

    ret                                                         ;; give back the control to the caller

.increase_pointer_by_one_increase_line:
    pusha                                                       ;; push all the 16 bits registers to the stack
    pushad                                                      ;; push the 32 bits registers

    mov     eax, line_pointer                                   ;; move the line pointer in the eax register
    mov     ebx, [eax]                                          ;; move the pointed value in ebx

    cmp     ebx, 24                                             ;; compare ebx to 24 (the last line on the screen)
    je      .increase_pointer_by_one_increase_line_scroll_screen    ;; scroll the screen

    add     ebx, 1                                              ;; add 1 to the line pointer
    mov     dword[eax], ebx                                     ;; save the update in the memory
.increase_pointer_by_one_increase_line_end:

    mov     eax, cursor_pointer                                 ;; move the cursor pointer to eax
    mov     dword[eax], 0x00                                    ;; save the value 0x00 in the memory

    popad                                                       ;; restore all the 32 bits registers
    popa                                                        ;; restore the 16 bits registers

    jmp     .increase_pointer_by_one_step_two                   ;; jump back to the caller

.increase_pointer_by_one_increase_line_scroll_screen:
    call    scroll_screen                                       ;; call the screen scrolling routine

    jmp     .increase_pointer_by_one_increase_line_end          ;; jump back to the caller

;;;
;;; Scroll the screen by one line
;;;
scroll_screen:
    pusha                                                       ;; push all the 16 bits registers to the stack
    pushad                                                      ;; push the 32 bits registers

    ;;; Clear the first line
    mov     eax, 0xB8000                                        ;; move the eax the vga memory address

.scroll_screen_loop_clear_first_line:

    cmp     eax, 0xB809E                                        ;; compare eax with the last byte of the vga memory
    je      .scroll_screen_loop_clear_first_line_end            ;; jump to the end of the loop

    mov     byte[eax], 0x00                                     ;; save the 0x00 value in memory
    add     eax, 1                                              ;; increase the pointer by two

    mov     byte[eax], 0x00                                     ;; save the 0x00 value in memory
    add     eax, 1                                              ;; increase the pointer

    jmp     .scroll_screen_loop_clear_first_line                ;; make the loop

.scroll_screen_loop_clear_first_line_end:

    mov     eax, 0xB80A0                                        ;; move the vga memory + 160 to eax
    mov     ebx, 0xB8000                                        ;; move the vga memory address to ebx

.scroll_characters_loop:

    cmp     eax, 0xB8FA0                                        ;; compare eax to the vga memory + 160
    je      .scroll_characters_loop_end                         ;; jump to the end of the loop

    mov     cl, [eax]                                           ;; move the value stored in eax to cl
    mov     byte[ebx], cl                                       ;; save cl to the new vga address

    mov     byte[eax], 0x00                                     ;; clear the last location

    add     eax, 1                                              ;; increase the current vga location
    add     ebx, 1                                              ;; increase the new vga address

    jmp     .scroll_characters_loop                             ;; make the loop

.scroll_characters_loop_end:

    popad                                                       ;; restore all the 32 bits registers
    popa                                                        ;; restore the 16 bits registers

    ret                                                         ;; give back the control to the caller

;;;
;;; This code prints a string stored in si to the screen using direct access to vga memory.
;;; Params:
;;;       / si = The string to print
;;;       / ah = The color of the string that will be print
;;;
print_string_directly_to_vga_memory:

.print_string_vga_loop:

    lodsb                                                       ;; load the pointed value in si to al

    cmp     al, 0x00                                            ;; compare al to the end of the string
    je      .print_string_vga_loop_end                          ;; jump to the end of the loop

    cmp     al, 0xA                                             ;; check if the caracter is a newline character
    jne     .print_string_vga_loop_step_two                     ;; if not, jump to the second step of the loop

    call    print_newline                                       ;; print the newline
    jmp     .print_string_vga_loop_call                         ;; jump directly to the loop call

.print_string_vga_loop_step_two:
    call    print_char_with_vga_memory_access                   ;; call the print char routine

.print_string_vga_loop_call:
    jmp     .print_string_vga_loop                              ;; make the loop

.print_string_vga_loop_end:

    ret                                                         ;; give back the control to the caller

;;;
;;; This code clears the screen and resets the printing pointer
;;;
clear_screen:
    pusha                                                       ;; push all the 16 bits registers to the stack
    pushad                                                      ;; push the 32 bits registers

    mov     eax, 0xB8000                                        ;; move to eax the vga memory pointer

.clear_screen_loop:

    cmp     eax, 0xB8FA0                                        ;; compare eax to the end of the vga memory
    je      .clear_screen_loop_end                              ;; jump to the end of the loop

    mov     byte[eax], 0x00                                     ;; reset the current pointed value
    inc     eax                                                 ;; increase the pointer

    jmp     .clear_screen_loop                                  ;; make the loop

.clear_screen_loop_end:

    popad                                                       ;; restore all the 32 bits registers
    popa                                                        ;; restore the 16 bits registers

    ret                                                         ;; give back the control to the caller

;;;
;;; Print the newline character (\n). This will basicly update the line pointer
;;;
print_newline:
    pusha                                                       ;; push all the 16 bits registers to the stack
    pushad                                                      ;; push the 32 bits registers

    mov     eax, line_pointer                                   ;; move to eax the line pointer
    mov     ebx, [eax]                                          ;; move the value of the pointer in ebx
    inc     ebx                                                 ;; increase ebx
    mov     dword[eax], ebx                                     ;; save the increased value in memory

    mov     eax, cursor_pointer                                 ;; move the cursor pointer in eax
    mov     dword[eax], 0x00                                    ;; reset the pointer and save it in memory

    popad                                                       ;; restore all the 32 bits registers
    popa                                                        ;; restore the 16 bits registers

    ret                                                         ;; give back the control to the caller


;;;                                                                                             ;;;
;;; DATA SECTION                                                                                ;;;
;;;                                                                                             ;;;

;;; The line pointer. A value between in 0 and 24
line_pointer:
    dd  0x00

;;; The cursor pointer. A value between 0 and 79
cursor_pointer:
    dd  0x00