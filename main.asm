; filepath: c:\Users\samii\Desktop\temp\temp.asm
TITLE Tactical Encryption Unit      (TacticalEncryption.asm)

; Add processor architecture and memory model
.386
.model flat, stdcall
.stack 4096

; Fix the includes - can't INCLUDE a .lib file
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

ExitProcess PROTO, dwExitCode:DWORD

.data
; ASCII art banner
bannerLine1    BYTE "  _______         _   _           _   ", 0
bannerLine2    BYTE " |__   __|       | | (_)         | |  ", 0
bannerLine3    BYTE "    | | __ _  ___| |_ _  ___ __ _| |  ", 0
bannerLine4    BYTE "    | |/ _` |/ __| __| |/ __/ _` | |  ", 0
bannerLine5    BYTE "    | | (_| | (__| |_| | (_| (_| | |  ", 0
bannerLine6    BYTE "    |_|\__,_|\___|\__|_|\___\__,_|_|  ", 0
bannerLine7    BYTE "                                      ", 0
bannerLine8    BYTE "    Encryption Unit | Secure Comms    ", 0

; Menu and prompt strings
welcomeMsg      BYTE "=== Welcome to Tactical Encryption Unit ===", 0
menuPrompt      BYTE "1. Encrypt a message", 0dh, 0ah
                BYTE "2. Decrypt a message", 0dh, 0ah
                BYTE "3. Exit", 0dh, 0ah
                BYTE "Enter your choice (1-3): ", 0
encryptModeMsg  BYTE "=== ENCRYPTION MODE ===", 0
decryptModeMsg  BYTE "=== DECRYPTION MODE ===", 0
cipherBoxTop    BYTE "+-------------------------------------+", 0
cipherBoxMid    BYTE "|                                     |", 0
cipherBoxBot    BYTE "+-------------------------------------+", 0
cipherTitle     BYTE "      AVAILABLE CIPHER METHODS        ", 0
cipherOption1   BYTE "  [1]  Caesar Cipher                  ", 0
cipherOption2   BYTE "  [2]  ROT13                          ", 0
cipherOption3   BYTE "  [3]  Vigenere Cipher                ", 0
cipherOption4   BYTE "  [4]  Custom Substitution            ", 0
cipherOption5   BYTE "  [5]  Playfair Cipher                ", 0
cipherOption6   BYTE "  [6]  Monoalphabetic Cipher          ", 0
cipherPrompt    BYTE "  Select cipher (1-6): ", 0
invalidChoice   BYTE "Invalid choice. Please try again.", 0
enterText       BYTE "Enter the text (max 100 chars): ", 0
enterShift      BYTE "Enter the shift value (1-25): ", 0
enterKey        BYTE "Enter 26-letter substitution key (A-Z): ", 0
enterVigKey     BYTE "Enter the Vigenere keyword: ", 0
enterPlayfairKey BYTE "Enter the Playfair keyword: ", 0
enterMonoKey    BYTE "Enter the Monoalphabetic key (single letter A-Z): ", 0
resultMsg       BYTE "Result: ", 0
pressKey        BYTE "Press any key to continue...", 0
goodbyeMsg      BYTE "Thank you for using Tactical Encryption Unit. Goodbye!", 0
invalidShift    BYTE "Invalid shift. Please enter a number between 1 and 25.", 0
invalidKey      BYTE "Invalid key. Must be 26 unique letters.", 0
invalidRails    BYTE "Invalid rail count. Please enter a number between 2 and 10.", 0
invalidMonoKey  BYTE "Invalid key. Please enter a letter A-Z.", 0

; Data storage
userChoice      DWORD ?
cipherChoice    DWORD ?
inputBuffer     BYTE 101 DUP(0)  ; 100 chars + null terminator
outputBuffer    BYTE 101 DUP(0)
shiftValue      DWORD ?
bufferSize      DWORD 100
keyBuffer       BYTE 27 DUP(0)   ; 26 letters + null terminator
vigKeyBuffer    BYTE 51 DUP(0)   ; 50 chars + null terminator
vigKeyLen       DWORD 0
playfairKey     BYTE 26 DUP(0)   ; Playfair key
playfairMatrix  BYTE 25 DUP(0)   ; 5x5 Playfair matrix
monoKey         BYTE 0           ; Monoalphabetic key
tempBuffer      BYTE 101 DUP(0)  ; Temporary buffer for complex operations

; Rail fence storage for tracking positions - repurposed for monoalphabetic
monoTable       BYTE 26 DUP(0)   ; Monoalphabetic substitution table

.code
main PROC
    call Clrscr

MainMenu:
    ; Set color for banner (bright cyan on black)
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    ; Display ASCII art banner
    mov edx, OFFSET bannerLine1
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine2
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine3
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine4
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine5
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine6
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine7
    call WriteString
    call Crlf
    mov edx, OFFSET bannerLine8
    call WriteString
    call Crlf
    call Crlf
    
    ; Set color for welcome text (bright white on black)
    mov eax, white + (black * 16)
    call SetTextColor

    ; Display welcome message
    mov edx, OFFSET welcomeMsg
    call WriteString
    call Crlf
    call Crlf
    
    ; Set color for menu options (light green on black)
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    
    ; Display menu
    mov edx, OFFSET menuPrompt
    call WriteString
    
    ; Set color for user input (yellow on black)
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    ; Read user choice
    call ReadInt
    ; Store the value directly in a register for comparison
    mov ebx, eax 
    mov userChoice, ebx
    
    ; Reset color to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Process menu choice using the value in ebx register
    cmp ebx, 1
    je EncryptOption
    cmp ebx, 2
    je DecryptOption
    cmp ebx, 3
    je ExitProgram
    
    ; Invalid choice - red text
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET invalidChoice
    call WriteString
    call Crlf
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Short delay before showing menu again
    mov eax, 1000
    call Delay
    jmp MainMenu
    
