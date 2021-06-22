.486
IDEAL
MODEL small
STACK 256
p386
DATASEG
    ;; Home 
    column dw ? ;; The column in which the "Start Game" button starts
    row dw ? ;; The row in which the "Start Game" button starts
    end_row dw ? ;; The row in which the "Start Game" button ends
    isOnHomePage db 1 ;; Value to check if the current page is the home page 1 = true 0 = false
    startGameMessage db "Start Game$" ;; The message for the "Start Game" button
    title db "Welcome To iMath$" ;; The welcome message that appears on the home page
    ;;
    ;; End Page
    isOnEndPage db 0 ;; Value to check if the current page is the end page 1 = true 0 = false
    hasPlayed db 0 ;; Value to check if TaDeum has already played 1 = true 0 = false
    winnerMessage db "You Have Done It!$" ;; Message for the winner
    exitButton db "Exit$" ;; Message for the exit button
    ;;
    PRN dw ? ;; pseudo random number
    basicRandomNumber1 db ? ;; the first number of the exercise
    basicRandomNumber2 db ? ;; the second number of the exercise
    result db ? ;; the correct answer
    userAnswer db 0 ;; the answer of the user
    randomNumber db ? ;; variable for holding a random number betwenn 0-9
    space db " $" ;; space character

    ;; Math Signs
    plusSign db " + $" 
    minusSign db " - $"
    mulSign db " * $"
    divSign db " / $"
    equalSign db "=$"
    ;;

    score db 0 ;; The user's score
    ;;
    
    ;; Exercise
    correctMsg db "              Very Good!$" ;; Message for a correct answer
    incorrectMsg db "              Next Time!$" ;; Message for an incorrect answer
    isCorrect db ? ;; Variable to hold the result of the proc CompareResultWithUserAnswer which checks if the typed a correct answer
    VALUE db 0 ;; current value of user's input
    ;;
    ;; Sounds
        inCorrectNote dw 5000h
        correctNote dw 700h
        sound dw ?
        fourthC dw 11DBh
        thirdG dw 17C7h
        fourthD dw 0FE8h
        fourthE dw 0E2Ah
        fourthF dw 0D5Ah
        fourthG dw 0BE3h
    ;;


CODESEG
    include "UtilLib.inc"
    include "GrLib.inc"


;; Choose Random Question
proc generateRandomNumberBetweenZeroAndThree
    push es
    mov ax, 40h
    mov es, ax
    mov ax, [es:6Ch]
    and al, 00000011b
    mov [randomNumber], al
    pop es
    ret
endp generateRandomNumberBetweenZeroAndThree

proc chooseRandomQuestion
    cmp [score], 10
    je EndPage
    push 1
    call sleep
    call DrawBlackScreen
    cmp [isOnEndPage], 1
    je END_CHOOSE_RANDOM_QUESTION
    call printScore
    call generateRandomNumberBetweenZeroAndThree
    cmp [randomNumber], 0
    je ADDITION_QUESTION
    cmp [randomNumber], 1
    je SUBTRACTION_QUESTION
    cmp [randomNumber], 2
    je MULTIPLICATION_QUESTION
    cmp [randomNumber], 3
    je DIVISION_QUESTION

    ADDITION_QUESTION:
    call BasicAdditionPage
    jmp END_CHOOSE_RANDOM_QUESTION
    SUBTRACTION_QUESTION:
    call BasicSubtractionPage
    jmp END_CHOOSE_RANDOM_QUESTION
    MULTIPLICATION_QUESTION:
    call BasicMultiplicationPage
    jmp END_CHOOSE_RANDOM_QUESTION
    DIVISION_QUESTION:
    call BasicDivisionPage
    jmp END_CHOOSE_RANDOM_QUESTION

    END_CHOOSE_RANDOM_QUESTION:
    ret
endp chooseRandomQuestion
;;

