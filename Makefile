# پوشه ها
code := code/
lib := lib/
export := export/

# اسکریپت های اساسی
kernel := kernel.c
boot := boot.asm
link := link.ld

# کتابخانه ها
log := log.c

bin := boot.bin
img := SaediOS.img

install:
	@sudo apt update
	@sudo apt install nasm qemu-system coreutils

all:
	@make clean
	@make build
	@make link 
	@make img
	@make clean


build:
	
	@nasm $(code)$(boot) -f bin -o $(bin)
	@echo "Compiled SaBootloader!"

	@gcc -m32 -c $(code)$(kernel) -o kernel.o -ffreestanding -fno-builtin -fno-pic -fno-pie -O2 -Wall
	@echo "Compiled kernel!"

	@gcc -m32 -static -nostartfiles -c $(code)$(lib)$(log) -o log.o
	@echo "log.c Compiled!"

link:
	# لینک کرنل با کتابخانه ها
	@ld -m elf_i386 -T $(code)$(link) -o kernel.elf kernel.o log.o
	
	@objcopy -R .note -R .comment -S -O binary kernel.elf kernel.bin
	
	@rm kernel.elf
	@echo "linked!"

img:
	@bash -c 'head -c $$( ./dummy.sh  $$(( $$(stat -c %s kernel.bin) + $$(stat -c %s boot.bin) )) ) < /dev/zero > tmp'
	@cat boot.bin kernel.bin tmp > $(img)
	@echo "Created $(img)! "
	@mv $(img) $(export)

clean:
	@rm -f *.bin *.o *.elf tmp
	@echo "clean directory!"

qemu:
	@qemu-system-x86_64 -fda $(export)$(img)
	@echo "Run Qemu!"

all-qemu:
	@make all
	@make qemu name=$(img)