EncryptOption:
    ; Set cyan for encrypt mode
    mov eax, cyan + (black * 16)
    call SetTextColor
    call Crlf
    mov edx, OFFSET encryptModeMsg
    call WriteString
    call Crlf
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Set encryption mode in userChoice (will be needed for some cipher implementations)
    mov userChoice, 1
    
    call SelectCipher
    call GetUserInput
    mov ebx, 1                  ; Set mode to encrypt (1)
    call ProcessCipher
    call DisplayResult
    jmp ContinuePrompt
    
DecryptOption:
    ; Set green for decrypt mode
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    call Crlf
    mov edx, OFFSET decryptModeMsg
    call WriteString
    call Crlf
    call Crlf
    
    ; Reset to white
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Set decryption mode in userChoice (will be needed for some cipher implementations)
    mov userChoice, 0
    
    call SelectCipher
    call GetUserInput
    mov ebx, 0                  ; Set mode to decrypt (0)
    call ProcessCipher
    call DisplayResult
    
ContinuePrompt:
    call Crlf
    
    ; Light blue for continue prompt
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    
    mov edx, OFFSET pressKey
    call WriteString
    call ReadChar
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    call Clrscr
    jmp MainMenu
    
ExitProgram:
    call Clrscr
    
    ; Magenta for goodbye message
    mov eax, magenta + (black * 16)
    call SetTextColor
    
    mov edx, OFFSET goodbyeMsg
    call WriteString
    call Crlf
    
    ; Reset color to default (light gray on black)
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Short delay before exit
    mov eax, 1500
    call Delay
    exit

main ENDP

; Lets user select which cipher to use
SelectCipher PROC
    call Crlf
    
    ; Set border color (light gray)
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Display top border
    mov edx, OFFSET cipherBoxTop
    call WriteString
    call Crlf
    
    ; Display middle part
    mov edx, OFFSET cipherBoxMid
    call WriteString
    call Crlf
    
    ; Display title with a different color (bright white)
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherTitle
    call WriteString
    call Crlf
    
    ; Reset to border color
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherBoxMid
    call WriteString
    call Crlf
    
    ; Display cipher options with different colors for each option
    
    ; Option 1 - light red
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption1
    call WriteString
    call Crlf
    
    ; Option 2 - light blue
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption2
    call WriteString
    call Crlf
    
    ; Option 3 - light green
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption3
    call WriteString
    call Crlf
    
    ; Option 4 - yellow
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption4
    call WriteString
    call Crlf
    
    ; Option 5 - magenta
    mov eax, magenta + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption5
    call WriteString
    call Crlf
    
    ; Option 6 - cyan
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherOption6
    call WriteString
    call Crlf
    
    ; Bottom border - light gray
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherBoxBot
    call WriteString
    call Crlf
    
    ; Prompt for selection - white
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET cipherPrompt
    call WriteString
    
    ; User input - yellow
    mov eax, yellow + (black * 16)
    call SetTextColor
    call ReadInt
    
    ; Store user's choice in temporary register for validation
    mov ebx, eax
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Validate choice (1-6) using ebx for comparison
    cmp ebx, 1
    jl InvalidCipherChoice
    cmp ebx, 6
    jg InvalidCipherChoice
    
    ; Store the valid choice in cipherChoice
    mov cipherChoice, ebx
    ret
    
InvalidCipherChoice:
    mov eax, lightRed + (black * 16)  ; Red for error
    call SetTextColor
    mov edx, OFFSET invalidChoice
    call WriteString
    call Crlf
    
    ; Reset color
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Short pause before retrying
    mov eax, 800
    call Delay
    jmp SelectCipher
    
SelectCipher ENDP

; Gets text input and any needed parameters for selected cipher
GetUserInput PROC
    ; Get message
    call Crlf
    mov edx, OFFSET enterText
    call WriteString
    
    mov edx, OFFSET inputBuffer
    mov ecx, bufferSize
    call ReadString
    
    ; Check which cipher was selected to get appropriate parameters
    cmp cipherChoice, 1
    je GetCaesarParams
    cmp cipherChoice, 2
    je ROT13NoParams       ; ROT13 doesn't need parameters
    cmp cipherChoice, 3
    je GetVigenereParams   ; Vigenere needs a keyword
    cmp cipherChoice, 4
    je GetSubstitutionParams
    cmp cipherChoice, 5
    je GetPlayfairParams   ; Playfair needs a keyword
    cmp cipherChoice, 6
    je GetMonoalphabeticParams  ; Monoalphabetic needs a key character
    
GetCaesarParams:
    ; Get shift value for Caesar cipher
    mov edx, OFFSET enterShift
    call WriteString
    call ReadInt
    
    ; Validate shift (1-25)
    cmp eax, 1
    jl InvalidShiftValue
    cmp eax, 25
    jg InvalidShiftValue
    
    mov shiftValue, eax
    ret
    
InvalidShiftValue:
    mov edx, OFFSET invalidShift
    call WriteString
    call Crlf
    jmp GetCaesarParams
    
ROT13NoParams:
    ; ROT13 always uses shift of 13
    mov shiftValue, 13
    ret
    
GetVigenereParams:
    ; Get Vigenere keyword
    mov edx, OFFSET enterVigKey
    call WriteString
    
    mov edx, OFFSET vigKeyBuffer
    mov ecx, 50  ; Max keyword size
    call ReadString
    
    ; Store keyword length
    mov vigKeyLen, eax
    ret
    
GetSubstitutionParams:
    ; Get substitution alphabet
    mov edx, OFFSET enterKey
    call WriteString
    
    mov edx, OFFSET keyBuffer
    mov ecx, 27  ; 26 letters + null terminator
    call ReadString
    
    ; Validate key length (should be exactly 26)
    cmp eax, 26
    jne InvalidKeyValue
    
    ; Could add more validation for unique letters here if needed
    ret
    