;; Score 
;; procedure to print the current score of the user 
proc printScore

    mov dl, 2    
    mov dh, 2 
    mov bh, 0  
    mov ah, 02h 
    int 10h
    mov dl, [score]
    add dl, '0'
    mov ah, 02h
    int 21h

    ret
endp printScore

;; 

;;; Spaces and Breaklines 
;; Prints 5 breaklines
proc AddBreakLines
    mov si, 0
    mov cx, 5
    BreakLineLoop:
        call printNewLine
        inc si
        loop BreakLineLoop
    ret
endp AddBreakLines
;; Prints 54 spaces
proc AddSpaces
    mov si, 0
    mov cx, 54
    mov dx, offset space
    SpaceLoop:
        call printStr
        inc si
        loop SpaceLoop
    ret
endp AddSpaces
;; Prints two spaces with an equal sign in the middle
proc AddEqualSign
    mov dl, [space]
    mov ah, 2h
    int 21h
    push 1
    call sleep
    mov dl, [equalSign]
    mov ah, 2h
    int 21h
    push 1
    call sleep
    mov dl, [space]
    mov ah, 2h
    int 21h
    ret
endp AddEqualSign

;; Compares the correct result to the user's answer and updates isCorrect accordingly
proc CompareResultWithUserAnswer
    mov al, [userAnswer]
    cmp al, [result]
    jne NOT_CORRECT
    mov [isCorrect], 1
    jmp END_COMPARE
    NOT_CORRECT:
    mov [isCorrect], 0
    END_COMPARE:
    ret
endp CompareResultWithUserAnswer

;; Lets the user type his answer until he presses "Enter"
proc getInput
    mov [userAnswer], 0
    READ:
    MOV AH, 1
    INT 21H
    
    CMP AL, 13
    JE ENDOFNUMBER
    
    MOV [VALUE], AL
    SUB [VALUE], 48
    
    MOV AL, [userAnswer]
    MOV BL, 10
    MUL BL
    
    ADD AL, [VALUE]
    
    MOV [userAnswer], AL
    
    JMP READ

    ENDOFNUMBER:   

    ret
endp getInput

;; Sounds - Sounds and Music
    proc soundInCorrect
        in al, 61h
        or al, 00000011b
        out 61h, al
        mov al, 0B6h
        out 43h, al
        mov ax, [inCorrectNote]
        out 42h, al
        mov al, ah
        out 42h, al
        push 1
        call sleep
        in al, 61h
        and al, 11111100b
        out 61h, al
        ret
    endp soundInCorrect

    proc soundCorrect
        in al, 61h
        or al, 00000011b
        out 61h, al
        mov al, 0B6h
        out 43h, al
        mov ax, [correctNote]
        out 42h, al
        mov al, ah
        out 42h, al
        push 1
        call sleep
        in al, 61h
        and al, 11111100b
        out 61h, al
        ret
    endp soundCorrect

    proc playSound
        in al, 61h
        or al, 00000011b
        out 61h, al
        mov al, 0B6h
        out 43h, al
        mov ax, [sound]
        out 42h, al
        mov al, ah
        out 42h, al
        push 1
        call sleep
        in al, 61h
        and al, 11111100b
        out 61h, al
        ret
        
    endp playSound

    proc playTaDeum
        cmp [hasPlayed], 1
        je END_PLAY_TA_DEUM
        mov cx, [thirdG]
        mov [sound], cx
        call playSound
        mov cx, [fourthC]
        mov [sound], cx
        call playSound
        call playSound
        mov cx, [fourthD]
        mov [sound], cx
        call playSound
        mov cx, [fourthE]
        mov [sound], cx
        call playSound
        mov cx, [fourthC]
        mov [sound], cx
        call playSound
        mov cx, [fourthG]
        mov [sound], cx
        call playSound
        mov cx, [fourthF]
        mov [sound], cx
        call playSound
        mov cx, [fourthE]
        mov [sound], cx
        call playSound
        mov cx, [fourthE]
        mov [sound], cx
        call playSound
        mov cx, [fourthF]
        mov [sound], cx
        call playSound
        mov cx, [fourthG]
        mov [sound], cx
        call playSound
        mov cx, [fourthE]
        mov [sound], cx
        call playSound
        mov cx, [fourthF]
        mov [sound], cx
        call playSound
        mov cx, [fourthD]
        mov [sound], cx
        call playSound
        mov cx, [fourthC]
        mov [sound], cx
        call playSound
        call playSound
        mov [hasPlayed], 1
        END_PLAY_TA_DEUM:
        ret
    endp playTaDeum
