;    ________________________________
;   |                                |
;   |    SaBootloader version 0x01   |
;   |________________________________|                                
;   [-_-_-_website:saedi.zya.me_-_-_-]
; [.]
;[.]

[BITS 16]
[org 0x7c00]

mov ax , 0x0003 ; [ ah = 0 clean screen and al = 0x03 text mod ] پاک سازی صفحه 
int 0x10

reset_drive:
    
    mov ah, 0 ; بارگزاری مجدد دیسک
    int 0x13
    or ah, ah ; برسی خروجی 0
    jnz reset_drive ; اگه صفر نبود پرش کن

    ; لود کردن سکتور بعدی
    xor ax, ax
    mov es, ax ; برای آدرس دهی فیزیکی Extra Segment صفر کردن 
    mov ch, ah ; 0 سیلندر
    mov dh, ah ; هدر 0
    mov bx, 0x1000 ; 0x1000 بارگذاری کرنل از ادرس 
    mov cl, 0x02 ; تنظیم سکتور شروع به 2
    mov ah, 0x02 ; Read Selector for Drive فراخوانی سیستم 
    mov al, 0x01 ; تعداد هدر کرنل
    int 0x13 
    or ah , ah 
    jnz log_error ; نمایش خطا
    
cli ; غیر فعال کردن وقفه ضروری

xor ax , ax
mov ds , ax ; پاک سازی دیتا سگمنت

lgdt[gtd_desc]

;protect mode جهت ورود به cr0 تنظیم 
mov eax, cr0 
or eax , 0x01
mov cr0 , eax

jmp 0x08:clear_pipe32; پرش و پاک سازی لوله خط

; لوله خط و یا پاپ لاین قسمتی است که دستورات رو درون صف قرار میدهد و یکی یکی اجرا میکند حالا ما باید از صف 16 بیتی خارج بشویم
; و برویم به 32 بیتی
[BITS 32]
clear_pipe32:

  mov ax, 0x10 ; قرار دادن این مقدار درون این رجستر جهت تعریف استک و دیتا درون جدول توصیف گر سراری
  mov ds, ax ; تنظیم استک
  mov ss, ax ; تنظیم دیتا


  mov esp, 0x090000 ; تنظیم نشانه گر استک در بالا تا با کرنل مداخله نکند

  mov byte [0xB8000], 88 ; چاپ کردن X
  mov byte [0xB8000+1], 0x1B ; تنظیم پس زمینه آبی پر رنگ و متن آبی روشن
  
  call dword 0x08:0x00001000 ; رفتن به کد سی

  mov byte [0xB8000], 89 ; چاپ کردن Y
  mov byte [0xB8000+1], 0x1B ; تنظیم پس زمینه آبی پر رنگ و متن آبی روشن

  jmp $ ; حلقه بی نهایت در صورت پرش از کرنل


gdt:

gdt_null:
  dd 0
  dd 0

gdt_code:
  dw 0xFFFF
  dw 0
  db 0
  db 10011010b
  db 11001111b
  db 0

gdt_data:
  dw 0xFFFF
  dw 0
  db 0
  db 10010010b
  db 11001111b
  db 0

gdt_end:

gtd_desc:
   dw gdt_end - gdt - 1
   dd gdt



log_error:
    mov si , error_msg ; بارگزاری پیام
    mov ah , 0x0e ; برای چاپ بر روی صفحه ah تنظیم 

    run:
        mov al, [si] ; خواند کارکتر
        int 0x10 
        inc si ; رفتن به کارکتر بعدی
        or al , al ; برسی وجود 0 جهت برسی رسیدن به انتهای پیام
        jnz run ; اگه 0 نبود کارکتر بعدی چاپ بشود
        

error_msg db "Saedi: Not can to load sector2" , 0
    


times 510 - ($ - $$) db 0 ; پر کردن باقی مانده سکتور با صفر جهت تکمیل سکتور
dw 0xAA55 ; امضای بوت لودر