InvalidKeyValue:
    mov edx, OFFSET invalidKey
    call WriteString
    call Crlf
    jmp GetSubstitutionParams

GetPlayfairParams:
    ; Get Playfair keyword
    mov edx, OFFSET enterPlayfairKey
    call WriteString
    
    mov edx, OFFSET playfairKey
    mov ecx, 25  ; Max keyword size
    call ReadString
    
    ; Generate the Playfair matrix from the keyword
    call GeneratePlayfairMatrix
    ret
    
GetMonoalphabeticParams:
    ; Get Monoalphabetic key character
    mov edx, OFFSET enterMonoKey
    call WriteString
    call ReadChar
    call WriteChar        ; Echo the character
    call Crlf
    
    ; Validate key (must be A-Z or a-z)
    cmp al, 'A'
    jl InvalidMonoKeyValue
    cmp al, 'z'
    jg InvalidMonoKeyValue
    cmp al, 'Z'
    jle StoreMonoKey
    cmp al, 'a'
    jl InvalidMonoKeyValue
    
    ; Convert lowercase to uppercase
    sub al, 32
    
StoreMonoKey:
    mov monoKey, al
    
    ; Generate the monoalphabetic substitution table
    call GenerateMonoalphabeticTable
    ret
    
InvalidMonoKeyValue:
    mov edx, OFFSET invalidMonoKey
    call WriteString
    call Crlf
    jmp GetMonoalphabeticParams
    
GetUserInput ENDP

; Generate monoalphabetic substitution table based on key
GenerateMonoalphabeticTable PROC
    ; The table will be a simple shift of the alphabet based on the key character
    ; A becomes key, B becomes key+1, etc.
    
    mov al, monoKey
    sub al, 'A'       ; Convert to 0-25 range
    mov cl, al        ; Save shift value
    
    mov esi, OFFSET monoTable
    mov al, 0         ; Start with 'A' (0 in 0-25 range)
    
FillTableLoop:
    cmp al, 26
    jge DoneTable
    
    ; Calculate shifted value
    mov bl, al
    add bl, cl        ; Add shift value
    cmp bl, 26
    jl NoWrapAround
    sub bl, 26        ; Wrap around if needed
    
NoWrapAround:
    mov [esi], bl     ; Store shifted value in table
    inc al
    inc esi
    jmp FillTableLoop
    
DoneTable:
    ret
GenerateMonoalphabeticTable ENDP

; Process the selected cipher
; ebx = 1 for encrypt, 0 for decrypt
ProcessCipher PROC
    ; Dispatch to appropriate cipher based on choice
    cmp cipherChoice, 1
    je ProcessCaesar
    cmp cipherChoice, 2
    je ProcessROT13
    cmp cipherChoice, 3
    je ProcessVigenere
    cmp cipherChoice, 4
    je ProcessSubstitution
    cmp cipherChoice, 5
    je ProcessPlayfair
    cmp cipherChoice, 6
    je ProcessMonoalphabetic
    ret
    
ProcessCipher ENDP

; Process Caesar cipher
ProcessCaesar PROC
    mov esi, OFFSET inputBuffer  ; Source pointer
    mov edi, OFFSET outputBuffer ; Destination pointer
    
CaesarLoop:
    mov al, [esi]              ; Get current character
    cmp al, 0                  ; Check for null terminator
    je DoneCaesar
    
    ; Check if character is a letter
    cmp al, 'A'
    jl NotALetterCaesar
    cmp al, 'z'
    jg NotALetterCaesar
    cmp al, 'Z'
    jle UpperCaseLetterCaesar
    cmp al, 'a'
    jl NotALetterCaesar
    
    ; Process lowercase letter
    cmp ebx, 1
    je EncryptLowerCaesar
    jmp DecryptLowerCaesar
    
EncryptLowerCaesar:
    mov cl, al
    sub cl, 'a'                ; Convert to 0-25
    add cl, BYTE PTR shiftValue ; Apply shift
    mov ah, 0
    mov al, cl
    mov cl, 26
    div cl                     ; eax / 26, remainder in ah
    add ah, 'a'                ; Convert back to ASCII
    mov al, ah
    jmp SaveCharCaesar
    
DecryptLowerCaesar:
    mov cl, al
    sub cl, 'a'                ; Convert to 0-25
    add cl, 26                 ; Ensure positive after subtraction
    sub cl, BYTE PTR shiftValue ; Apply reverse shift
    mov ah, 0
    mov al, cl
    mov cl, 26
    div cl                     ; eax / 26, remainder in ah
    add ah, 'a'                ; Convert back to ASCII
    mov al, ah
    jmp SaveCharCaesar
    
UpperCaseLetterCaesar:
    cmp ebx, 1
    je EncryptUpperCaesar
    jmp DecryptUpperCaesar
    
EncryptUpperCaesar:
    mov cl, al
    sub cl, 'A'                ; Convert to 0-25
    add cl, BYTE PTR shiftValue ; Apply shift
    mov ah, 0
    mov al, cl
    mov cl, 26
    div cl                     ; eax / 26, remainder in ah
    add ah, 'A'                ; Convert back to ASCII
    mov al, ah
    jmp SaveCharCaesar
    
DecryptUpperCaesar:
    mov cl, al
    sub cl, 'A'                ; Convert to 0-25
    add cl, 26                 ; Ensure positive after subtraction
    sub cl, BYTE PTR shiftValue ; Apply reverse shift
    mov ah, 0
    mov al, cl
    mov cl, 26
    div cl                     ; eax / 26, remainder in ah
    add ah, 'A'                ; Convert back to ASCII
    mov al, ah
    jmp SaveCharCaesar
    
NotALetterCaesar:
    ; Keep non-alphabetic characters as they are
    mov [edi], al
    inc esi
    inc edi
    jmp CaesarLoop
    