;;

;; Score
;; Increase the score by 1
proc IncreaseScore
    inc [score]
    ret
endp IncreaseScore
;; Decrease the score by 1 if it's not 0
proc DecreaseScore
    cmp [score], 0
    je DECREASE_END
    dec [score]
    call printScore
    DECREASE_END:
    ret

endp DecreaseScore


;;
;; Renders an addition exercise  
proc Addition
addition:
    call AddBreakLines
    call AddSpaces
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber1], dl  
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    mov dx, offset plusSign
    call printStr
    push 1
    call sleep
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber2], dl
    add  dl, '0'  
    mov ah, 2h  
    int 21h

  

    push 1
    call sleep
    ;
    call AddEqualSign
    ;
    call getInput
    mov al, [basicRandomNumber1]
    add al, [basicRandomNumber2]
    mov [result], al
    
    call CompareResultWithUserAnswer
    call printNewLine
    call printNewLine
    call printNewLine
    cmp [isCorrect], 0
    je INCORRECT_ADDITION
    CORRECT_ADDITION:
    call soundCorrect
    mov dx, offset correctMsg
    mov ah, 09h
    int 21h
    call IncreaseScore
    jmp END_ADDITION_FUNCTION
    
    INCORRECT_ADDITION:
    call soundInCorrect
    mov dx, offset incorrectMsg
    mov ah, 09h
    int 21h
    call DecreaseScore
    END_ADDITION_FUNCTION:
    jmp END_ADDITION
    ret
endp Addition

proc BasicAdditionPage
    call Addition
    END_ADDITION:
    call chooseRandomQuestion
    ret
endp BasicAdditionPage
;; Renders a subtraction exercise
proc Subtraction
    Subtraction:
 call AddBreakLines
    call AddSpaces
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber1], dl
    push 1
    call sleep
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber2], dl
    push 1
    call sleep
    cmp dl, [basicRandomNumber1]
    jbe CONTINUE_BASIC_SUBTRACTION
    xchg [basicRandomNumber1], dl
    mov [basicRandomNumber2], dl
    CONTINUE_BASIC_SUBTRACTION:
    mov dl, [basicRandomNumber1]
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    mov dx, offset minusSign
    call printStr
    push 1
    call sleep
    mov dl, [basicRandomNumber2]
    add  dl, '0'  
    mov ah, 2h 
    int 21h
    ;
    mov dl, [space]
    mov ah, 2h
    int 21h
    push 1
    call sleep
    mov dl, [equalSign]
    mov ah, 2h
    int 21h
    push 1
    call sleep
    mov dl, [space]
    mov ah, 2h
    int 21h
    ;
    call getInput
    mov al, [basicRandomNumber1]
    sub al, [basicRandomNumber2]
    mov [result], al
    call CompareResultWithUserAnswer
    call printNewLine
    call printNewLine
    call printNewLine
    cmp [isCorrect], 0
    je INCORRECT_SUBTRACTION
    CORRECT_SUBTRACTION:
    call soundCorrect
    mov dx, offset correctMsg
    mov ah, 09h
    int 21h
    call IncreaseScore
    jmp END_SUBTRACTION
    
    INCORRECT_SUBTRACTION:
    call soundInCorrect
    mov dx, offset incorrectMsg
    mov ah, 09h
    int 21h
    call DecreaseScore
    END_SUBTRACTION:
    jmp END_SUBTRACTION_FUNCTION
    ret