SaveCharCaesar:
    mov [edi], al
    inc esi
    inc edi
    jmp CaesarLoop
    
DoneCaesar:
    mov BYTE PTR [edi], 0      ; Add null terminator
    ret
    
ProcessCaesar ENDP

; Process ROT13 cipher (same as Caesar with fixed shift of 13)
ProcessROT13 PROC
    ; ROT13 is just Caesar with shift=13, and encrypt=decrypt
    ; We already set shiftValue to 13 earlier
    call ProcessCaesar
    ret
ProcessROT13 ENDP

; Process Vigenere cipher
ProcessVigenere PROC
    mov esi, OFFSET inputBuffer  ; Source pointer
    mov edi, OFFSET outputBuffer ; Destination pointer
    mov edx, 0                   ; Key position counter
    
VigenereLoop:
    mov al, [esi]              ; Get current character
    cmp al, 0                  ; Check for null terminator
    je DoneVigenere
    
    ; Check if character is a letter
    cmp al, 'A'
    jl NotALetterVigenere
    cmp al, 'z'
    jg NotALetterVigenere
    cmp al, 'Z'
    jle UpperCaseLetterVigenere
    cmp al, 'a'
    jl NotALetterVigenere
    
    ; Process lowercase letter
    movzx ecx, al              ; Save original character
    
    ; Get current key character
    mov eax, edx
    xor edx, edx               ; Clear high bits of edx
    div vigKeyLen              ; eax = edx:eax / vigKeyLen, edx = remainder
    mov eax, edx               ; Move remainder to eax
    
    mov al, BYTE PTR [vigKeyBuffer + eax]  ; Get key char
    
    ; Convert key char to uppercase if it's lowercase
    cmp al, 'a'
    jl SkipToUpperVig
    cmp al, 'z'
    jg SkipToUpperVig
    sub al, 32                 ; Convert to uppercase
    
SkipToUpperVig:
    sub al, 'A'                ; Convert key to 0-25
    mov ah, al                 ; Store key value in ah
    
    ; Now process based on encrypt/decrypt mode
    mov al, cl                 ; Restore original character
    sub al, 'a'                ; Convert to 0-25
    
    ; Fix: Compare ebx (mode parameter) with 1 instead of cl with 1
    cmp ebx, 1                  ; Compare using correct register
    jne DecryptLowerVigenere
    
    ; Encrypt: (char + key) mod 26
    add al, ah                 ; Add key value
    mov cl, 26
    div cl                     ; al / 26, remainder in ah
    mov al, ah                 ; Get remainder
    add al, 'a'                ; Convert back to ASCII
    jmp SaveCharVigenere
    
DecryptLowerVigenere:
    ; Decrypt: (char - key + 26) mod 26
    add al, 26                 ; Ensure positive result
    sub al, ah                 ; Subtract key value
    mov cl, 26
    div cl                     ; al / 26, remainder in ah
    mov al, ah                 ; Get remainder
    add al, 'a'                ; Convert back to ASCII
    jmp SaveCharVigenere
    
UpperCaseLetterVigenere:
    movzx ecx, al              ; Save original character
    
    ; Get current key character
    mov eax, edx
    xor edx, edx               ; Clear high bits of edx
    div vigKeyLen              ; eax = edx:eax / vigKeyLen, edx = remainder
    mov eax, edx               ; Move remainder to eax
    
    mov al, BYTE PTR [vigKeyBuffer + eax]  ; Get key char
    
    ; Convert key char to uppercase if it's lowercase
    cmp al, 'a'
    jl SkipToUpperVig2
    cmp al, 'z'
    jg SkipToUpperVig2
    sub al, 32                 ; Convert to uppercase
    
SkipToUpperVig2:
    sub al, 'A'                ; Convert key to 0-25
    mov ah, al                 ; Store key value in ah
    
    ; Now process based on encrypt/decrypt mode
    mov al, cl                 ; Restore original character
    sub al, 'A'                ; Convert to 0-25
    
    ; Fix: Compare ebx (mode parameter) with 1 instead of cl with 1
    cmp ebx, 1                  ; Compare using correct register
    jne DecryptUpperVigenere
    
    ; Encrypt: (char + key) mod 26
    add al, ah                 ; Add key value
    mov cl, 26
    div cl                     ; al / 26, remainder in ah
    mov al, ah                 ; Get remainder
    add al, 'A'                ; Convert back to ASCII
    jmp SaveCharVigenere
    
DecryptUpperVigenere:
    ; Decrypt: (char - key + 26) mod 26
    add al, 26                 ; Ensure positive result
    sub al, ah                 ; Subtract key value
    mov cl, 26
    div cl                     ; al / 26, remainder in ah
    mov al, ah                 ; Get remainder
    add al, 'A'                ; Convert back to ASCII
    jmp SaveCharVigenere
    
NotALetterVigenere:
    ; Keep non-alphabetic characters as they are
    mov [edi], al
    inc esi
    inc edi
    jmp VigenereLoop
    
SaveCharVigenere:
    mov [edi], al
    inc esi
    inc edi
    inc edx                    ; Increment key position
    jmp VigenereLoop
    
DoneVigenere:
    mov BYTE PTR [edi], 0      ; Add null terminator
    ret
ProcessVigenere ENDP

; Process custom substitution cipher
ProcessSubstitution PROC
    mov esi, OFFSET inputBuffer  ; Source pointer
    mov edi, OFFSET outputBuffer ; Destination pointer
    