endp Subtraction

proc BasicSubtractionPage
    call Subtraction
    END_SUBTRACTION_FUNCTION:
    call chooseRandomQuestion
    ret
endp BasicSubtractionPage
;; Renders a multiplication exercise
proc Multiplication
    Multiplication:
    call AddBreakLines
    call AddSpaces
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber1], dl
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    mov dx, offset mulSign
    call printStr
    push 1
    call sleep
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber2], dl
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    call AddEqualSign
    call getInput
    mov si, 0
    mov al, [basicRandomNumber2]
    cbw
    mov cx, ax
    mov al, 0
    MULTIPLY:
    add al, [basicRandomNumber1]
    inc si
    loop MULTIPLY
    mov [result], al
    call CompareResultWithUserAnswer
    call printNewLine
    call printNewLine
    call printNewLine
    cmp [isCorrect], 0
    je INCORRECT_MULTIPLICATION
    CORRECT_MULTIPLICATION:
    call soundCorrect
    mov dx, offset correctMsg
    mov ah, 09h
    int 21h
    call IncreaseScore
    jmp END_MULTIPLICATION_FUNCTION
    
    INCORRECT_MULTIPLICATION:
    call soundInCorrect
    mov dx, offset incorrectMsg
    mov ah, 09h
    int 21h
    call DecreaseScore
    END_MULTIPLICATION_FUNCTION:
    jmp END_MULTIPLICATION
    ret
endp Multiplication


proc BasicMultiplicationPage
    call Multiplication
    END_MULTIPLICATION:
    call chooseRandomQuestion
    ret
endp BasicMultiplicationPage
;; Renders a division exercise
proc Division
    Division:
    call AddBreakLines
    call AddSpaces
    call generateBasicRandomNumber
    mov dl, [randomNumber]
    mov [basicRandomNumber1], dl
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    mov dx, offset divSign
    call printStr
    push 1
    call sleep
    call generateBasicRandomNumber
    mov al, 0
    cmp al, [randomNumber]
    jne CONTINUE_DIVISION
    mov [randomNumber], 1
    CONTINUE_DIVISION:
    mov dl, [randomNumber]
    mov [basicRandomNumber2], dl
    add  dl, '0'  
    mov ah, 2h  
    int 21h
    call AddEqualSign
    call getInput 
    mov al, [basicRandomNumber1]
    cbw
    mov bl, [basicRandomNumber2]
    div bl
    mov [result], al
    call CompareResultWithUserAnswer
    call printNewLine
    call printNewLine
    call printNewLine
    cmp [isCorrect], 0
    je INCORRECT_DIVISION
    CORRECT_DIVISION:
    call soundCorrect
    mov dx, offset correctMsg
    mov ah, 09h
    int 21h
    call IncreaseScore
    jmp END_DIVISION_FUNCTION
    
    INCORRECT_DIVISION:
    call soundInCorrect
    mov dx, offset incorrectMsg
    mov ah, 09h
    int 21h
    call DecreaseScore
    END_DIVISION_FUNCTION:
    jmp END_DIVISION
    ret
endp Division

proc BasicDivisionPage
    call Division
    END_DIVISION:
    call chooseRandomQuestion
    ret
endp BasicDivisionPage
;; Home Page
;; Draws the Start Game Button
proc DrawHomeButton
    mov ah, 0   ; set display mode function.
    mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
    int 10h     ; set it!
    mov al, 05h
    mov cx, [column]  ;col
    mov dx, [row]  ;row
    mov ah, 0ch ; put pixel
 
    homeButton:
    inc cx
    int 10h
    cmp cx, 240
    jne homeButton

    mov cx, [column]  ; reset to start of col
    inc dx      ;next row
    cmp dx, [end_row]
    jne homeButton
    ret