SubstitutionLoop:
    mov al, [esi]              ; Get current character
    cmp al, 0                  ; Check for null terminator
    je DoneSubstitution
    
    ; Check if character is a letter
    cmp al, 'A'
    jl NotALetterSubstitution
    cmp al, 'z'
    jg NotALetterSubstitution
    cmp al, 'Z'
    jle UpperCaseLetterSubstitution
    cmp al, 'a'
    jl NotALetterSubstitution
    
    ; Process lowercase letter
    push eax                   ; Save original character
    sub al, 'a'                ; Convert to 0-25 index
    movzx eax, al              ; Zero-extend to use as index
    
    ; Check if encrypting (uses ebx as mode parameter: 1=encrypt, 0=decrypt)
    cmp ebx, 1
    jne DecryptLowerSubstitution
    
    ; Encrypt - direct mapping
    mov cl, [keyBuffer + eax]
    ; Convert to lowercase if it's uppercase
    cmp cl, 'A'
    jl SkipLowerCase1
    cmp cl, 'Z'
    jg SkipLowerCase1
    add cl, 32                 ; Convert to lowercase
SkipLowerCase1:
    mov al, cl
    jmp SaveCharSubstitutionLower
    
DecryptLowerSubstitution:
    ; Decrypt - have to find index in key that matches our letter
    movzx ebx, al             ; Save the character index in ebx
    mov ecx, 0                ; Start with index 0
    
DecryptLowerLoop:
    cmp ecx, 26
    jge NotFoundLowerSub      ; Should not happen with valid key
    
    ; Get key character and normalize to lowercase for comparison
    mov dl, [keyBuffer + ecx]
    cmp dl, 'A'
    jl SkipToLower
    cmp dl, 'Z'
    jg SkipToLower
    add dl, 32                ; Convert to lowercase
    
SkipToLower:
    cmp dl, bl                ; Does key char match our index?
    je FoundLowerSub
    inc ecx
    jmp DecryptLowerLoop
    
FoundLowerSub:
    mov al, cl
    add al, 'a'               ; Convert index back to letter
    jmp SaveCharSubstitutionLower
    
NotFoundLowerSub:
    ; If not found (shouldn't happen with valid key), keep original
    pop eax                   ; Restore original and keep it
    jmp NotALetterSubstitution
    
SaveCharSubstitutionLower:
    pop edx                   ; Remove original char from stack
    mov [edi], al
    inc esi
    inc edi
    jmp SubstitutionLoop
    
UpperCaseLetterSubstitution:
    push eax                  ; Save original character
    sub al, 'A'               ; Convert to 0-25 index
    movzx eax, al             ; Zero-extend to use as index
    
    ; Check if encrypting (uses ebx as mode parameter: 1=encrypt, 0=decrypt)
    cmp ebx, 1
    jne DecryptUpperSubstitution
    
    ; Encrypt - direct mapping
    mov cl, [keyBuffer + eax]
    ; Convert to uppercase if it's lowercase
    cmp cl, 'a'
    jl SkipUpperCase1
    cmp cl, 'z'
    jg SkipUpperCase1
    sub cl, 32                ; Convert to uppercase
SkipUpperCase1:
    mov al, cl
    jmp SaveCharSubstitutionUpper
    
DecryptUpperSubstitution:
    ; Decrypt - have to find index in key that matches our letter
    movzx ebx, al             ; Save the character index in ebx
    mov ecx, 0                ; Start with index 0
    
DecryptUpperLoop:
    cmp ecx, 26
    jge NotFoundUpperSub      ; Should not happen with valid key
    
    ; Get key character and normalize to uppercase for comparison
    mov dl, [keyBuffer + ecx]
    cmp dl, 'a'
    jl SkipToUpper
    cmp dl, 'z'
    jg SkipToUpper
    sub dl, 32                ; Convert to uppercase
    
SkipToUpper:
    cmp dl, bl                ; Does key char match our index?
    je FoundUpperSub
    inc ecx
    jmp DecryptUpperLoop
    
FoundUpperSub:
    mov al, cl
    add al, 'A'               ; Convert index back to letter
    jmp SaveCharSubstitutionUpper
    
NotFoundUpperSub:
    ; If not found (shouldn't happen with valid key), keep original
    pop eax                   ; Restore original and keep it
    jmp NotALetterSubstitution
    
SaveCharSubstitutionUpper:
    pop edx                   ; Remove original char from stack
    mov [edi], al
    inc esi
    inc edi
    jmp SubstitutionLoop
    
NotALetterSubstitution:
    ; Keep non-alphabetic characters as they are
    mov [edi], al
    inc esi
    inc edi
    jmp SubstitutionLoop
    
DoneSubstitution:
    mov BYTE PTR [edi], 0      ; Add null terminator
    ret
ProcessSubstitution ENDP

; Generate Playfair matrix from the keyword
GeneratePlayfairMatrix PROC
    ; Initialize matrix with zeros
    mov esi, OFFSET playfairMatrix
    mov ecx, 25                ; 5x5 matrix
    mov al, 0
    
ClearMatrix:
    mov [esi], al
    inc esi
    loop ClearMatrix
    
    ; Process the keyword first
    mov esi, OFFSET playfairKey
    mov edi, OFFSET playfairMatrix
    mov ebx, 0                 ; Current position in matrix
    
KeywordLoop:
    mov al, [esi]
    cmp al, 0
    je FillRemaining
    
    ; Convert to uppercase if lowercase
    cmp al, 'a'
    jl NotLowerKey
    cmp al, 'z'
    jg NotLowerKey
    sub al, 32                 ; Convert to uppercase
    
NotLowerKey:
    ; Skip if not a letter
    cmp al, 'A'
    jl SkipCharKey
    cmp al, 'Z'
    jg SkipCharKey
    
    ; Convert I/J to I (standard in Playfair)
    cmp al, 'J'
    jne NotJ
    mov al, 'I'
    
NotJ:
    ; Check if this letter is already in matrix
    push esi                   ; Save keyword position
    push ebx                   ; Save matrix position
    
    mov esi, OFFSET playfairMatrix
    mov ecx, 25                ; Check all cells
    
CheckDuplicate:
    cmp [esi], al
    je FoundDuplicate
    inc esi
    loop CheckDuplicate
    
    ; Not found, add to matrix
    pop ebx                    ; Restore matrix position
    mov esi, OFFSET playfairMatrix
    add esi, ebx
    mov [esi], al
    inc ebx
    jmp DoneDuplicateCheck
    
FoundDuplicate:
    ; Already exists, skip
    pop ebx
    
DoneDuplicateCheck:
    pop esi                    ; Restore keyword position
    
SkipCharKey:
    inc esi
    jmp KeywordLoop
    
    ; Fill remaining positions with unused letters
FillRemaining:
    mov al, 'A'
    
FillLoop:
    cmp al, 'Z'
    jg DoneMatrix              ; We've tried all letters
    
    ; Skip J in Playfair (commonly I=J)
    cmp al, 'J'
    je NextLetter
    
    ; Check if this letter is already in matrix
    push esi                   ; Save current position
    push ebx
    
    mov esi, OFFSET playfairMatrix
    mov ecx, 25                ; Check all cells
    
CheckFill:
    cmp [esi], al
    je FoundFill
    inc esi
    loop CheckFill
    
    ; Not found, add to matrix
    pop ebx                    ; Restore matrix position
    cmp ebx, 25                ; Check if matrix is full
    jge DoneMatrix
    
    mov esi, OFFSET playfairMatrix
    add esi, ebx
    mov [esi], al
    inc ebx
    jmp DoneFillCheck
    
FoundFill:
    ; Already exists, skip
    pop ebx
    
DoneFillCheck:
    pop esi                    ; Restore position
    
NextLetter:
    inc al
    jmp FillLoop
    
DoneMatrix:
    ret
GeneratePlayfairMatrix ENDP

; Find position of a character in the Playfair matrix
; Input: AL = character to find, Output: AH = row (0-4), AL = col (0-4)
FindPlayfairPos PROC
    ; Convert to uppercase if lowercase
    cmp al, 'a'
    jl NotLowerFind
    cmp al, 'z'
    jg NotLowerFind
    sub al, 32                 ; Convert to uppercase
    
NotLowerFind:
    ; Handle I/J substitution
    cmp al, 'J'
    jne NotJFind
    mov al, 'I'
    
NotJFind:
    push ebx
    push esi
    
    mov ebx, 0                 ; Counter
    mov esi, OFFSET playfairMatrix
    
FindLoop:
    cmp ebx, 25
    jge NotFound
    
    cmp [esi], al
    je Found
    inc ebx
    inc esi
    jmp FindLoop
    
Found:
    ; Convert linear position to row/col
    mov eax, ebx
    mov bl, 5
    div bl                     ; AL = quotient (row), AH = remainder (col)
    pop esi
    pop ebx
    ret
    
NotFound:
    ; Not found - shouldn't happen with valid input
    mov ah, 0
    mov al, 0
    pop esi
    pop ebx
    ret
FindPlayfairPos ENDP

; Process Playfair cipher
ProcessPlayfair PROC
    ; We'll use a two-pass approach:
    ; 1. Preprocess the text (duplicate letter handling, make pairs)
    ; 2. Encrypt/decrypt the pairs using Playfair rules
    
    ; First pass: preprocess text to handle Playfair rules
    call PreprocessPlayfair
    
    ; Second pass: encrypt/decrypt pairs
    mov esi, OFFSET tempBuffer ; Source is the preprocessed text
    mov edi, OFFSET outputBuffer
    
PlayfairMainLoop:
    mov al, [esi]
    cmp al, 0                  ; Check for end of buffer
    je DonePlayfair
    
    ; Get the current digraph (pair of letters)
    mov ah, [esi+1]
    cmp ah, 0                  ; Check if we reached end with odd letter
    je ProcessSingleLetter
    
    ; Find positions of both letters in matrix
    push eax                   ; Save digraph
    call FindPlayfairPos       ; Find first letter, result in AH=row, AL=col
    mov bl, ah                 ; BL = row of first letter
    mov bh, al                 ; BH = col of first letter
    
    pop eax                    ; Restore digraph
    mov al, ah                 ; AL = second letter
    call FindPlayfairPos       ; Find second letter, result in AH=row, AL=col
    mov cl, ah                 ; CL = row of second letter
    mov ch, al                 ; CH = col of second letter
    
    ; Save original ebx value (which has our encrypt/decrypt mode)
    push ebx                   ; Save encryption mode (1=encrypt, 0=decrypt)

    ; Process based on relative positions and encrypt/decrypt mode
    
    ; 1. If in the same row
    cmp bl, cl
    jne NotSameRow
    
    ; Adjust columns based on encrypt/decrypt
    mov al, bh                 ; First letter column
    mov ah, ch                 ; Second letter column
    
    ; Check if encrypting (1=encrypt, 0=decrypt)
    pop ebx                    ; Restore encryption mode
    push ebx                   ; Save it again for later
    cmp ebx, 1                  
    jne DecryptSameRow
    
    ; Encrypt: shift right
    inc al
    cmp al, 5                  ; Check if we need to wrap
    jl SkipWrapCol1
    sub al, 5                  ; Wrap around to 0
SkipWrapCol1:
    
    inc ah
    cmp ah, 5                  ; Check if we need to wrap
    jl SkipWrapCol2
    sub ah, 5                  ; Wrap around to 0
SkipWrapCol2:
    jmp ProcessSameRow
    
DecryptSameRow:
    ; Decrypt: shift left
    dec al
    cmp al, 0
    jge SkipFixRow1
    add al, 5                  ; Handle wrapping from 0 to 4
SkipFixRow1:
    
    dec ah
    cmp ah, 0
    jge SkipFixRow2
    add ah, 5                  ; Handle wrapping from 0 to 4
SkipFixRow2:
    
ProcessSameRow:
    ; Get letters from matrix
    mov bh, al                 ; First letter new col
    mov ch, ah                 ; Second letter new col
    
    ; Calculate positions in matrix and get letters
    movzx eax, bl              ; Row of first letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, bh                 ; + Column
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dl, [edx]              ; First transformed letter
    
    movzx eax, cl              ; Row of second letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, ch                 ; + Column
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dh, [edx]              ; Second transformed letter
    
    ; Store results and continue
    mov [edi], dl
    mov [edi+1], dh
    add edi, 2
    
    ; Move to next digraph in input buffer
    add esi, 2                 ; Move to next pair in input
    pop ebx                    ; Restore encryption mode
    jmp PlayfairMainLoop
    
NotSameRow:
    ; 2. If in the same column
    cmp bh, ch
    jne NotSameCol
    
    ; Adjust rows based on encrypt/decrypt
    mov al, bl                 ; First letter row
    mov ah, cl                 ; Second letter row
    
    ; Check if encrypting (1=encrypt, 0=decrypt)
    pop ebx                    ; Restore encryption mode
    push ebx                   ; Save it again for later
    cmp ebx, 1                  
    jne DecryptSameCol
    
    ; Encrypt: shift down
    inc al
    cmp al, 5                  ; Check if we need to wrap
    jl SkipWrapRow1
    sub al, 5                  ; Wrap around to 0
SkipWrapRow1:
    
    inc ah
    cmp ah, 5                  ; Check if we need to wrap
    jl SkipWrapRow2
    sub ah, 5                  ; Wrap around to 0
SkipWrapRow2:
    jmp ProcessSameCol
    
DecryptSameCol:
    ; Decrypt: shift up
    dec al
    cmp al, 0
    jge SkipFixCol1
    add al, 5                  ; Handle wrapping from 0 to 4
SkipFixCol1:
    
    dec ah
    cmp ah, 0
    jge SkipFixCol2
    add ah, 5                  ; Handle wrapping from 0 to 4
SkipFixCol2:
    
ProcessSameCol:
    ; Get letters from matrix
    mov bl, al                 ; First letter new row
    mov cl, ah                 ; Second letter new row
    
    ; Calculate positions in matrix and get letters
    movzx eax, bl              ; Row of first letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, bh                 ; + Column
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dl, [edx]              ; First transformed letter
    
    movzx eax, cl              ; Row of second letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, ch                 ; + Column
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dh, [edx]              ; Second transformed letter
    
    ; Store results and continue
    mov [edi], dl
    mov [edi+1], dh
    add edi, 2
    
    ; Move to next digraph in input buffer
    add esi, 2                 ; Move to next pair in input
    pop ebx                    ; Restore encryption mode
    jmp PlayfairMainLoop
    
NotSameCol:
    ; 3. Form a rectangle, swap columns
    ; Always the same for encrypt/decrypt
    
    ; Calculate positions in matrix and get letters
    movzx eax, bl              ; Row of first letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, ch                 ; + Column of SECOND letter
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dl, [edx]              ; First transformed letter
    
    movzx eax, cl              ; Row of second letter (clear upper bits)
    mov ecx, 5
    mul ecx                    ; Row * 5
    add al, bh                 ; + Column of FIRST letter
    
    mov edx, OFFSET playfairMatrix
    add edx, eax
    mov dh, [edx]              ; Second transformed letter
    
    ; Store results and continue
    mov [edi], dl
    mov [edi+1], dh
    add edi, 2
    
    ; Move to next digraph in input buffer
    add esi, 2                 ; Move to next pair in input
    pop ebx                    ; Restore encryption mode
    jmp PlayfairMainLoop
    
ProcessSingleLetter:
    ; Handle odd letter at end (should be rare with preprocessing)
    mov [edi], al
    inc edi
    
DonePlayfair:
    mov BYTE PTR [edi], 0      ; Add null terminator
    ret
ProcessPlayfair ENDP

; Preprocesses text for Playfair cipher (handle pairs)
PreprocessPlayfair PROC
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET tempBuffer
    
PreprocessLoop:
    mov al, [esi]
    cmp al, 0
    je CheckLastLetter
    
    ; Skip non-alphabetic characters
    cmp al, 'A'
    jl SkipNonAlpha
    cmp al, 'z'
    jg SkipNonAlpha
    cmp al, 'Z'
    jle IsUpperAlpha
    cmp al, 'a'
    jl SkipNonAlpha
    
    ; Convert lowercase to uppercase
    sub al, 32
    jmp IsUpperAlpha
    
IsUpperAlpha:
    ; Handle I/J substitution
    cmp al, 'J'
    jne NotJPreprocess
    mov al, 'I'
    
NotJPreprocess:
    ; Store this letter
    mov [edi], al
    inc edi
    inc esi
    
    ; Check if we need to add a second letter
    mov al, [esi]
    cmp al, 0
    je AddXAndFinish
    
    ; Process next character
    cmp al, 'A'
    jl SkipNonAlpha2
    cmp al, 'z'
    jg SkipNonAlpha2
    cmp al, 'Z'
    jle ProcessNextAlpha
    cmp al, 'a'
    jl SkipNonAlpha2
    
    ; Convert lowercase to uppercase
    sub al, 32
    
ProcessNextAlpha:
    ; Handle I/J substitution
    cmp al, 'J'
    jne NotJPreprocess2
    mov al, 'I'
    
NotJPreprocess2:
    ; Check if this letter equals the previous one
    cmp al, [edi-1]
    jne AddSecondLetter
    
    ; If same, add 'X' between
    mov BYTE PTR [edi], 'X'
    inc edi
    jmp PreprocessLoop      ; Don't consume the second letter yet
    
AddSecondLetter:
    ; Add the second letter
    mov [edi], al
    inc edi
    inc esi
    jmp PreprocessLoop
    
SkipNonAlpha:
    ; Skip non-alpha
    inc esi
    jmp PreprocessLoop
    
SkipNonAlpha2:
    ; Skip non-alpha in second position
    inc esi
    jmp PreprocessLoop
    
AddXAndFinish:
    ; Add 'X' for a single trailing letter
    mov BYTE PTR [edi], 'X'
    inc edi
    
CheckLastLetter:
    ; Check if we have an odd number of processed letters
    mov eax, edi
    sub eax, OFFSET tempBuffer
    and eax, 1              ; Check if odd (last bit = 1)
    jz DonePreprocess       ; If even, we're done
    
    ; Add 'X' to make pairs complete
    mov BYTE PTR [edi], 'X'
    inc edi
    
DonePreprocess:
    mov BYTE PTR [edi], 0   ; Add null terminator
    ret
PreprocessPlayfair ENDP

; Process Monoalphabetic cipher
ProcessMonoalphabetic PROC
    mov esi, OFFSET inputBuffer  ; Source pointer
    mov edi, OFFSET outputBuffer ; Destination pointer
    
MonoalphabeticLoop:
    mov al, [esi]              ; Get current character
    cmp al, 0                  ; Check for null terminator
    je DoneMonoalphabetic
    
    ; Check if character is a letter
    cmp al, 'A'
    jl NotALetterMono
    cmp al, 'z'
    jg NotALetterMono
    cmp al, 'Z'
    jle UpperCaseLetterMono
    cmp al, 'a'
    jl NotALetterMono
    
    ; Process lowercase letter
    push eax                   ; Save original character
    sub al, 'a'                ; Convert to 0-25 index
    movzx ecx, al              ; Zero-extend to use as index
    
    ; Check encryption mode (ebx is 1 for encrypt, 0 for decrypt)
    cmp ebx, 1
    jne DecryptLowerMono
    
    ; Encrypt - use the monoTable
    mov al, [monoTable + ecx]
    add al, 'a'                ; Convert back to ASCII
    jmp SaveCharMono
    
DecryptLowerMono:
    ; Decrypt - find the original letter
    mov edx, 0                 ; Start search at 0
    
DecryptLowerLoop:
    cmp edx, 26
    jge NotFoundLowerMono      ; Should not happen with valid key
    
    movzx eax, BYTE PTR [monoTable + edx]
    cmp al, cl                 ; Compare table entry with our character index
    je FoundLowerMono
    inc edx
    jmp DecryptLowerLoop
    
FoundLowerMono:
    mov al, dl
    add al, 'a'                ; Convert index back to ASCII
    jmp SaveCharMono
    
NotFoundLowerMono:
    ; If not found, revert to original
    pop eax                    ; Restore original
    jmp NotALetterMono
    
SaveCharMono:
    pop edx                    ; Remove original from stack
    mov [edi], al
    inc esi
    inc edi
    jmp MonoalphabeticLoop
    
UpperCaseLetterMono:
    push eax                   ; Save original character
    sub al, 'A'                ; Convert to 0-25 index
    movzx ecx, al              ; Zero-extend to use as index
    
    ; Check encryption mode (ebx is 1 for encrypt, 0 for decrypt)
    cmp ebx, 1
    jne DecryptUpperMono
    
    ; Encrypt - use the monoTable
    mov al, [monoTable + ecx]
    add al, 'A'                ; Convert back to ASCII
    jmp SaveCharUpperMono
    
DecryptUpperMono:
    ; Decrypt - find the original letter
    mov edx, 0                 ; Start search at 0
    
DecryptUpperLoop:
    cmp edx, 26
    jge NotFoundUpperMono      ; Should not happen with valid key
    
    movzx eax, BYTE PTR [monoTable + edx]
    cmp al, cl                 ; Compare table entry with our character index
    je FoundUpperMono
    inc edx
    jmp DecryptUpperLoop
    
FoundUpperMono:
    mov al, dl
    add al, 'A'                ; Convert index back to ASCII
    jmp SaveCharUpperMono
    
NotFoundUpperMono:
    ; If not found, revert to original
    pop eax                    ; Restore original
    jmp NotALetterMono
    
SaveCharUpperMono:
    pop edx                    ; Remove original from stack
    mov [edi], al
    inc esi
    inc edi
    jmp MonoalphabeticLoop
    
NotALetterMono:
    ; Keep non-alphabetic characters as they are
    mov [edi], al
    inc esi
    inc edi
    jmp MonoalphabeticLoop
    
DoneMonoalphabetic:
    mov BYTE PTR [edi], 0      ; Add null terminator
    ret
ProcessMonoalphabetic ENDP

; Remove the entire process rail fence cipher and replace with stub
ProcessRailFence PROC
    ; Left as a stub for compatibility
    ; The monoalphabetic cipher is used instead
    jmp ProcessMonoalphabetic
ProcessRailFence ENDP

; Remove/stub the rail fence calculation functions
CalculateRail PROC
    ; Left as a stub for compatibility
    ret
CalculateRail ENDP

; Display result to the user with visual formatting
DisplayResult PROC
    call Crlf
    call Crlf
    
    ; Create a box around the result
    mov eax, lightGray + (black * 16)
    call SetTextColor
    
    ; Top border
    mov ecx, 60
    mov al, '='
TopBorderLoop:
    call WriteChar
    loop TopBorderLoop
    call Crlf
    
    ; Label with bright text
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Show "Result: " in bright cyan
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov edx, OFFSET resultMsg
    call WriteString
    
    ; Show actual result in bright yellow
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET outputBuffer
    call WriteString
    
    ; Continue right border
    mov eax, lightGray + (black * 16)
    call SetTextColor
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    call Crlf
    
    ; Bottom border
    mov ecx, 60
    mov al, '='
BottomBorderLoop:
    call WriteChar
    loop BottomBorderLoop
    call Crlf
    
    ; Reset color to default
    mov eax, white + (black * 16)
    call SetTextColor
    
    ret
DisplayResult ENDP

END main