endp DrawHomeButton

proc DrawBlackScreen
    mov ah, 0   ; set display mode function.
    mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
    int 10h     ; set it!
    mov al, 00h
    mov cx, 0  ;col
    mov dx, 0  ;row
    mov ah, 0ch ; put pixel
 
    blackScreen:
    inc cx
    int 10h
    cmp cx, 320
    jne blackScreen

    mov cx, 0  ; reset to start of col
    inc dx      ;next row
    cmp dx, 200
    jne blackScreen
    ret
endp DrawBlackScreen
;; Renders the Home Page and checks if the Start Game has been pressed. If it has, the procedure calls chooseRandomQuestion
proc HomePage

    mov ah, 09h
    int 21h
    mov [column], 80
    mov [end_row], 110
    mov [row], 70
    call DrawHomeButton


    mov dl, 15    
    mov dh, 11    
    mov bh, 0     
    mov ah, 02h   
    int 10h
    mov dx, offset startGameMessage
    mov ah, 09h   ;DisplayString
    int 21h 

    mov dl, 12    ;Center column
    mov dh, 2    ;in top rows
    mov bh, 0     ;Display page 0
    mov ah, 02h   ;SetCursor
    int 10h
    mov dx, offset title
    mov ah, 09h   ;DispayString
    int 21h 

    mov ax, 0h
    int 33h
    mov ax, 1h
    int 33h
    pressStart:
    mov ax, 3h
    int 33h
    cmp bx, 01h
    jne pressStart
    shr cx, 1
    sub dx, 2
    cmp cx, 240
    ja pressStart
    cmp cx, 80
    jb pressStart
    cmp dx, 70
    jb pressStart
    cmp dx, 110 
    ja pressStart
    cmp [isOnHomePage], 1
    jne pressStart
    mov [isOnHomePage], 0
    call DrawBlackScreen
    mov dl, 15    
    mov dh, 11    
    mov bh, 0     
    mov ah, 02h  
    int 10h
    mov ax, 0h
    int 33h
    mov ax, 1h
    int 33h

    call chooseRandomQuestion
    
    ret
endp HomePage
;; 

;; End Page
;; Renders the end page
proc EndPage
    END_PAGE:
    mov [isOnEndPage], 1
    call DrawBlackScreen
    mov dl, 12    
    mov dh, 11    
    mov bh, 0     
    mov ah, 02h   
    int 10h
    mov dx, offset winnerMessage
    mov ah, 09h   ;DisplayString
    int 21h 
    call playTaDeum
    ret
endp EndPage
;;
proc CalcNew
CalcNew:
    mov     ax, 25173          ; LCG Multiplier
    mul     [word ptr PRN]     ; DX:AX = LCG multiplier * seed
    add     ax, 13849          ; Add LCG increment value
     ;Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov     [PRN], ax          ; Update seed = return value
    ret

endp CalcNew

;; Generates a random number between 0-9
proc generateBasicRandomNumber
    mov     AH, 00h   ; interrupt to get system timer in CX:DX 
    int     1AH
    mov     [PRN], dx
    call    CalcNew   ; -> AX is a random number
    xor     dx, dx
    mov     cx, 10    
    div     cx        ; here dx contains the remainder - from 0 to 9
    ;add     dl, '0'   ; to ascii from '0' to '9'
    mov [randomNumber], dl
     call    CalcNew   ; -> AX is another random number
    ret
endp generateBasicRandomNumber
start:
    mov ax, @data
    mov ds,ax
    mov ax, TRUE
    ut_init_lib ax
    call AllocateDblBuffer
   
    gr_set_video_mode_vga
    call HomePage
exit:
    COMPLETE_EXIT:
    call ReleaseDblBuffer
    gr_set_video_mode_txt
    
    return 0
END start
