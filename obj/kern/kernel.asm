
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/kclock.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 80 37 10 f0       	push   $0xf0103780
f0100050:	e8 48 27 00 00       	call   f010279d <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
	{
	
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
		}
	else
	mon_backtrace(0, 0, 0);	
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0f 07 00 00       	call   f010078a <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 37 10 f0       	push   $0xf010379c
f0100087:	e8 11 27 00 00       	call   f010279d <cprintf>
	
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 50 79 11 f0       	mov    $0xf0117950,%eax
f010009f:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 73 11 f0       	push   $0xf0117300
f01000ac:	e8 3c 32 00 00       	call   f01032ed <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 a2 04 00 00       	call   f0100558 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 37 10 f0       	push   $0xf01037b7
f01000c3:	e8 d5 26 00 00       	call   f010279d <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 f2 0f 00 00       	call   f01010bf <mem_init>
	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000cd:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000d4:	e8 67 ff ff ff       	call   f0100040 <test_backtrace>
f01000d9:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000dc:	83 ec 0c             	sub    $0xc,%esp
f01000df:	6a 00                	push   $0x0
f01000e1:	e8 11 07 00 00       	call   f01007f7 <monitor>
f01000e6:	83 c4 10             	add    $0x10,%esp
f01000e9:	eb f1                	jmp    f01000dc <i386_init+0x48>

f01000eb <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000eb:	55                   	push   %ebp
f01000ec:	89 e5                	mov    %esp,%ebp
f01000ee:	56                   	push   %esi
f01000ef:	53                   	push   %ebx
f01000f0:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000f3:	83 3d 40 79 11 f0 00 	cmpl   $0x0,0xf0117940
f01000fa:	75 37                	jne    f0100133 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000fc:	89 35 40 79 11 f0    	mov    %esi,0xf0117940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100102:	fa                   	cli    
f0100103:	fc                   	cld    

	va_start(ap, fmt);
f0100104:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100107:	83 ec 04             	sub    $0x4,%esp
f010010a:	ff 75 0c             	pushl  0xc(%ebp)
f010010d:	ff 75 08             	pushl  0x8(%ebp)
f0100110:	68 d2 37 10 f0       	push   $0xf01037d2
f0100115:	e8 83 26 00 00       	call   f010279d <cprintf>
	vcprintf(fmt, ap);
f010011a:	83 c4 08             	add    $0x8,%esp
f010011d:	53                   	push   %ebx
f010011e:	56                   	push   %esi
f010011f:	e8 53 26 00 00       	call   f0102777 <vcprintf>
	cprintf("\n");
f0100124:	c7 04 24 9e 3f 10 f0 	movl   $0xf0103f9e,(%esp)
f010012b:	e8 6d 26 00 00       	call   f010279d <cprintf>
	va_end(ap);
f0100130:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100133:	83 ec 0c             	sub    $0xc,%esp
f0100136:	6a 00                	push   $0x0
f0100138:	e8 ba 06 00 00       	call   f01007f7 <monitor>
f010013d:	83 c4 10             	add    $0x10,%esp
f0100140:	eb f1                	jmp    f0100133 <_panic+0x48>

f0100142 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100142:	55                   	push   %ebp
f0100143:	89 e5                	mov    %esp,%ebp
f0100145:	53                   	push   %ebx
f0100146:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100149:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010014c:	ff 75 0c             	pushl  0xc(%ebp)
f010014f:	ff 75 08             	pushl  0x8(%ebp)
f0100152:	68 ea 37 10 f0       	push   $0xf01037ea
f0100157:	e8 41 26 00 00       	call   f010279d <cprintf>
	vcprintf(fmt, ap);
f010015c:	83 c4 08             	add    $0x8,%esp
f010015f:	53                   	push   %ebx
f0100160:	ff 75 10             	pushl  0x10(%ebp)
f0100163:	e8 0f 26 00 00       	call   f0102777 <vcprintf>
	cprintf("\n");
f0100168:	c7 04 24 9e 3f 10 f0 	movl   $0xf0103f9e,(%esp)
f010016f:	e8 29 26 00 00       	call   f010279d <cprintf>
	va_end(ap);
}
f0100174:	83 c4 10             	add    $0x10,%esp
f0100177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010017a:	c9                   	leave  
f010017b:	c3                   	ret    

f010017c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010017c:	55                   	push   %ebp
f010017d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100184:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100185:	a8 01                	test   $0x1,%al
f0100187:	74 0b                	je     f0100194 <serial_proc_data+0x18>
f0100189:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010018e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018f:	0f b6 c0             	movzbl %al,%eax
f0100192:	eb 05                	jmp    f0100199 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100199:	5d                   	pop    %ebp
f010019a:	c3                   	ret    

f010019b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019b:	55                   	push   %ebp
f010019c:	89 e5                	mov    %esp,%ebp
f010019e:	53                   	push   %ebx
f010019f:	83 ec 04             	sub    $0x4,%esp
f01001a2:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a4:	eb 2b                	jmp    f01001d1 <cons_intr+0x36>
		if (c == 0)
f01001a6:	85 c0                	test   %eax,%eax
f01001a8:	74 27                	je     f01001d1 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001aa:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f01001b0:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b3:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f01001b9:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001bf:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c5:	75 0a                	jne    f01001d1 <cons_intr+0x36>
			cons.wpos = 0;
f01001c7:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f01001ce:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d1:	ff d3                	call   *%ebx
f01001d3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d6:	75 ce                	jne    f01001a6 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d8:	83 c4 04             	add    $0x4,%esp
f01001db:	5b                   	pop    %ebx
f01001dc:	5d                   	pop    %ebp
f01001dd:	c3                   	ret    

f01001de <kbd_proc_data>:
f01001de:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e3:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001e4:	a8 01                	test   $0x1,%al
f01001e6:	0f 84 f8 00 00 00    	je     f01002e4 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001ec:	a8 20                	test   $0x20,%al
f01001ee:	0f 85 f6 00 00 00    	jne    f01002ea <kbd_proc_data+0x10c>
f01001f4:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f9:	ec                   	in     (%dx),%al
f01001fa:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001fc:	3c e0                	cmp    $0xe0,%al
f01001fe:	75 0d                	jne    f010020d <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100200:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f0100207:	b8 00 00 00 00       	mov    $0x0,%eax
f010020c:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010020d:	55                   	push   %ebp
f010020e:	89 e5                	mov    %esp,%ebp
f0100210:	53                   	push   %ebx
f0100211:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100214:	84 c0                	test   %al,%al
f0100216:	79 36                	jns    f010024e <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100218:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f010021e:	89 cb                	mov    %ecx,%ebx
f0100220:	83 e3 40             	and    $0x40,%ebx
f0100223:	83 e0 7f             	and    $0x7f,%eax
f0100226:	85 db                	test   %ebx,%ebx
f0100228:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010022b:	0f b6 d2             	movzbl %dl,%edx
f010022e:	0f b6 82 60 39 10 f0 	movzbl -0xfefc6a0(%edx),%eax
f0100235:	83 c8 40             	or     $0x40,%eax
f0100238:	0f b6 c0             	movzbl %al,%eax
f010023b:	f7 d0                	not    %eax
f010023d:	21 c8                	and    %ecx,%eax
f010023f:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f0100244:	b8 00 00 00 00       	mov    $0x0,%eax
f0100249:	e9 a4 00 00 00       	jmp    f01002f2 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010024e:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f0100254:	f6 c1 40             	test   $0x40,%cl
f0100257:	74 0e                	je     f0100267 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100259:	83 c8 80             	or     $0xffffff80,%eax
f010025c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010025e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100261:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100267:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010026a:	0f b6 82 60 39 10 f0 	movzbl -0xfefc6a0(%edx),%eax
f0100271:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100277:	0f b6 8a 60 38 10 f0 	movzbl -0xfefc7a0(%edx),%ecx
f010027e:	31 c8                	xor    %ecx,%eax
f0100280:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100285:	89 c1                	mov    %eax,%ecx
f0100287:	83 e1 03             	and    $0x3,%ecx
f010028a:	8b 0c 8d 40 38 10 f0 	mov    -0xfefc7c0(,%ecx,4),%ecx
f0100291:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100295:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100298:	a8 08                	test   $0x8,%al
f010029a:	74 1b                	je     f01002b7 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010029c:	89 da                	mov    %ebx,%edx
f010029e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002a1:	83 f9 19             	cmp    $0x19,%ecx
f01002a4:	77 05                	ja     f01002ab <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a6:	83 eb 20             	sub    $0x20,%ebx
f01002a9:	eb 0c                	jmp    f01002b7 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002ab:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002ae:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002b1:	83 fa 19             	cmp    $0x19,%edx
f01002b4:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b7:	f7 d0                	not    %eax
f01002b9:	a8 06                	test   $0x6,%al
f01002bb:	75 33                	jne    f01002f0 <kbd_proc_data+0x112>
f01002bd:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002c3:	75 2b                	jne    f01002f0 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c5:	83 ec 0c             	sub    $0xc,%esp
f01002c8:	68 04 38 10 f0       	push   $0xf0103804
f01002cd:	e8 cb 24 00 00       	call   f010279d <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d7:	b8 03 00 00 00       	mov    $0x3,%eax
f01002dc:	ee                   	out    %al,(%dx)
f01002dd:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002e0:	89 d8                	mov    %ebx,%eax
f01002e2:	eb 0e                	jmp    f01002f2 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e9:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ef:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f0:	89 d8                	mov    %ebx,%eax
}
f01002f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f5:	c9                   	leave  
f01002f6:	c3                   	ret    

f01002f7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f7:	55                   	push   %ebp
f01002f8:	89 e5                	mov    %esp,%ebp
f01002fa:	57                   	push   %edi
f01002fb:	56                   	push   %esi
f01002fc:	53                   	push   %ebx
f01002fd:	83 ec 1c             	sub    $0x1c,%esp
f0100300:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100302:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100307:	be fd 03 00 00       	mov    $0x3fd,%esi
f010030c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100311:	eb 09                	jmp    f010031c <cons_putc+0x25>
f0100313:	89 ca                	mov    %ecx,%edx
f0100315:	ec                   	in     (%dx),%al
f0100316:	ec                   	in     (%dx),%al
f0100317:	ec                   	in     (%dx),%al
f0100318:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100319:	83 c3 01             	add    $0x1,%ebx
f010031c:	89 f2                	mov    %esi,%edx
f010031e:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031f:	a8 20                	test   $0x20,%al
f0100321:	75 08                	jne    f010032b <cons_putc+0x34>
f0100323:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100329:	7e e8                	jle    f0100313 <cons_putc+0x1c>
f010032b:	89 f8                	mov    %edi,%eax
f010032d:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100330:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100335:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100336:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033b:	be 79 03 00 00       	mov    $0x379,%esi
f0100340:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100345:	eb 09                	jmp    f0100350 <cons_putc+0x59>
f0100347:	89 ca                	mov    %ecx,%edx
f0100349:	ec                   	in     (%dx),%al
f010034a:	ec                   	in     (%dx),%al
f010034b:	ec                   	in     (%dx),%al
f010034c:	ec                   	in     (%dx),%al
f010034d:	83 c3 01             	add    $0x1,%ebx
f0100350:	89 f2                	mov    %esi,%edx
f0100352:	ec                   	in     (%dx),%al
f0100353:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100359:	7f 04                	jg     f010035f <cons_putc+0x68>
f010035b:	84 c0                	test   %al,%al
f010035d:	79 e8                	jns    f0100347 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100364:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100368:	ee                   	out    %al,(%dx)
f0100369:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010036e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100373:	ee                   	out    %al,(%dx)
f0100374:	b8 08 00 00 00       	mov    $0x8,%eax
f0100379:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010037a:	89 fa                	mov    %edi,%edx
f010037c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100382:	89 f8                	mov    %edi,%eax
f0100384:	80 cc 07             	or     $0x7,%ah
f0100387:	85 d2                	test   %edx,%edx
f0100389:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010038c:	89 f8                	mov    %edi,%eax
f010038e:	0f b6 c0             	movzbl %al,%eax
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	74 74                	je     f010040a <cons_putc+0x113>
f0100396:	83 f8 09             	cmp    $0x9,%eax
f0100399:	7f 0a                	jg     f01003a5 <cons_putc+0xae>
f010039b:	83 f8 08             	cmp    $0x8,%eax
f010039e:	74 14                	je     f01003b4 <cons_putc+0xbd>
f01003a0:	e9 99 00 00 00       	jmp    f010043e <cons_putc+0x147>
f01003a5:	83 f8 0a             	cmp    $0xa,%eax
f01003a8:	74 3a                	je     f01003e4 <cons_putc+0xed>
f01003aa:	83 f8 0d             	cmp    $0xd,%eax
f01003ad:	74 3d                	je     f01003ec <cons_putc+0xf5>
f01003af:	e9 8a 00 00 00       	jmp    f010043e <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003b4:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003bb:	66 85 c0             	test   %ax,%ax
f01003be:	0f 84 e6 00 00 00    	je     f01004aa <cons_putc+0x1b3>
			crt_pos--;
f01003c4:	83 e8 01             	sub    $0x1,%eax
f01003c7:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003cd:	0f b7 c0             	movzwl %ax,%eax
f01003d0:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d5:	83 cf 20             	or     $0x20,%edi
f01003d8:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003de:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003e2:	eb 78                	jmp    f010045c <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003e4:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f01003eb:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ec:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003f3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f9:	c1 e8 16             	shr    $0x16,%eax
f01003fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ff:	c1 e0 04             	shl    $0x4,%eax
f0100402:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f0100408:	eb 52                	jmp    f010045c <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010040a:	b8 20 00 00 00       	mov    $0x20,%eax
f010040f:	e8 e3 fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f0100414:	b8 20 00 00 00       	mov    $0x20,%eax
f0100419:	e8 d9 fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f010041e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100423:	e8 cf fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f0100428:	b8 20 00 00 00       	mov    $0x20,%eax
f010042d:	e8 c5 fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f0100432:	b8 20 00 00 00       	mov    $0x20,%eax
f0100437:	e8 bb fe ff ff       	call   f01002f7 <cons_putc>
f010043c:	eb 1e                	jmp    f010045c <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010043e:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100445:	8d 50 01             	lea    0x1(%eax),%edx
f0100448:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f010044f:	0f b7 c0             	movzwl %ax,%eax
f0100452:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100458:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010045c:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100463:	cf 07 
f0100465:	76 43                	jbe    f01004aa <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100467:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f010046c:	83 ec 04             	sub    $0x4,%esp
f010046f:	68 00 0f 00 00       	push   $0xf00
f0100474:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010047a:	52                   	push   %edx
f010047b:	50                   	push   %eax
f010047c:	e8 b9 2e 00 00       	call   f010333a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100481:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100487:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010048d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100493:	83 c4 10             	add    $0x10,%esp
f0100496:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010049b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010049e:	39 d0                	cmp    %edx,%eax
f01004a0:	75 f4                	jne    f0100496 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004a2:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f01004a9:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004aa:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f01004b0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b5:	89 ca                	mov    %ecx,%edx
f01004b7:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b8:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f01004bf:	8d 71 01             	lea    0x1(%ecx),%esi
f01004c2:	89 d8                	mov    %ebx,%eax
f01004c4:	66 c1 e8 08          	shr    $0x8,%ax
f01004c8:	89 f2                	mov    %esi,%edx
f01004ca:	ee                   	out    %al,(%dx)
f01004cb:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d0:	89 ca                	mov    %ecx,%edx
f01004d2:	ee                   	out    %al,(%dx)
f01004d3:	89 d8                	mov    %ebx,%eax
f01004d5:	89 f2                	mov    %esi,%edx
f01004d7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004db:	5b                   	pop    %ebx
f01004dc:	5e                   	pop    %esi
f01004dd:	5f                   	pop    %edi
f01004de:	5d                   	pop    %ebp
f01004df:	c3                   	ret    

f01004e0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004e0:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f01004e7:	74 11                	je     f01004fa <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e9:	55                   	push   %ebp
f01004ea:	89 e5                	mov    %esp,%ebp
f01004ec:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ef:	b8 7c 01 10 f0       	mov    $0xf010017c,%eax
f01004f4:	e8 a2 fc ff ff       	call   f010019b <cons_intr>
}
f01004f9:	c9                   	leave  
f01004fa:	f3 c3                	repz ret 

f01004fc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004fc:	55                   	push   %ebp
f01004fd:	89 e5                	mov    %esp,%ebp
f01004ff:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100502:	b8 de 01 10 f0       	mov    $0xf01001de,%eax
f0100507:	e8 8f fc ff ff       	call   f010019b <cons_intr>
}
f010050c:	c9                   	leave  
f010050d:	c3                   	ret    

f010050e <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010050e:	55                   	push   %ebp
f010050f:	89 e5                	mov    %esp,%ebp
f0100511:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100514:	e8 c7 ff ff ff       	call   f01004e0 <serial_intr>
	kbd_intr();
f0100519:	e8 de ff ff ff       	call   f01004fc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010051e:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f0100523:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f0100529:	74 26                	je     f0100551 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010052b:	8d 50 01             	lea    0x1(%eax),%edx
f010052e:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f0100534:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010053b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010053d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100543:	75 11                	jne    f0100556 <cons_getc+0x48>
			cons.rpos = 0;
f0100545:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f010054c:	00 00 00 
f010054f:	eb 05                	jmp    f0100556 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100551:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100556:	c9                   	leave  
f0100557:	c3                   	ret    

f0100558 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100558:	55                   	push   %ebp
f0100559:	89 e5                	mov    %esp,%ebp
f010055b:	57                   	push   %edi
f010055c:	56                   	push   %esi
f010055d:	53                   	push   %ebx
f010055e:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100561:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100568:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056f:	5a a5 
	if (*cp != 0xA55A) {
f0100571:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100578:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010057c:	74 11                	je     f010058f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010057e:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f0100585:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100588:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010058d:	eb 16                	jmp    f01005a5 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100596:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f010059d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a5:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f01005ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b0:	89 fa                	mov    %edi,%edx
f01005b2:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b3:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b6:	89 da                	mov    %ebx,%edx
f01005b8:	ec                   	in     (%dx),%al
f01005b9:	0f b6 c8             	movzbl %al,%ecx
f01005bc:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bf:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c4:	89 fa                	mov    %edi,%edx
f01005c6:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c7:	89 da                	mov    %ebx,%edx
f01005c9:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ca:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f01005d0:	0f b6 c0             	movzbl %al,%eax
f01005d3:	09 c8                	or     %ecx,%eax
f01005d5:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005db:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e5:	89 f2                	mov    %esi,%edx
f01005e7:	ee                   	out    %al,(%dx)
f01005e8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005ed:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f2:	ee                   	out    %al,(%dx)
f01005f3:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f8:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005fd:	89 da                	mov    %ebx,%edx
f01005ff:	ee                   	out    %al,(%dx)
f0100600:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100605:	b8 00 00 00 00       	mov    $0x0,%eax
f010060a:	ee                   	out    %al,(%dx)
f010060b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100610:	b8 03 00 00 00       	mov    $0x3,%eax
f0100615:	ee                   	out    %al,(%dx)
f0100616:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010061b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100620:	ee                   	out    %al,(%dx)
f0100621:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100626:	b8 01 00 00 00       	mov    $0x1,%eax
f010062b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010062c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100631:	ec                   	in     (%dx),%al
f0100632:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100634:	3c ff                	cmp    $0xff,%al
f0100636:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f010063d:	89 f2                	mov    %esi,%edx
f010063f:	ec                   	in     (%dx),%al
f0100640:	89 da                	mov    %ebx,%edx
f0100642:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100643:	80 f9 ff             	cmp    $0xff,%cl
f0100646:	75 10                	jne    f0100658 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100648:	83 ec 0c             	sub    $0xc,%esp
f010064b:	68 10 38 10 f0       	push   $0xf0103810
f0100650:	e8 48 21 00 00       	call   f010279d <cprintf>
f0100655:	83 c4 10             	add    $0x10,%esp
}
f0100658:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010065b:	5b                   	pop    %ebx
f010065c:	5e                   	pop    %esi
f010065d:	5f                   	pop    %edi
f010065e:	5d                   	pop    %ebp
f010065f:	c3                   	ret    

f0100660 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100660:	55                   	push   %ebp
f0100661:	89 e5                	mov    %esp,%ebp
f0100663:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100666:	8b 45 08             	mov    0x8(%ebp),%eax
f0100669:	e8 89 fc ff ff       	call   f01002f7 <cons_putc>
}
f010066e:	c9                   	leave  
f010066f:	c3                   	ret    

f0100670 <getchar>:

int
getchar(void)
{
f0100670:	55                   	push   %ebp
f0100671:	89 e5                	mov    %esp,%ebp
f0100673:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100676:	e8 93 fe ff ff       	call   f010050e <cons_getc>
f010067b:	85 c0                	test   %eax,%eax
f010067d:	74 f7                	je     f0100676 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <iscons>:

int
iscons(int fdnum)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100684:	b8 01 00 00 00       	mov    $0x1,%eax
f0100689:	5d                   	pop    %ebp
f010068a:	c3                   	ret    

f010068b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010068b:	55                   	push   %ebp
f010068c:	89 e5                	mov    %esp,%ebp
f010068e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100691:	68 60 3a 10 f0       	push   $0xf0103a60
f0100696:	68 7e 3a 10 f0       	push   $0xf0103a7e
f010069b:	68 83 3a 10 f0       	push   $0xf0103a83
f01006a0:	e8 f8 20 00 00       	call   f010279d <cprintf>
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 04 3b 10 f0       	push   $0xf0103b04
f01006ad:	68 8c 3a 10 f0       	push   $0xf0103a8c
f01006b2:	68 83 3a 10 f0       	push   $0xf0103a83
f01006b7:	e8 e1 20 00 00       	call   f010279d <cprintf>
f01006bc:	83 c4 0c             	add    $0xc,%esp
f01006bf:	68 04 3b 10 f0       	push   $0xf0103b04
f01006c4:	68 95 3a 10 f0       	push   $0xf0103a95
f01006c9:	68 83 3a 10 f0       	push   $0xf0103a83
f01006ce:	e8 ca 20 00 00       	call   f010279d <cprintf>
	return 0;
}
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	c9                   	leave  
f01006d9:	c3                   	ret    

f01006da <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006da:	55                   	push   %ebp
f01006db:	89 e5                	mov    %esp,%ebp
f01006dd:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006e0:	68 9f 3a 10 f0       	push   $0xf0103a9f
f01006e5:	e8 b3 20 00 00       	call   f010279d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ea:	83 c4 08             	add    $0x8,%esp
f01006ed:	68 0c 00 10 00       	push   $0x10000c
f01006f2:	68 2c 3b 10 f0       	push   $0xf0103b2c
f01006f7:	e8 a1 20 00 00       	call   f010279d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006fc:	83 c4 0c             	add    $0xc,%esp
f01006ff:	68 0c 00 10 00       	push   $0x10000c
f0100704:	68 0c 00 10 f0       	push   $0xf010000c
f0100709:	68 54 3b 10 f0       	push   $0xf0103b54
f010070e:	e8 8a 20 00 00       	call   f010279d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100713:	83 c4 0c             	add    $0xc,%esp
f0100716:	68 71 37 10 00       	push   $0x103771
f010071b:	68 71 37 10 f0       	push   $0xf0103771
f0100720:	68 78 3b 10 f0       	push   $0xf0103b78
f0100725:	e8 73 20 00 00       	call   f010279d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010072a:	83 c4 0c             	add    $0xc,%esp
f010072d:	68 00 73 11 00       	push   $0x117300
f0100732:	68 00 73 11 f0       	push   $0xf0117300
f0100737:	68 9c 3b 10 f0       	push   $0xf0103b9c
f010073c:	e8 5c 20 00 00       	call   f010279d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100741:	83 c4 0c             	add    $0xc,%esp
f0100744:	68 50 79 11 00       	push   $0x117950
f0100749:	68 50 79 11 f0       	push   $0xf0117950
f010074e:	68 c0 3b 10 f0       	push   $0xf0103bc0
f0100753:	e8 45 20 00 00       	call   f010279d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100758:	b8 4f 7d 11 f0       	mov    $0xf0117d4f,%eax
f010075d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100762:	83 c4 08             	add    $0x8,%esp
f0100765:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010076a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100770:	85 c0                	test   %eax,%eax
f0100772:	0f 48 c2             	cmovs  %edx,%eax
f0100775:	c1 f8 0a             	sar    $0xa,%eax
f0100778:	50                   	push   %eax
f0100779:	68 e4 3b 10 f0       	push   $0xf0103be4
f010077e:	e8 1a 20 00 00       	call   f010279d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100783:	b8 00 00 00 00       	mov    $0x0,%eax
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	56                   	push   %esi
f010078e:	53                   	push   %ebx
f010078f:	83 ec 20             	sub    $0x20,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100792:	89 eb                	mov    %ebp,%ebx
	//cprintf("\n Stack backtrace:\n");
	struct Eipdebuginfo info;
	while(pointer)
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",pointer, pointer[1], pointer[2], pointer[3], pointer[4], pointer[5], pointer[6]);
	    debuginfo_eip(pointer[1],&info);
f0100794:	8d 75 e0             	lea    -0x20(%ebp),%esi
	uint32_t *pointer;
	pointer=(uint32_t *) read_ebp();
	// Meghana
	//cprintf("\n Stack backtrace:\n");
	struct Eipdebuginfo info;
	while(pointer)
f0100797:	eb 4e                	jmp    f01007e7 <mon_backtrace+0x5d>
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",pointer, pointer[1], pointer[2], pointer[3], pointer[4], pointer[5], pointer[6]);
f0100799:	ff 73 18             	pushl  0x18(%ebx)
f010079c:	ff 73 14             	pushl  0x14(%ebx)
f010079f:	ff 73 10             	pushl  0x10(%ebx)
f01007a2:	ff 73 0c             	pushl  0xc(%ebx)
f01007a5:	ff 73 08             	pushl  0x8(%ebx)
f01007a8:	ff 73 04             	pushl  0x4(%ebx)
f01007ab:	53                   	push   %ebx
f01007ac:	68 10 3c 10 f0       	push   $0xf0103c10
f01007b1:	e8 e7 1f 00 00       	call   f010279d <cprintf>
	    debuginfo_eip(pointer[1],&info);
f01007b6:	83 c4 18             	add    $0x18,%esp
f01007b9:	56                   	push   %esi
f01007ba:	ff 73 04             	pushl  0x4(%ebx)
f01007bd:	e8 e5 20 00 00       	call   f01028a7 <debuginfo_eip>
	    cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(pointer[1]-info.eip_fn_addr));
f01007c2:	83 c4 08             	add    $0x8,%esp
f01007c5:	8b 43 04             	mov    0x4(%ebx),%eax
f01007c8:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007cb:	50                   	push   %eax
f01007cc:	ff 75 e8             	pushl  -0x18(%ebp)
f01007cf:	ff 75 ec             	pushl  -0x14(%ebp)
f01007d2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007d5:	ff 75 e0             	pushl  -0x20(%ebp)
f01007d8:	68 b8 3a 10 f0       	push   $0xf0103ab8
f01007dd:	e8 bb 1f 00 00       	call   f010279d <cprintf>
	    pointer=(uint32_t *)pointer[0];
f01007e2:	8b 1b                	mov    (%ebx),%ebx
f01007e4:	83 c4 20             	add    $0x20,%esp
	uint32_t *pointer;
	pointer=(uint32_t *) read_ebp();
	// Meghana
	//cprintf("\n Stack backtrace:\n");
	struct Eipdebuginfo info;
	while(pointer)
f01007e7:	85 db                	test   %ebx,%ebx
f01007e9:	75 ae                	jne    f0100799 <mon_backtrace+0xf>
	    debuginfo_eip(pointer[1],&info);
	    cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(pointer[1]-info.eip_fn_addr));
	    pointer=(uint32_t *)pointer[0];
	}
	return 0;
}
f01007eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007f3:	5b                   	pop    %ebx
f01007f4:	5e                   	pop    %esi
f01007f5:	5d                   	pop    %ebp
f01007f6:	c3                   	ret    

f01007f7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007f7:	55                   	push   %ebp
f01007f8:	89 e5                	mov    %esp,%ebp
f01007fa:	57                   	push   %edi
f01007fb:	56                   	push   %esi
f01007fc:	53                   	push   %ebx
f01007fd:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100800:	68 44 3c 10 f0       	push   $0xf0103c44
f0100805:	e8 93 1f 00 00       	call   f010279d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010080a:	c7 04 24 68 3c 10 f0 	movl   $0xf0103c68,(%esp)
f0100811:	e8 87 1f 00 00       	call   f010279d <cprintf>
f0100816:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100819:	83 ec 0c             	sub    $0xc,%esp
f010081c:	68 c8 3a 10 f0       	push   $0xf0103ac8
f0100821:	e8 70 28 00 00       	call   f0103096 <readline>
f0100826:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	85 c0                	test   %eax,%eax
f010082d:	74 ea                	je     f0100819 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010082f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100836:	be 00 00 00 00       	mov    $0x0,%esi
f010083b:	eb 0a                	jmp    f0100847 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010083d:	c6 03 00             	movb   $0x0,(%ebx)
f0100840:	89 f7                	mov    %esi,%edi
f0100842:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100845:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100847:	0f b6 03             	movzbl (%ebx),%eax
f010084a:	84 c0                	test   %al,%al
f010084c:	74 63                	je     f01008b1 <monitor+0xba>
f010084e:	83 ec 08             	sub    $0x8,%esp
f0100851:	0f be c0             	movsbl %al,%eax
f0100854:	50                   	push   %eax
f0100855:	68 cc 3a 10 f0       	push   $0xf0103acc
f010085a:	e8 51 2a 00 00       	call   f01032b0 <strchr>
f010085f:	83 c4 10             	add    $0x10,%esp
f0100862:	85 c0                	test   %eax,%eax
f0100864:	75 d7                	jne    f010083d <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100866:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100869:	74 46                	je     f01008b1 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010086b:	83 fe 0f             	cmp    $0xf,%esi
f010086e:	75 14                	jne    f0100884 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100870:	83 ec 08             	sub    $0x8,%esp
f0100873:	6a 10                	push   $0x10
f0100875:	68 d1 3a 10 f0       	push   $0xf0103ad1
f010087a:	e8 1e 1f 00 00       	call   f010279d <cprintf>
f010087f:	83 c4 10             	add    $0x10,%esp
f0100882:	eb 95                	jmp    f0100819 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100884:	8d 7e 01             	lea    0x1(%esi),%edi
f0100887:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010088b:	eb 03                	jmp    f0100890 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010088d:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100890:	0f b6 03             	movzbl (%ebx),%eax
f0100893:	84 c0                	test   %al,%al
f0100895:	74 ae                	je     f0100845 <monitor+0x4e>
f0100897:	83 ec 08             	sub    $0x8,%esp
f010089a:	0f be c0             	movsbl %al,%eax
f010089d:	50                   	push   %eax
f010089e:	68 cc 3a 10 f0       	push   $0xf0103acc
f01008a3:	e8 08 2a 00 00       	call   f01032b0 <strchr>
f01008a8:	83 c4 10             	add    $0x10,%esp
f01008ab:	85 c0                	test   %eax,%eax
f01008ad:	74 de                	je     f010088d <monitor+0x96>
f01008af:	eb 94                	jmp    f0100845 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008b1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008b8:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008b9:	85 f6                	test   %esi,%esi
f01008bb:	0f 84 58 ff ff ff    	je     f0100819 <monitor+0x22>
f01008c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008c6:	83 ec 08             	sub    $0x8,%esp
f01008c9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008cc:	ff 34 85 a0 3c 10 f0 	pushl  -0xfefc360(,%eax,4)
f01008d3:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d6:	e8 77 29 00 00       	call   f0103252 <strcmp>
f01008db:	83 c4 10             	add    $0x10,%esp
f01008de:	85 c0                	test   %eax,%eax
f01008e0:	75 21                	jne    f0100903 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01008e2:	83 ec 04             	sub    $0x4,%esp
f01008e5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e8:	ff 75 08             	pushl  0x8(%ebp)
f01008eb:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008ee:	52                   	push   %edx
f01008ef:	56                   	push   %esi
f01008f0:	ff 14 85 a8 3c 10 f0 	call   *-0xfefc358(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008f7:	83 c4 10             	add    $0x10,%esp
f01008fa:	85 c0                	test   %eax,%eax
f01008fc:	78 25                	js     f0100923 <monitor+0x12c>
f01008fe:	e9 16 ff ff ff       	jmp    f0100819 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100903:	83 c3 01             	add    $0x1,%ebx
f0100906:	83 fb 03             	cmp    $0x3,%ebx
f0100909:	75 bb                	jne    f01008c6 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010090b:	83 ec 08             	sub    $0x8,%esp
f010090e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100911:	68 ee 3a 10 f0       	push   $0xf0103aee
f0100916:	e8 82 1e 00 00       	call   f010279d <cprintf>
f010091b:	83 c4 10             	add    $0x10,%esp
f010091e:	e9 f6 fe ff ff       	jmp    f0100819 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100923:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100926:	5b                   	pop    %ebx
f0100927:	5e                   	pop    %esi
f0100928:	5f                   	pop    %edi
f0100929:	5d                   	pop    %ebp
f010092a:	c3                   	ret    

f010092b <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f010092b:	55                   	push   %ebp
f010092c:	89 e5                	mov    %esp,%ebp
f010092e:	56                   	push   %esi
f010092f:	53                   	push   %ebx
f0100930:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100932:	83 ec 0c             	sub    $0xc,%esp
f0100935:	50                   	push   %eax
f0100936:	e8 fb 1d 00 00       	call   f0102736 <mc146818_read>
f010093b:	89 c6                	mov    %eax,%esi
f010093d:	83 c3 01             	add    $0x1,%ebx
f0100940:	89 1c 24             	mov    %ebx,(%esp)
f0100943:	e8 ee 1d 00 00       	call   f0102736 <mc146818_read>
f0100948:	c1 e0 08             	shl    $0x8,%eax
f010094b:	09 f0                	or     %esi,%eax
}
f010094d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100950:	5b                   	pop    %ebx
f0100951:	5e                   	pop    %esi
f0100952:	5d                   	pop    %ebp
f0100953:	c3                   	ret    

f0100954 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100954:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100956:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f010095d:	75 0f                	jne    f010096e <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010095f:	b8 4f 89 11 f0       	mov    $0xf011894f,%eax
f0100964:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100969:	a3 38 75 11 f0       	mov    %eax,0xf0117538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    
    result = nextfree;
f010096e:	a1 38 75 11 f0       	mov    0xf0117538,%eax
    
    if(n>0)
f0100973:	85 d2                	test   %edx,%edx
f0100975:	74 14                	je     f010098b <boot_alloc+0x37>
    {
      nextfree = nextfree+ROUNDUP(n, PGSIZE);
f0100977:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f010097d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100983:	01 c2                	add    %eax,%edx
f0100985:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
    }
    
	if ((uint32_t) nextfree > (npages * PGSIZE + KERNBASE))
f010098b:	8b 0d 44 79 11 f0    	mov    0xf0117944,%ecx
f0100991:	8d 91 00 00 0f 00    	lea    0xf0000(%ecx),%edx
f0100997:	c1 e2 0c             	shl    $0xc,%edx
f010099a:	39 15 38 75 11 f0    	cmp    %edx,0xf0117538
f01009a0:	76 17                	jbe    f01009b9 <boot_alloc+0x65>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01009a2:	55                   	push   %ebp
f01009a3:	89 e5                	mov    %esp,%ebp
f01009a5:	83 ec 0c             	sub    $0xc,%esp
      nextfree = nextfree+ROUNDUP(n, PGSIZE);
    }
    
	if ((uint32_t) nextfree > (npages * PGSIZE + KERNBASE))
	{
		panic("Out of Memory");
f01009a8:	68 c4 3c 10 f0       	push   $0xf0103cc4
f01009ad:	6a 73                	push   $0x73
f01009af:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01009b4:	e8 32 f7 ff ff       	call   f01000eb <_panic>
	}

	return result;
}
f01009b9:	f3 c3                	repz ret 

f01009bb <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009bb:	89 d1                	mov    %edx,%ecx
f01009bd:	c1 e9 16             	shr    $0x16,%ecx
f01009c0:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c3:	a8 01                	test   $0x1,%al
f01009c5:	74 52                	je     f0100a19 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009cc:	89 c1                	mov    %eax,%ecx
f01009ce:	c1 e9 0c             	shr    $0xc,%ecx
f01009d1:	3b 0d 44 79 11 f0    	cmp    0xf0117944,%ecx
f01009d7:	72 1b                	jb     f01009f4 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009d9:	55                   	push   %ebp
f01009da:	89 e5                	mov    %esp,%ebp
f01009dc:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009df:	50                   	push   %eax
f01009e0:	68 d0 3f 10 f0       	push   $0xf0103fd0
f01009e5:	68 07 03 00 00       	push   $0x307
f01009ea:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01009ef:	e8 f7 f6 ff ff       	call   f01000eb <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009f4:	c1 ea 0c             	shr    $0xc,%edx
f01009f7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009fd:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a04:	89 c2                	mov    %eax,%edx
f0100a06:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a0e:	85 d2                	test   %edx,%edx
f0100a10:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a15:	0f 44 c2             	cmove  %edx,%eax
f0100a18:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a1e:	c3                   	ret    

f0100a1f <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a1f:	55                   	push   %ebp
f0100a20:	89 e5                	mov    %esp,%ebp
f0100a22:	57                   	push   %edi
f0100a23:	56                   	push   %esi
f0100a24:	53                   	push   %ebx
f0100a25:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a28:	84 c0                	test   %al,%al
f0100a2a:	0f 85 72 02 00 00    	jne    f0100ca2 <check_page_free_list+0x283>
f0100a30:	e9 7f 02 00 00       	jmp    f0100cb4 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a35:	83 ec 04             	sub    $0x4,%esp
f0100a38:	68 f4 3f 10 f0       	push   $0xf0103ff4
f0100a3d:	68 48 02 00 00       	push   $0x248
f0100a42:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100a47:	e8 9f f6 ff ff       	call   f01000eb <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a4c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a52:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a58:	89 c2                	mov    %eax,%edx
f0100a5a:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0100a60:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a66:	0f 95 c2             	setne  %dl
f0100a69:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a6c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a70:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a72:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a76:	8b 00                	mov    (%eax),%eax
f0100a78:	85 c0                	test   %eax,%eax
f0100a7a:	75 dc                	jne    f0100a58 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a88:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a8b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a90:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a95:	be 01 00 00 00       	mov    $0x1,%esi
		
	}
	
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a9a:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100aa0:	eb 53                	jmp    f0100af5 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100aa2:	89 d8                	mov    %ebx,%eax
f0100aa4:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0100aaa:	c1 f8 03             	sar    $0x3,%eax
f0100aad:	c1 e0 0c             	shl    $0xc,%eax
	
	if (PDX(page2pa(pp)) < pdx_limit)
f0100ab0:	89 c2                	mov    %eax,%edx
f0100ab2:	c1 ea 16             	shr    $0x16,%edx
f0100ab5:	39 f2                	cmp    %esi,%edx
f0100ab7:	73 3a                	jae    f0100af3 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ab9:	89 c2                	mov    %eax,%edx
f0100abb:	c1 ea 0c             	shr    $0xc,%edx
f0100abe:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0100ac4:	72 12                	jb     f0100ad8 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ac6:	50                   	push   %eax
f0100ac7:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100acc:	6a 52                	push   $0x52
f0100ace:	68 de 3c 10 f0       	push   $0xf0103cde
f0100ad3:	e8 13 f6 ff ff       	call   f01000eb <_panic>
	
	memset(page2kva(pp), 0x97, 128);
f0100ad8:	83 ec 04             	sub    $0x4,%esp
f0100adb:	68 80 00 00 00       	push   $0x80
f0100ae0:	68 97 00 00 00       	push   $0x97
f0100ae5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100aea:	50                   	push   %eax
f0100aeb:	e8 fd 27 00 00       	call   f01032ed <memset>
f0100af0:	83 c4 10             	add    $0x10,%esp
		
	}
	
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100af3:	8b 1b                	mov    (%ebx),%ebx
f0100af5:	85 db                	test   %ebx,%ebx
f0100af7:	75 a9                	jne    f0100aa2 <check_page_free_list+0x83>
	
	if (PDX(page2pa(pp)) < pdx_limit)
	
	memset(page2kva(pp), 0x97, 128);
	first_free_page = (char *) boot_alloc(0);
f0100af9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100afe:	e8 51 fe ff ff       	call   f0100954 <boot_alloc>
f0100b03:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b06:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0c:	8b 0d 4c 79 11 f0    	mov    0xf011794c,%ecx
		assert(pp < pages + npages);
f0100b12:	a1 44 79 11 f0       	mov    0xf0117944,%eax
f0100b17:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b1a:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b1d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b20:	be 00 00 00 00       	mov    $0x0,%esi
f0100b25:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	
	if (PDX(page2pa(pp)) < pdx_limit)
	
	memset(page2kva(pp), 0x97, 128);
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b28:	e9 30 01 00 00       	jmp    f0100c5d <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b2d:	39 ca                	cmp    %ecx,%edx
f0100b2f:	73 19                	jae    f0100b4a <check_page_free_list+0x12b>
f0100b31:	68 ec 3c 10 f0       	push   $0xf0103cec
f0100b36:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100b3b:	68 64 02 00 00       	push   $0x264
f0100b40:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100b45:	e8 a1 f5 ff ff       	call   f01000eb <_panic>
		assert(pp < pages + npages);
f0100b4a:	39 fa                	cmp    %edi,%edx
f0100b4c:	72 19                	jb     f0100b67 <check_page_free_list+0x148>
f0100b4e:	68 0d 3d 10 f0       	push   $0xf0103d0d
f0100b53:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100b58:	68 65 02 00 00       	push   $0x265
f0100b5d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100b62:	e8 84 f5 ff ff       	call   f01000eb <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b67:	89 d0                	mov    %edx,%eax
f0100b69:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b6c:	a8 07                	test   $0x7,%al
f0100b6e:	74 19                	je     f0100b89 <check_page_free_list+0x16a>
f0100b70:	68 18 40 10 f0       	push   $0xf0104018
f0100b75:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100b7a:	68 66 02 00 00       	push   $0x266
f0100b7f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100b84:	e8 62 f5 ff ff       	call   f01000eb <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b89:	c1 f8 03             	sar    $0x3,%eax
f0100b8c:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b8f:	85 c0                	test   %eax,%eax
f0100b91:	75 19                	jne    f0100bac <check_page_free_list+0x18d>
f0100b93:	68 21 3d 10 f0       	push   $0xf0103d21
f0100b98:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100b9d:	68 69 02 00 00       	push   $0x269
f0100ba2:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100ba7:	e8 3f f5 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bac:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bb1:	75 19                	jne    f0100bcc <check_page_free_list+0x1ad>
f0100bb3:	68 32 3d 10 f0       	push   $0xf0103d32
f0100bb8:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100bbd:	68 6a 02 00 00       	push   $0x26a
f0100bc2:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100bc7:	e8 1f f5 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bcc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bd1:	75 19                	jne    f0100bec <check_page_free_list+0x1cd>
f0100bd3:	68 4c 40 10 f0       	push   $0xf010404c
f0100bd8:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100bdd:	68 6b 02 00 00       	push   $0x26b
f0100be2:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100be7:	e8 ff f4 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bec:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bf1:	75 19                	jne    f0100c0c <check_page_free_list+0x1ed>
f0100bf3:	68 4b 3d 10 f0       	push   $0xf0103d4b
f0100bf8:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100bfd:	68 6c 02 00 00       	push   $0x26c
f0100c02:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100c07:	e8 df f4 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c0c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c11:	76 3f                	jbe    f0100c52 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c13:	89 c3                	mov    %eax,%ebx
f0100c15:	c1 eb 0c             	shr    $0xc,%ebx
f0100c18:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c1b:	77 12                	ja     f0100c2f <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c1d:	50                   	push   %eax
f0100c1e:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100c23:	6a 52                	push   $0x52
f0100c25:	68 de 3c 10 f0       	push   $0xf0103cde
f0100c2a:	e8 bc f4 ff ff       	call   f01000eb <_panic>
f0100c2f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c34:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c37:	76 1e                	jbe    f0100c57 <check_page_free_list+0x238>
f0100c39:	68 70 40 10 f0       	push   $0xf0104070
f0100c3e:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100c43:	68 6d 02 00 00       	push   $0x26d
f0100c48:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100c4d:	e8 99 f4 ff ff       	call   f01000eb <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c52:	83 c6 01             	add    $0x1,%esi
f0100c55:	eb 04                	jmp    f0100c5b <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c57:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	
	if (PDX(page2pa(pp)) < pdx_limit)
	
	memset(page2kva(pp), 0x97, 128);
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5b:	8b 12                	mov    (%edx),%edx
f0100c5d:	85 d2                	test   %edx,%edx
f0100c5f:	0f 85 c8 fe ff ff    	jne    f0100b2d <check_page_free_list+0x10e>
f0100c65:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c68:	85 f6                	test   %esi,%esi
f0100c6a:	7f 19                	jg     f0100c85 <check_page_free_list+0x266>
f0100c6c:	68 65 3d 10 f0       	push   $0xf0103d65
f0100c71:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100c76:	68 75 02 00 00       	push   $0x275
f0100c7b:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100c80:	e8 66 f4 ff ff       	call   f01000eb <_panic>
	assert(nfree_extmem > 0);
f0100c85:	85 db                	test   %ebx,%ebx
f0100c87:	7f 42                	jg     f0100ccb <check_page_free_list+0x2ac>
f0100c89:	68 77 3d 10 f0       	push   $0xf0103d77
f0100c8e:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0100c93:	68 76 02 00 00       	push   $0x276
f0100c98:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100c9d:	e8 49 f4 ff ff       	call   f01000eb <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ca2:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100ca7:	85 c0                	test   %eax,%eax
f0100ca9:	0f 85 9d fd ff ff    	jne    f0100a4c <check_page_free_list+0x2d>
f0100caf:	e9 81 fd ff ff       	jmp    f0100a35 <check_page_free_list+0x16>
f0100cb4:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100cbb:	0f 84 74 fd ff ff    	je     f0100a35 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc1:	be 00 04 00 00       	mov    $0x400,%esi
f0100cc6:	e9 cf fd ff ff       	jmp    f0100a9a <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cce:	5b                   	pop    %ebx
f0100ccf:	5e                   	pop    %esi
f0100cd0:	5f                   	pop    %edi
f0100cd1:	5d                   	pop    %ebp
f0100cd2:	c3                   	ret    

f0100cd3 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cd3:	55                   	push   %ebp
f0100cd4:	89 e5                	mov    %esp,%ebp
f0100cd6:	53                   	push   %ebx
f0100cd7:	83 ec 04             	sub    $0x4,%esp
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list=NULL;
f0100cda:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0100ce1:	00 00 00 
	
	for (uint32_t i = 0 ; i < npages; i++) {
f0100ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ce9:	eb 5b                	jmp    f0100d46 <page_init+0x73>
		
		//cprintf("%u ",KERNBASE/PGSIZE);
		if(i==0 || ((i >= IOPHYSMEM/PGSIZE) && (i < ((uint32_t) boot_alloc(0)-KERNBASE)/PGSIZE)))
f0100ceb:	85 db                	test   %ebx,%ebx
f0100ced:	74 1e                	je     f0100d0d <page_init+0x3a>
f0100cef:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100cf5:	76 24                	jbe    f0100d1b <page_init+0x48>
f0100cf7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cfc:	e8 53 fc ff ff       	call   f0100954 <boot_alloc>
f0100d01:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d06:	c1 e8 0c             	shr    $0xc,%eax
f0100d09:	39 c3                	cmp    %eax,%ebx
f0100d0b:	73 0e                	jae    f0100d1b <page_init+0x48>
		{
			pages[i].pp_ref = 1;
f0100d0d:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0100d12:	66 c7 44 d8 04 01 00 	movw   $0x1,0x4(%eax,%ebx,8)
			continue;
f0100d19:	eb 28                	jmp    f0100d43 <page_init+0x70>
f0100d1b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
		}
		else
		{
		 //cprintf("%x \n",&pages);
		 pages[i].pp_ref = 0;
f0100d22:	89 c2                	mov    %eax,%edx
f0100d24:	03 15 4c 79 11 f0    	add    0xf011794c,%edx
f0100d2a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		 pages[i].pp_link = page_free_list;
f0100d30:	8b 0d 3c 75 11 f0    	mov    0xf011753c,%ecx
f0100d36:	89 0a                	mov    %ecx,(%edx)
		 page_free_list = &pages[i];
f0100d38:	03 05 4c 79 11 f0    	add    0xf011794c,%eax
f0100d3e:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list=NULL;
	
	for (uint32_t i = 0 ; i < npages; i++) {
f0100d43:	83 c3 01             	add    $0x1,%ebx
f0100d46:	3b 1d 44 79 11 f0    	cmp    0xf0117944,%ebx
f0100d4c:	72 9d                	jb     f0100ceb <page_init+0x18>
		 pages[i].pp_ref = 0;
		 pages[i].pp_link = page_free_list;
		 page_free_list = &pages[i];
	    }
	}
}
f0100d4e:	83 c4 04             	add    $0x4,%esp
f0100d51:	5b                   	pop    %ebx
f0100d52:	5d                   	pop    %ebp
f0100d53:	c3                   	ret    

f0100d54 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d54:	55                   	push   %ebp
f0100d55:	89 e5                	mov    %esp,%ebp
f0100d57:	53                   	push   %ebx
f0100d58:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *pp;
	
	if( page_free_list == NULL ) 
f0100d5b:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100d61:	85 db                	test   %ebx,%ebx
f0100d63:	74 58                	je     f0100dbd <page_alloc+0x69>
	return NULL;
	
	pp = page_free_list;
	page_free_list = pp->pp_link;
f0100d65:	8b 03                	mov    (%ebx),%eax
f0100d67:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
    pp->pp_link = NULL;
f0100d6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	
	//cprintf("pp= %x page_free= %x phys");
	
	if (alloc_flags & ALLOC_ZERO)
f0100d72:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d76:	74 45                	je     f0100dbd <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d78:	89 d8                	mov    %ebx,%eax
f0100d7a:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0100d80:	c1 f8 03             	sar    $0x3,%eax
f0100d83:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d86:	89 c2                	mov    %eax,%edx
f0100d88:	c1 ea 0c             	shr    $0xc,%edx
f0100d8b:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0100d91:	72 12                	jb     f0100da5 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d93:	50                   	push   %eax
f0100d94:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100d99:	6a 52                	push   $0x52
f0100d9b:	68 de 3c 10 f0       	push   $0xf0103cde
f0100da0:	e8 46 f3 ff ff       	call   f01000eb <_panic>
	{
		memset(page2kva(pp), 0, PGSIZE);
f0100da5:	83 ec 04             	sub    $0x4,%esp
f0100da8:	68 00 10 00 00       	push   $0x1000
f0100dad:	6a 00                	push   $0x0
f0100daf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100db4:	50                   	push   %eax
f0100db5:	e8 33 25 00 00       	call   f01032ed <memset>
f0100dba:	83 c4 10             	add    $0x10,%esp
	}
	// Fill this function in
	return pp;
}
f0100dbd:	89 d8                	mov    %ebx,%eax
f0100dbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100dc2:	c9                   	leave  
f0100dc3:	c3                   	ret    

f0100dc4 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100dc4:	55                   	push   %ebp
f0100dc5:	89 e5                	mov    %esp,%ebp
f0100dc7:	83 ec 08             	sub    $0x8,%esp
f0100dca:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	
	if(pp->pp_ref != 0 || pp->pp_link != NULL)
f0100dcd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100dd2:	75 05                	jne    f0100dd9 <page_free+0x15>
f0100dd4:	83 38 00             	cmpl   $0x0,(%eax)
f0100dd7:	74 17                	je     f0100df0 <page_free+0x2c>
	panic("Physical Page is non empty");
f0100dd9:	83 ec 04             	sub    $0x4,%esp
f0100ddc:	68 88 3d 10 f0       	push   $0xf0103d88
f0100de1:	68 5b 01 00 00       	push   $0x15b
f0100de6:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100deb:	e8 fb f2 ff ff       	call   f01000eb <_panic>
    
    else
    {
		pp->pp_link = page_free_list;
f0100df0:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100df6:	89 10                	mov    %edx,(%eax)
        page_free_list=pp;
f0100df8:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dfd:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0100e03:	c1 f8 03             	sar    $0x3,%eax
f0100e06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e09:	89 c2                	mov    %eax,%edx
f0100e0b:	c1 ea 0c             	shr    $0xc,%edx
f0100e0e:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0100e14:	72 12                	jb     f0100e28 <page_free+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e16:	50                   	push   %eax
f0100e17:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100e1c:	6a 52                	push   $0x52
f0100e1e:	68 de 3c 10 f0       	push   $0xf0103cde
f0100e23:	e8 c3 f2 ff ff       	call   f01000eb <_panic>
        memset(page2kva(pp), 0, PGSIZE);
f0100e28:	83 ec 04             	sub    $0x4,%esp
f0100e2b:	68 00 10 00 00       	push   $0x1000
f0100e30:	6a 00                	push   $0x0
f0100e32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e37:	50                   	push   %eax
f0100e38:	e8 b0 24 00 00       	call   f01032ed <memset>
	}	
}
f0100e3d:	83 c4 10             	add    $0x10,%esp
f0100e40:	c9                   	leave  
f0100e41:	c3                   	ret    

f0100e42 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e42:	55                   	push   %ebp
f0100e43:	89 e5                	mov    %esp,%ebp
f0100e45:	83 ec 08             	sub    $0x8,%esp
f0100e48:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e4b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e4f:	83 e8 01             	sub    $0x1,%eax
f0100e52:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e56:	66 85 c0             	test   %ax,%ax
f0100e59:	75 0c                	jne    f0100e67 <page_decref+0x25>
		page_free(pp);
f0100e5b:	83 ec 0c             	sub    $0xc,%esp
f0100e5e:	52                   	push   %edx
f0100e5f:	e8 60 ff ff ff       	call   f0100dc4 <page_free>
f0100e64:	83 c4 10             	add    $0x10,%esp
}
f0100e67:	c9                   	leave  
f0100e68:	c3                   	ret    

f0100e69 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e69:	55                   	push   %ebp
f0100e6a:	89 e5                	mov    %esp,%ebp
f0100e6c:	57                   	push   %edi
f0100e6d:	56                   	push   %esi
f0100e6e:	53                   	push   %ebx
f0100e6f:	83 ec 0c             	sub    $0xc,%esp
f0100e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
      pde_t * pde; //va(virtual address) point to pa(physical address)
      pte_t * pgtable; //same as pde
      struct PageInfo *pp;

      pde = &pgdir[PDX(va)]; // va->pgdir
f0100e75:	89 de                	mov    %ebx,%esi
f0100e77:	c1 ee 16             	shr    $0x16,%esi
f0100e7a:	c1 e6 02             	shl    $0x2,%esi
f0100e7d:	03 75 08             	add    0x8(%ebp),%esi
      if(*pde & PTE_P) {
f0100e80:	8b 06                	mov    (%esi),%eax
f0100e82:	a8 01                	test   $0x1,%al
f0100e84:	74 2f                	je     f0100eb5 <pgdir_walk+0x4c>
          pgtable = (KADDR(PTE_ADDR(*pde)));
f0100e86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e8b:	89 c2                	mov    %eax,%edx
f0100e8d:	c1 ea 0c             	shr    $0xc,%edx
f0100e90:	39 15 44 79 11 f0    	cmp    %edx,0xf0117944
f0100e96:	77 15                	ja     f0100ead <pgdir_walk+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e98:	50                   	push   %eax
f0100e99:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100e9e:	68 8f 01 00 00       	push   $0x18f
f0100ea3:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100ea8:	e8 3e f2 ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f0100ead:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100eb3:	eb 77                	jmp    f0100f2c <pgdir_walk+0xc3>
      } else {
        //page table page not exist
        if(!create ||
f0100eb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100eb9:	74 7f                	je     f0100f3a <pgdir_walk+0xd1>
f0100ebb:	83 ec 0c             	sub    $0xc,%esp
f0100ebe:	6a 01                	push   $0x1
f0100ec0:	e8 8f fe ff ff       	call   f0100d54 <page_alloc>
f0100ec5:	83 c4 10             	add    $0x10,%esp
f0100ec8:	85 c0                	test   %eax,%eax
f0100eca:	74 75                	je     f0100f41 <pgdir_walk+0xd8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ecc:	89 c1                	mov    %eax,%ecx
f0100ece:	2b 0d 4c 79 11 f0    	sub    0xf011794c,%ecx
f0100ed4:	c1 f9 03             	sar    $0x3,%ecx
f0100ed7:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eda:	89 ca                	mov    %ecx,%edx
f0100edc:	c1 ea 0c             	shr    $0xc,%edx
f0100edf:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0100ee5:	72 12                	jb     f0100ef9 <pgdir_walk+0x90>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee7:	51                   	push   %ecx
f0100ee8:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100eed:	6a 52                	push   $0x52
f0100eef:	68 de 3c 10 f0       	push   $0xf0103cde
f0100ef4:	e8 f2 f1 ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f0100ef9:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0100eff:	89 fa                	mov    %edi,%edx
           !(pp = page_alloc(ALLOC_ZERO)) ||
f0100f01:	85 ff                	test   %edi,%edi
f0100f03:	74 43                	je     f0100f48 <pgdir_walk+0xdf>
           !(pgtable = (pte_t*)page2kva(pp)))
            return NULL;
           
        pp->pp_ref++;
f0100f05:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f0a:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100f10:	77 15                	ja     f0100f27 <pgdir_walk+0xbe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f12:	57                   	push   %edi
f0100f13:	68 b8 40 10 f0       	push   $0xf01040b8
f0100f18:	68 98 01 00 00       	push   $0x198
f0100f1d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0100f22:	e8 c4 f1 ff ff       	call   f01000eb <_panic>
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
f0100f27:	83 c9 07             	or     $0x7,%ecx
f0100f2a:	89 0e                	mov    %ecx,(%esi)
    }

    return &pgtable[PTX(va)];
f0100f2c:	c1 eb 0a             	shr    $0xa,%ebx
f0100f2f:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f35:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100f38:	eb 13                	jmp    f0100f4d <pgdir_walk+0xe4>
      } else {
        //page table page not exist
        if(!create ||
           !(pp = page_alloc(ALLOC_ZERO)) ||
           !(pgtable = (pte_t*)page2kva(pp)))
            return NULL;
f0100f3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f3f:	eb 0c                	jmp    f0100f4d <pgdir_walk+0xe4>
f0100f41:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f46:	eb 05                	jmp    f0100f4d <pgdir_walk+0xe4>
f0100f48:	b8 00 00 00 00       	mov    $0x0,%eax
        pp->pp_ref++;
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
    }

    return &pgtable[PTX(va)];
}
f0100f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f50:	5b                   	pop    %ebx
f0100f51:	5e                   	pop    %esi
f0100f52:	5f                   	pop    %edi
f0100f53:	5d                   	pop    %ebp
f0100f54:	c3                   	ret    

f0100f55 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f55:	55                   	push   %ebp
f0100f56:	89 e5                	mov    %esp,%ebp
f0100f58:	57                   	push   %edi
f0100f59:	56                   	push   %esi
f0100f5a:	53                   	push   %ebx
f0100f5b:	83 ec 1c             	sub    $0x1c,%esp
f0100f5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	//for (uint32_t i=0; i < size ; i=i+PGSIZE)
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
f0100f61:	c1 e9 0c             	shr    $0xc,%ecx
f0100f64:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	
	while(i<x)
f0100f67:	89 d6                	mov    %edx,%esi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	//for (uint32_t i=0; i < size ; i=i+PGSIZE)
	
	uint32_t i=0, x=0;
f0100f69:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f71:	29 d0                	sub    %edx,%eax
f0100f73:	89 45 e0             	mov    %eax,-0x20(%ebp)
	x=size/(PGSIZE);
	
	while(i<x)
	{
		pte_t *PTE = pgdir_walk(pgdir,(void *)va,1);
		*PTE = (PTE_ADDR(pa)) | perm | PTE_P;
f0100f76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f79:	83 c8 01             	or     $0x1,%eax
f0100f7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
	
	while(i<x)
f0100f7f:	eb 25                	jmp    f0100fa6 <boot_map_region+0x51>
	{
		pte_t *PTE = pgdir_walk(pgdir,(void *)va,1);
f0100f81:	83 ec 04             	sub    $0x4,%esp
f0100f84:	6a 01                	push   $0x1
f0100f86:	56                   	push   %esi
f0100f87:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f8a:	e8 da fe ff ff       	call   f0100e69 <pgdir_walk>
		*PTE = (PTE_ADDR(pa)) | perm | PTE_P;
f0100f8f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100f95:	0b 5d d8             	or     -0x28(%ebp),%ebx
f0100f98:	89 18                	mov    %ebx,(%eax)
		va=va+PGSIZE;
f0100f9a:	81 c6 00 10 00 00    	add    $0x1000,%esi
		pa=pa+PGSIZE;
		i++;
f0100fa0:	83 c7 01             	add    $0x1,%edi
f0100fa3:	83 c4 10             	add    $0x10,%esp
f0100fa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa9:	8d 1c 30             	lea    (%eax,%esi,1),%ebx
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
	
	while(i<x)
f0100fac:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100faf:	75 d0                	jne    f0100f81 <boot_map_region+0x2c>
		va=va+PGSIZE;
		pa=pa+PGSIZE;
		i++;
	}
	
}
f0100fb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fb4:	5b                   	pop    %ebx
f0100fb5:	5e                   	pop    %esi
f0100fb6:	5f                   	pop    %edi
f0100fb7:	5d                   	pop    %ebp
f0100fb8:	c3                   	ret    

f0100fb9 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fb9:	55                   	push   %ebp
f0100fba:	89 e5                	mov    %esp,%ebp
f0100fbc:	83 ec 0c             	sub    $0xc,%esp
	// Fill this function in
	struct PageInfo *PP=NULL;
	
	pte_t *PTE = pgdir_walk(pgdir,va,0);
f0100fbf:	6a 00                	push   $0x0
f0100fc1:	ff 75 0c             	pushl  0xc(%ebp)
f0100fc4:	ff 75 08             	pushl  0x8(%ebp)
f0100fc7:	e8 9d fe ff ff       	call   f0100e69 <pgdir_walk>
	
	if(PTE == NULL)
f0100fcc:	83 c4 10             	add    $0x10,%esp
f0100fcf:	85 c0                	test   %eax,%eax
f0100fd1:	74 32                	je     f0101005 <page_lookup+0x4c>
f0100fd3:	89 c1                	mov    %eax,%ecx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd5:	8b 10                	mov    (%eax),%edx
f0100fd7:	c1 ea 0c             	shr    $0xc,%edx
f0100fda:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0100fe0:	72 14                	jb     f0100ff6 <page_lookup+0x3d>
		panic("pa2page called with invalid pa");
f0100fe2:	83 ec 04             	sub    $0x4,%esp
f0100fe5:	68 dc 40 10 f0       	push   $0xf01040dc
f0100fea:	6a 4b                	push   $0x4b
f0100fec:	68 de 3c 10 f0       	push   $0xf0103cde
f0100ff1:	e8 f5 f0 ff ff       	call   f01000eb <_panic>
	return &pages[PGNUM(pa)];
f0100ff6:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0100ffb:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	}
	
	PP=pa2page(PTE_ADDR(*PTE));
	
	*pte_store=PTE;
f0100ffe:	8b 55 10             	mov    0x10(%ebp),%edx
f0101001:	89 0a                	mov    %ecx,(%edx)
	
	return PP;
f0101003:	eb 05                	jmp    f010100a <page_lookup+0x51>
	
	pte_t *PTE = pgdir_walk(pgdir,va,0);
	
	if(PTE == NULL)
	{
		return NULL;
f0101005:	b8 00 00 00 00       	mov    $0x0,%eax
	PP=pa2page(PTE_ADDR(*PTE));
	
	*pte_store=PTE;
	
	return PP;
}
f010100a:	c9                   	leave  
f010100b:	c3                   	ret    

f010100c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
//     tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010100c:	55                   	push   %ebp
f010100d:	89 e5                	mov    %esp,%ebp
f010100f:	53                   	push   %ebx
f0101010:	83 ec 18             	sub    $0x18,%esp
f0101013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo *PP=page_lookup(pgdir,va,&pte_store);
f0101016:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101019:	50                   	push   %eax
f010101a:	53                   	push   %ebx
f010101b:	ff 75 08             	pushl  0x8(%ebp)
f010101e:	e8 96 ff ff ff       	call   f0100fb9 <page_lookup>
	
	if(PP == NULL)
f0101023:	83 c4 10             	add    $0x10,%esp
f0101026:	85 c0                	test   %eax,%eax
f0101028:	74 18                	je     f0101042 <page_remove+0x36>
	{
		return;
	}
		page_decref(PP);
f010102a:	83 ec 0c             	sub    $0xc,%esp
f010102d:	50                   	push   %eax
f010102e:	e8 0f fe ff ff       	call   f0100e42 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101033:	0f 01 3b             	invlpg (%ebx)
		tlb_invalidate(pgdir, va);
	*pte_store=0;
f0101036:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101039:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010103f:	83 c4 10             	add    $0x10,%esp
}
f0101042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101045:	c9                   	leave  
f0101046:	c3                   	ret    

f0101047 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101047:	55                   	push   %ebp
f0101048:	89 e5                	mov    %esp,%ebp
f010104a:	57                   	push   %edi
f010104b:	56                   	push   %esi
f010104c:	53                   	push   %ebx
f010104d:	83 ec 10             	sub    $0x10,%esp
f0101050:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101053:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101056:	6a 01                	push   $0x1
f0101058:	57                   	push   %edi
f0101059:	ff 75 08             	pushl  0x8(%ebp)
f010105c:	e8 08 fe ff ff       	call   f0100e69 <pgdir_walk>
 

    if (pte != NULL) {
f0101061:	83 c4 10             	add    $0x10,%esp
f0101064:	85 c0                	test   %eax,%eax
f0101066:	74 4a                	je     f01010b2 <page_insert+0x6b>
f0101068:	89 c3                	mov    %eax,%ebx
     
        if (*pte & PTE_P)
f010106a:	f6 00 01             	testb  $0x1,(%eax)
f010106d:	74 0f                	je     f010107e <page_insert+0x37>
            page_remove(pgdir, va);
f010106f:	83 ec 08             	sub    $0x8,%esp
f0101072:	57                   	push   %edi
f0101073:	ff 75 08             	pushl  0x8(%ebp)
f0101076:	e8 91 ff ff ff       	call   f010100c <page_remove>
f010107b:	83 c4 10             	add    $0x10,%esp
        if (page_free_list == pp)
f010107e:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101083:	39 f0                	cmp    %esi,%eax
f0101085:	75 07                	jne    f010108e <page_insert+0x47>
            page_free_list = page_free_list->pp_link;
f0101087:	8b 00                	mov    (%eax),%eax
f0101089:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
    }
    else {
            return -E_NO_MEM;
    }
    *pte = page2pa(pp) | perm | PTE_P;
f010108e:	89 f0                	mov    %esi,%eax
f0101090:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101096:	c1 f8 03             	sar    $0x3,%eax
f0101099:	c1 e0 0c             	shl    $0xc,%eax
f010109c:	8b 55 14             	mov    0x14(%ebp),%edx
f010109f:	83 ca 01             	or     $0x1,%edx
f01010a2:	09 d0                	or     %edx,%eax
f01010a4:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++;
f01010a6:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

    return 0;
f01010ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b0:	eb 05                	jmp    f01010b7 <page_insert+0x70>
            page_remove(pgdir, va);
        if (page_free_list == pp)
            page_free_list = page_free_list->pp_link;
    }
    else {
            return -E_NO_MEM;
f01010b2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    }
    *pte = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;

    return 0;
}
f01010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010ba:	5b                   	pop    %ebx
f01010bb:	5e                   	pop    %esi
f01010bc:	5f                   	pop    %edi
f01010bd:	5d                   	pop    %ebp
f01010be:	c3                   	ret    

f01010bf <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010bf:	55                   	push   %ebp
f01010c0:	89 e5                	mov    %esp,%ebp
f01010c2:	57                   	push   %edi
f01010c3:	56                   	push   %esi
f01010c4:	53                   	push   %ebx
f01010c5:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01010c8:	b8 15 00 00 00       	mov    $0x15,%eax
f01010cd:	e8 59 f8 ff ff       	call   f010092b <nvram_read>
f01010d2:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01010d4:	b8 17 00 00 00       	mov    $0x17,%eax
f01010d9:	e8 4d f8 ff ff       	call   f010092b <nvram_read>
f01010de:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01010e0:	b8 34 00 00 00       	mov    $0x34,%eax
f01010e5:	e8 41 f8 ff ff       	call   f010092b <nvram_read>
f01010ea:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f01010ed:	8d 98 00 40 00 00    	lea    0x4000(%eax),%ebx
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01010f3:	85 c0                	test   %eax,%eax
f01010f5:	75 0b                	jne    f0101102 <mem_init+0x43>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01010f7:	8d 9f 00 04 00 00    	lea    0x400(%edi),%ebx
f01010fd:	85 ff                	test   %edi,%edi
f01010ff:	0f 44 de             	cmove  %esi,%ebx
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101102:	89 da                	mov    %ebx,%edx
f0101104:	c1 ea 02             	shr    $0x2,%edx
f0101107:	89 15 44 79 11 f0    	mov    %edx,0xf0117944
	npages_basemem = basemem / (PGSIZE / 1024);
    cprintf("\n npages = %u  npages_basemem = %u extmem = %d ext16mem = %d\n", npages,npages_basemem,extmem,ext16mem);
f010110d:	83 ec 0c             	sub    $0xc,%esp
f0101110:	50                   	push   %eax
f0101111:	57                   	push   %edi
f0101112:	89 f0                	mov    %esi,%eax
f0101114:	c1 e8 02             	shr    $0x2,%eax
f0101117:	50                   	push   %eax
f0101118:	52                   	push   %edx
f0101119:	68 fc 40 10 f0       	push   $0xf01040fc
f010111e:	e8 7a 16 00 00       	call   f010279d <cprintf>
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101123:	83 c4 20             	add    $0x20,%esp
f0101126:	89 d8                	mov    %ebx,%eax
f0101128:	29 f0                	sub    %esi,%eax
f010112a:	50                   	push   %eax
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	68 3c 41 10 f0       	push   $0xf010413c
f0101132:	e8 66 16 00 00       	call   f010279d <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101137:	b8 00 10 00 00       	mov    $0x1000,%eax
f010113c:	e8 13 f8 ff ff       	call   f0100954 <boot_alloc>
f0101141:	a3 48 79 11 f0       	mov    %eax,0xf0117948
	memset(kern_pgdir, 0, PGSIZE);
f0101146:	83 c4 0c             	add    $0xc,%esp
f0101149:	68 00 10 00 00       	push   $0x1000
f010114e:	6a 00                	push   $0x0
f0101150:	50                   	push   %eax
f0101151:	e8 97 21 00 00       	call   f01032ed <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101156:	a1 48 79 11 f0       	mov    0xf0117948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010115b:	83 c4 10             	add    $0x10,%esp
f010115e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101163:	77 15                	ja     f010117a <mem_init+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101165:	50                   	push   %eax
f0101166:	68 b8 40 10 f0       	push   $0xf01040b8
f010116b:	68 9a 00 00 00       	push   $0x9a
f0101170:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101175:	e8 71 ef ff ff       	call   f01000eb <_panic>
f010117a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101180:	83 ca 05             	or     $0x5,%edx
f0101183:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101189:	a1 44 79 11 f0       	mov    0xf0117944,%eax
f010118e:	c1 e0 03             	shl    $0x3,%eax
f0101191:	e8 be f7 ff ff       	call   f0100954 <boot_alloc>
f0101196:	a3 4c 79 11 f0       	mov    %eax,0xf011794c
    size_t i;
    for (i = 0; i < npages ; i++) {
f010119b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011a0:	eb 2d                	jmp    f01011cf <mem_init+0x110>
		pages[i].pp_link = NULL;
f01011a2:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01011a7:	c7 04 d8 00 00 00 00 	movl   $0x0,(%eax,%ebx,8)
		pages[i].pp_ref = 0;
f01011ae:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01011b3:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f01011b6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		memset(&pages[i], 0, sizeof(struct PageInfo));
f01011bc:	83 ec 04             	sub    $0x4,%esp
f01011bf:	6a 08                	push   $0x8
f01011c1:	6a 00                	push   $0x0
f01011c3:	50                   	push   %eax
f01011c4:	e8 24 21 00 00       	call   f01032ed <memset>
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
    size_t i;
    for (i = 0; i < npages ; i++) {
f01011c9:	83 c3 01             	add    $0x1,%ebx
f01011cc:	83 c4 10             	add    $0x10,%esp
f01011cf:	3b 1d 44 79 11 f0    	cmp    0xf0117944,%ebx
f01011d5:	72 cb                	jb     f01011a2 <mem_init+0xe3>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01011d7:	e8 f7 fa ff ff       	call   f0100cd3 <page_init>
	check_page_free_list(1);
f01011dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01011e1:	e8 39 f8 ff ff       	call   f0100a1f <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01011e6:	83 3d 4c 79 11 f0 00 	cmpl   $0x0,0xf011794c
f01011ed:	75 17                	jne    f0101206 <mem_init+0x147>
		panic("'pages' is a null pointer!");
f01011ef:	83 ec 04             	sub    $0x4,%esp
f01011f2:	68 a3 3d 10 f0       	push   $0xf0103da3
f01011f7:	68 87 02 00 00       	push   $0x287
f01011fc:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101201:	e8 e5 ee ff ff       	call   f01000eb <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101206:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010120b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101210:	eb 05                	jmp    f0101217 <mem_init+0x158>
		++nfree;
f0101212:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101215:	8b 00                	mov    (%eax),%eax
f0101217:	85 c0                	test   %eax,%eax
f0101219:	75 f7                	jne    f0101212 <mem_init+0x153>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010121b:	83 ec 0c             	sub    $0xc,%esp
f010121e:	6a 00                	push   $0x0
f0101220:	e8 2f fb ff ff       	call   f0100d54 <page_alloc>
f0101225:	89 c7                	mov    %eax,%edi
f0101227:	83 c4 10             	add    $0x10,%esp
f010122a:	85 c0                	test   %eax,%eax
f010122c:	75 19                	jne    f0101247 <mem_init+0x188>
f010122e:	68 be 3d 10 f0       	push   $0xf0103dbe
f0101233:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101238:	68 8f 02 00 00       	push   $0x28f
f010123d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101242:	e8 a4 ee ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f0101247:	83 ec 0c             	sub    $0xc,%esp
f010124a:	6a 00                	push   $0x0
f010124c:	e8 03 fb ff ff       	call   f0100d54 <page_alloc>
f0101251:	89 c6                	mov    %eax,%esi
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	85 c0                	test   %eax,%eax
f0101258:	75 19                	jne    f0101273 <mem_init+0x1b4>
f010125a:	68 d4 3d 10 f0       	push   $0xf0103dd4
f010125f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101264:	68 90 02 00 00       	push   $0x290
f0101269:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010126e:	e8 78 ee ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f0101273:	83 ec 0c             	sub    $0xc,%esp
f0101276:	6a 00                	push   $0x0
f0101278:	e8 d7 fa ff ff       	call   f0100d54 <page_alloc>
f010127d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101280:	83 c4 10             	add    $0x10,%esp
f0101283:	85 c0                	test   %eax,%eax
f0101285:	75 19                	jne    f01012a0 <mem_init+0x1e1>
f0101287:	68 ea 3d 10 f0       	push   $0xf0103dea
f010128c:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101291:	68 91 02 00 00       	push   $0x291
f0101296:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010129b:	e8 4b ee ff ff       	call   f01000eb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012a0:	39 f7                	cmp    %esi,%edi
f01012a2:	75 19                	jne    f01012bd <mem_init+0x1fe>
f01012a4:	68 00 3e 10 f0       	push   $0xf0103e00
f01012a9:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01012ae:	68 94 02 00 00       	push   $0x294
f01012b3:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01012b8:	e8 2e ee ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012c0:	39 c6                	cmp    %eax,%esi
f01012c2:	74 04                	je     f01012c8 <mem_init+0x209>
f01012c4:	39 c7                	cmp    %eax,%edi
f01012c6:	75 19                	jne    f01012e1 <mem_init+0x222>
f01012c8:	68 78 41 10 f0       	push   $0xf0104178
f01012cd:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01012d2:	68 95 02 00 00       	push   $0x295
f01012d7:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01012dc:	e8 0a ee ff ff       	call   f01000eb <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012e1:	8b 0d 4c 79 11 f0    	mov    0xf011794c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01012e7:	8b 15 44 79 11 f0    	mov    0xf0117944,%edx
f01012ed:	c1 e2 0c             	shl    $0xc,%edx
f01012f0:	89 f8                	mov    %edi,%eax
f01012f2:	29 c8                	sub    %ecx,%eax
f01012f4:	c1 f8 03             	sar    $0x3,%eax
f01012f7:	c1 e0 0c             	shl    $0xc,%eax
f01012fa:	39 d0                	cmp    %edx,%eax
f01012fc:	72 19                	jb     f0101317 <mem_init+0x258>
f01012fe:	68 12 3e 10 f0       	push   $0xf0103e12
f0101303:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101308:	68 96 02 00 00       	push   $0x296
f010130d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101312:	e8 d4 ed ff ff       	call   f01000eb <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101317:	89 f0                	mov    %esi,%eax
f0101319:	29 c8                	sub    %ecx,%eax
f010131b:	c1 f8 03             	sar    $0x3,%eax
f010131e:	c1 e0 0c             	shl    $0xc,%eax
f0101321:	39 c2                	cmp    %eax,%edx
f0101323:	77 19                	ja     f010133e <mem_init+0x27f>
f0101325:	68 2f 3e 10 f0       	push   $0xf0103e2f
f010132a:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010132f:	68 97 02 00 00       	push   $0x297
f0101334:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101339:	e8 ad ed ff ff       	call   f01000eb <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010133e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101341:	29 c8                	sub    %ecx,%eax
f0101343:	c1 f8 03             	sar    $0x3,%eax
f0101346:	c1 e0 0c             	shl    $0xc,%eax
f0101349:	39 c2                	cmp    %eax,%edx
f010134b:	77 19                	ja     f0101366 <mem_init+0x2a7>
f010134d:	68 4c 3e 10 f0       	push   $0xf0103e4c
f0101352:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101357:	68 98 02 00 00       	push   $0x298
f010135c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101361:	e8 85 ed ff ff       	call   f01000eb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101366:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010136b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010136e:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101375:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101378:	83 ec 0c             	sub    $0xc,%esp
f010137b:	6a 00                	push   $0x0
f010137d:	e8 d2 f9 ff ff       	call   f0100d54 <page_alloc>
f0101382:	83 c4 10             	add    $0x10,%esp
f0101385:	85 c0                	test   %eax,%eax
f0101387:	74 19                	je     f01013a2 <mem_init+0x2e3>
f0101389:	68 69 3e 10 f0       	push   $0xf0103e69
f010138e:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101393:	68 9f 02 00 00       	push   $0x29f
f0101398:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010139d:	e8 49 ed ff ff       	call   f01000eb <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013a2:	83 ec 0c             	sub    $0xc,%esp
f01013a5:	57                   	push   %edi
f01013a6:	e8 19 fa ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f01013ab:	89 34 24             	mov    %esi,(%esp)
f01013ae:	e8 11 fa ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f01013b3:	83 c4 04             	add    $0x4,%esp
f01013b6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013b9:	e8 06 fa ff ff       	call   f0100dc4 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013c5:	e8 8a f9 ff ff       	call   f0100d54 <page_alloc>
f01013ca:	89 c6                	mov    %eax,%esi
f01013cc:	83 c4 10             	add    $0x10,%esp
f01013cf:	85 c0                	test   %eax,%eax
f01013d1:	75 19                	jne    f01013ec <mem_init+0x32d>
f01013d3:	68 be 3d 10 f0       	push   $0xf0103dbe
f01013d8:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01013dd:	68 a6 02 00 00       	push   $0x2a6
f01013e2:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01013e7:	e8 ff ec ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f01013ec:	83 ec 0c             	sub    $0xc,%esp
f01013ef:	6a 00                	push   $0x0
f01013f1:	e8 5e f9 ff ff       	call   f0100d54 <page_alloc>
f01013f6:	89 c7                	mov    %eax,%edi
f01013f8:	83 c4 10             	add    $0x10,%esp
f01013fb:	85 c0                	test   %eax,%eax
f01013fd:	75 19                	jne    f0101418 <mem_init+0x359>
f01013ff:	68 d4 3d 10 f0       	push   $0xf0103dd4
f0101404:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101409:	68 a7 02 00 00       	push   $0x2a7
f010140e:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101413:	e8 d3 ec ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f0101418:	83 ec 0c             	sub    $0xc,%esp
f010141b:	6a 00                	push   $0x0
f010141d:	e8 32 f9 ff ff       	call   f0100d54 <page_alloc>
f0101422:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101425:	83 c4 10             	add    $0x10,%esp
f0101428:	85 c0                	test   %eax,%eax
f010142a:	75 19                	jne    f0101445 <mem_init+0x386>
f010142c:	68 ea 3d 10 f0       	push   $0xf0103dea
f0101431:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101436:	68 a8 02 00 00       	push   $0x2a8
f010143b:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101440:	e8 a6 ec ff ff       	call   f01000eb <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101445:	39 fe                	cmp    %edi,%esi
f0101447:	75 19                	jne    f0101462 <mem_init+0x3a3>
f0101449:	68 00 3e 10 f0       	push   $0xf0103e00
f010144e:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101453:	68 aa 02 00 00       	push   $0x2aa
f0101458:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010145d:	e8 89 ec ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101462:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101465:	39 c7                	cmp    %eax,%edi
f0101467:	74 04                	je     f010146d <mem_init+0x3ae>
f0101469:	39 c6                	cmp    %eax,%esi
f010146b:	75 19                	jne    f0101486 <mem_init+0x3c7>
f010146d:	68 78 41 10 f0       	push   $0xf0104178
f0101472:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101477:	68 ab 02 00 00       	push   $0x2ab
f010147c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101481:	e8 65 ec ff ff       	call   f01000eb <_panic>
	assert(!page_alloc(0));
f0101486:	83 ec 0c             	sub    $0xc,%esp
f0101489:	6a 00                	push   $0x0
f010148b:	e8 c4 f8 ff ff       	call   f0100d54 <page_alloc>
f0101490:	83 c4 10             	add    $0x10,%esp
f0101493:	85 c0                	test   %eax,%eax
f0101495:	74 19                	je     f01014b0 <mem_init+0x3f1>
f0101497:	68 69 3e 10 f0       	push   $0xf0103e69
f010149c:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01014a1:	68 ac 02 00 00       	push   $0x2ac
f01014a6:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01014ab:	e8 3b ec ff ff       	call   f01000eb <_panic>
f01014b0:	89 f0                	mov    %esi,%eax
f01014b2:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01014b8:	c1 f8 03             	sar    $0x3,%eax
f01014bb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014be:	89 c2                	mov    %eax,%edx
f01014c0:	c1 ea 0c             	shr    $0xc,%edx
f01014c3:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f01014c9:	72 12                	jb     f01014dd <mem_init+0x41e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014cb:	50                   	push   %eax
f01014cc:	68 d0 3f 10 f0       	push   $0xf0103fd0
f01014d1:	6a 52                	push   $0x52
f01014d3:	68 de 3c 10 f0       	push   $0xf0103cde
f01014d8:	e8 0e ec ff ff       	call   f01000eb <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01014dd:	83 ec 04             	sub    $0x4,%esp
f01014e0:	68 00 10 00 00       	push   $0x1000
f01014e5:	6a 01                	push   $0x1
f01014e7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014ec:	50                   	push   %eax
f01014ed:	e8 fb 1d 00 00       	call   f01032ed <memset>
	page_free(pp0);
f01014f2:	89 34 24             	mov    %esi,(%esp)
f01014f5:	e8 ca f8 ff ff       	call   f0100dc4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01014fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101501:	e8 4e f8 ff ff       	call   f0100d54 <page_alloc>
f0101506:	83 c4 10             	add    $0x10,%esp
f0101509:	85 c0                	test   %eax,%eax
f010150b:	75 19                	jne    f0101526 <mem_init+0x467>
f010150d:	68 78 3e 10 f0       	push   $0xf0103e78
f0101512:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101517:	68 b1 02 00 00       	push   $0x2b1
f010151c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101521:	e8 c5 eb ff ff       	call   f01000eb <_panic>
	assert(pp && pp0 == pp);
f0101526:	39 c6                	cmp    %eax,%esi
f0101528:	74 19                	je     f0101543 <mem_init+0x484>
f010152a:	68 96 3e 10 f0       	push   $0xf0103e96
f010152f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101534:	68 b2 02 00 00       	push   $0x2b2
f0101539:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010153e:	e8 a8 eb ff ff       	call   f01000eb <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101543:	89 f0                	mov    %esi,%eax
f0101545:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f010154b:	c1 f8 03             	sar    $0x3,%eax
f010154e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101551:	89 c2                	mov    %eax,%edx
f0101553:	c1 ea 0c             	shr    $0xc,%edx
f0101556:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f010155c:	72 12                	jb     f0101570 <mem_init+0x4b1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010155e:	50                   	push   %eax
f010155f:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0101564:	6a 52                	push   $0x52
f0101566:	68 de 3c 10 f0       	push   $0xf0103cde
f010156b:	e8 7b eb ff ff       	call   f01000eb <_panic>
f0101570:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101576:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010157c:	80 38 00             	cmpb   $0x0,(%eax)
f010157f:	74 19                	je     f010159a <mem_init+0x4db>
f0101581:	68 a6 3e 10 f0       	push   $0xf0103ea6
f0101586:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010158b:	68 b5 02 00 00       	push   $0x2b5
f0101590:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101595:	e8 51 eb ff ff       	call   f01000eb <_panic>
f010159a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010159d:	39 d0                	cmp    %edx,%eax
f010159f:	75 db                	jne    f010157c <mem_init+0x4bd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015a4:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01015a9:	83 ec 0c             	sub    $0xc,%esp
f01015ac:	56                   	push   %esi
f01015ad:	e8 12 f8 ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f01015b2:	89 3c 24             	mov    %edi,(%esp)
f01015b5:	e8 0a f8 ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f01015ba:	83 c4 04             	add    $0x4,%esp
f01015bd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015c0:	e8 ff f7 ff ff       	call   f0100dc4 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015c5:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01015ca:	83 c4 10             	add    $0x10,%esp
f01015cd:	eb 05                	jmp    f01015d4 <mem_init+0x515>
		--nfree;
f01015cf:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015d2:	8b 00                	mov    (%eax),%eax
f01015d4:	85 c0                	test   %eax,%eax
f01015d6:	75 f7                	jne    f01015cf <mem_init+0x510>
		--nfree;
	assert(nfree == 0);
f01015d8:	85 db                	test   %ebx,%ebx
f01015da:	74 19                	je     f01015f5 <mem_init+0x536>
f01015dc:	68 b0 3e 10 f0       	push   $0xf0103eb0
f01015e1:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01015e6:	68 c2 02 00 00       	push   $0x2c2
f01015eb:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01015f0:	e8 f6 ea ff ff       	call   f01000eb <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01015f5:	83 ec 0c             	sub    $0xc,%esp
f01015f8:	68 98 41 10 f0       	push   $0xf0104198
f01015fd:	e8 9b 11 00 00       	call   f010279d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101602:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101609:	e8 46 f7 ff ff       	call   f0100d54 <page_alloc>
f010160e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101611:	83 c4 10             	add    $0x10,%esp
f0101614:	85 c0                	test   %eax,%eax
f0101616:	75 19                	jne    f0101631 <mem_init+0x572>
f0101618:	68 be 3d 10 f0       	push   $0xf0103dbe
f010161d:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101622:	68 1b 03 00 00       	push   $0x31b
f0101627:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010162c:	e8 ba ea ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f0101631:	83 ec 0c             	sub    $0xc,%esp
f0101634:	6a 00                	push   $0x0
f0101636:	e8 19 f7 ff ff       	call   f0100d54 <page_alloc>
f010163b:	89 c3                	mov    %eax,%ebx
f010163d:	83 c4 10             	add    $0x10,%esp
f0101640:	85 c0                	test   %eax,%eax
f0101642:	75 19                	jne    f010165d <mem_init+0x59e>
f0101644:	68 d4 3d 10 f0       	push   $0xf0103dd4
f0101649:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010164e:	68 1c 03 00 00       	push   $0x31c
f0101653:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101658:	e8 8e ea ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f010165d:	83 ec 0c             	sub    $0xc,%esp
f0101660:	6a 00                	push   $0x0
f0101662:	e8 ed f6 ff ff       	call   f0100d54 <page_alloc>
f0101667:	89 c6                	mov    %eax,%esi
f0101669:	83 c4 10             	add    $0x10,%esp
f010166c:	85 c0                	test   %eax,%eax
f010166e:	75 19                	jne    f0101689 <mem_init+0x5ca>
f0101670:	68 ea 3d 10 f0       	push   $0xf0103dea
f0101675:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010167a:	68 1d 03 00 00       	push   $0x31d
f010167f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101684:	e8 62 ea ff ff       	call   f01000eb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101689:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010168c:	75 19                	jne    f01016a7 <mem_init+0x5e8>
f010168e:	68 00 3e 10 f0       	push   $0xf0103e00
f0101693:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101698:	68 20 03 00 00       	push   $0x320
f010169d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01016a2:	e8 44 ea ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a7:	39 c3                	cmp    %eax,%ebx
f01016a9:	74 05                	je     f01016b0 <mem_init+0x5f1>
f01016ab:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016ae:	75 19                	jne    f01016c9 <mem_init+0x60a>
f01016b0:	68 78 41 10 f0       	push   $0xf0104178
f01016b5:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01016ba:	68 21 03 00 00       	push   $0x321
f01016bf:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01016c4:	e8 22 ea ff ff       	call   f01000eb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016c9:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01016ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016d1:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01016d8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016db:	83 ec 0c             	sub    $0xc,%esp
f01016de:	6a 00                	push   $0x0
f01016e0:	e8 6f f6 ff ff       	call   f0100d54 <page_alloc>
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	85 c0                	test   %eax,%eax
f01016ea:	74 19                	je     f0101705 <mem_init+0x646>
f01016ec:	68 69 3e 10 f0       	push   $0xf0103e69
f01016f1:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01016f6:	68 28 03 00 00       	push   $0x328
f01016fb:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101700:	e8 e6 e9 ff ff       	call   f01000eb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101705:	83 ec 04             	sub    $0x4,%esp
f0101708:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010170b:	50                   	push   %eax
f010170c:	6a 00                	push   $0x0
f010170e:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101714:	e8 a0 f8 ff ff       	call   f0100fb9 <page_lookup>
f0101719:	83 c4 10             	add    $0x10,%esp
f010171c:	85 c0                	test   %eax,%eax
f010171e:	74 19                	je     f0101739 <mem_init+0x67a>
f0101720:	68 b8 41 10 f0       	push   $0xf01041b8
f0101725:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010172a:	68 2b 03 00 00       	push   $0x32b
f010172f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101734:	e8 b2 e9 ff ff       	call   f01000eb <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101739:	6a 02                	push   $0x2
f010173b:	6a 00                	push   $0x0
f010173d:	53                   	push   %ebx
f010173e:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101744:	e8 fe f8 ff ff       	call   f0101047 <page_insert>
f0101749:	83 c4 10             	add    $0x10,%esp
f010174c:	85 c0                	test   %eax,%eax
f010174e:	78 19                	js     f0101769 <mem_init+0x6aa>
f0101750:	68 f0 41 10 f0       	push   $0xf01041f0
f0101755:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010175a:	68 2e 03 00 00       	push   $0x32e
f010175f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101764:	e8 82 e9 ff ff       	call   f01000eb <_panic>
	
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101769:	83 ec 0c             	sub    $0xc,%esp
f010176c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010176f:	e8 50 f6 ff ff       	call   f0100dc4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101774:	6a 02                	push   $0x2
f0101776:	6a 00                	push   $0x0
f0101778:	53                   	push   %ebx
f0101779:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010177f:	e8 c3 f8 ff ff       	call   f0101047 <page_insert>
f0101784:	83 c4 20             	add    $0x20,%esp
f0101787:	85 c0                	test   %eax,%eax
f0101789:	74 19                	je     f01017a4 <mem_init+0x6e5>
f010178b:	68 20 42 10 f0       	push   $0xf0104220
f0101790:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101795:	68 32 03 00 00       	push   $0x332
f010179a:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010179f:	e8 47 e9 ff ff       	call   f01000eb <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017a4:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017aa:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01017af:	89 c1                	mov    %eax,%ecx
f01017b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017b4:	8b 17                	mov    (%edi),%edx
f01017b6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017bf:	29 c8                	sub    %ecx,%eax
f01017c1:	c1 f8 03             	sar    $0x3,%eax
f01017c4:	c1 e0 0c             	shl    $0xc,%eax
f01017c7:	39 c2                	cmp    %eax,%edx
f01017c9:	74 19                	je     f01017e4 <mem_init+0x725>
f01017cb:	68 50 42 10 f0       	push   $0xf0104250
f01017d0:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01017d5:	68 33 03 00 00       	push   $0x333
f01017da:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01017df:	e8 07 e9 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01017e9:	89 f8                	mov    %edi,%eax
f01017eb:	e8 cb f1 ff ff       	call   f01009bb <check_va2pa>
f01017f0:	89 da                	mov    %ebx,%edx
f01017f2:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01017f5:	c1 fa 03             	sar    $0x3,%edx
f01017f8:	c1 e2 0c             	shl    $0xc,%edx
f01017fb:	39 d0                	cmp    %edx,%eax
f01017fd:	74 19                	je     f0101818 <mem_init+0x759>
f01017ff:	68 78 42 10 f0       	push   $0xf0104278
f0101804:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101809:	68 34 03 00 00       	push   $0x334
f010180e:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101813:	e8 d3 e8 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 1);
f0101818:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010181d:	74 19                	je     f0101838 <mem_init+0x779>
f010181f:	68 bb 3e 10 f0       	push   $0xf0103ebb
f0101824:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101829:	68 35 03 00 00       	push   $0x335
f010182e:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101833:	e8 b3 e8 ff ff       	call   f01000eb <_panic>
	assert(pp0->pp_ref == 1);
f0101838:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101840:	74 19                	je     f010185b <mem_init+0x79c>
f0101842:	68 cc 3e 10 f0       	push   $0xf0103ecc
f0101847:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010184c:	68 36 03 00 00       	push   $0x336
f0101851:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101856:	e8 90 e8 ff ff       	call   f01000eb <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010185b:	6a 02                	push   $0x2
f010185d:	68 00 10 00 00       	push   $0x1000
f0101862:	56                   	push   %esi
f0101863:	57                   	push   %edi
f0101864:	e8 de f7 ff ff       	call   f0101047 <page_insert>
f0101869:	83 c4 10             	add    $0x10,%esp
f010186c:	85 c0                	test   %eax,%eax
f010186e:	74 19                	je     f0101889 <mem_init+0x7ca>
f0101870:	68 a8 42 10 f0       	push   $0xf01042a8
f0101875:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010187a:	68 39 03 00 00       	push   $0x339
f010187f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101884:	e8 62 e8 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101889:	ba 00 10 00 00       	mov    $0x1000,%edx
f010188e:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0101893:	e8 23 f1 ff ff       	call   f01009bb <check_va2pa>
f0101898:	89 f2                	mov    %esi,%edx
f010189a:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f01018a0:	c1 fa 03             	sar    $0x3,%edx
f01018a3:	c1 e2 0c             	shl    $0xc,%edx
f01018a6:	39 d0                	cmp    %edx,%eax
f01018a8:	74 19                	je     f01018c3 <mem_init+0x804>
f01018aa:	68 e4 42 10 f0       	push   $0xf01042e4
f01018af:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01018b4:	68 3a 03 00 00       	push   $0x33a
f01018b9:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01018be:	e8 28 e8 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f01018c3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018c8:	74 19                	je     f01018e3 <mem_init+0x824>
f01018ca:	68 dd 3e 10 f0       	push   $0xf0103edd
f01018cf:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01018d4:	68 3b 03 00 00       	push   $0x33b
f01018d9:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01018de:	e8 08 e8 ff ff       	call   f01000eb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01018e3:	83 ec 0c             	sub    $0xc,%esp
f01018e6:	6a 00                	push   $0x0
f01018e8:	e8 67 f4 ff ff       	call   f0100d54 <page_alloc>
f01018ed:	83 c4 10             	add    $0x10,%esp
f01018f0:	85 c0                	test   %eax,%eax
f01018f2:	74 19                	je     f010190d <mem_init+0x84e>
f01018f4:	68 69 3e 10 f0       	push   $0xf0103e69
f01018f9:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01018fe:	68 3e 03 00 00       	push   $0x33e
f0101903:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101908:	e8 de e7 ff ff       	call   f01000eb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010190d:	6a 02                	push   $0x2
f010190f:	68 00 10 00 00       	push   $0x1000
f0101914:	56                   	push   %esi
f0101915:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010191b:	e8 27 f7 ff ff       	call   f0101047 <page_insert>
f0101920:	83 c4 10             	add    $0x10,%esp
f0101923:	85 c0                	test   %eax,%eax
f0101925:	74 19                	je     f0101940 <mem_init+0x881>
f0101927:	68 a8 42 10 f0       	push   $0xf01042a8
f010192c:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101931:	68 41 03 00 00       	push   $0x341
f0101936:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010193b:	e8 ab e7 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101940:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101945:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f010194a:	e8 6c f0 ff ff       	call   f01009bb <check_va2pa>
f010194f:	89 f2                	mov    %esi,%edx
f0101951:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101957:	c1 fa 03             	sar    $0x3,%edx
f010195a:	c1 e2 0c             	shl    $0xc,%edx
f010195d:	39 d0                	cmp    %edx,%eax
f010195f:	74 19                	je     f010197a <mem_init+0x8bb>
f0101961:	68 e4 42 10 f0       	push   $0xf01042e4
f0101966:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010196b:	68 42 03 00 00       	push   $0x342
f0101970:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101975:	e8 71 e7 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f010197a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010197f:	74 19                	je     f010199a <mem_init+0x8db>
f0101981:	68 dd 3e 10 f0       	push   $0xf0103edd
f0101986:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010198b:	68 43 03 00 00       	push   $0x343
f0101990:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101995:	e8 51 e7 ff ff       	call   f01000eb <_panic>
	
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010199a:	83 ec 0c             	sub    $0xc,%esp
f010199d:	6a 00                	push   $0x0
f010199f:	e8 b0 f3 ff ff       	call   f0100d54 <page_alloc>
f01019a4:	83 c4 10             	add    $0x10,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	74 19                	je     f01019c4 <mem_init+0x905>
f01019ab:	68 69 3e 10 f0       	push   $0xf0103e69
f01019b0:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01019b5:	68 47 03 00 00       	push   $0x347
f01019ba:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01019bf:	e8 27 e7 ff ff       	call   f01000eb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019c4:	8b 15 48 79 11 f0    	mov    0xf0117948,%edx
f01019ca:	8b 02                	mov    (%edx),%eax
f01019cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019d1:	89 c1                	mov    %eax,%ecx
f01019d3:	c1 e9 0c             	shr    $0xc,%ecx
f01019d6:	3b 0d 44 79 11 f0    	cmp    0xf0117944,%ecx
f01019dc:	72 15                	jb     f01019f3 <mem_init+0x934>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019de:	50                   	push   %eax
f01019df:	68 d0 3f 10 f0       	push   $0xf0103fd0
f01019e4:	68 4a 03 00 00       	push   $0x34a
f01019e9:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01019ee:	e8 f8 e6 ff ff       	call   f01000eb <_panic>
f01019f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01019fb:	83 ec 04             	sub    $0x4,%esp
f01019fe:	6a 00                	push   $0x0
f0101a00:	68 00 10 00 00       	push   $0x1000
f0101a05:	52                   	push   %edx
f0101a06:	e8 5e f4 ff ff       	call   f0100e69 <pgdir_walk>
f0101a0b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a0e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a11:	83 c4 10             	add    $0x10,%esp
f0101a14:	39 d0                	cmp    %edx,%eax
f0101a16:	74 19                	je     f0101a31 <mem_init+0x972>
f0101a18:	68 14 43 10 f0       	push   $0xf0104314
f0101a1d:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101a22:	68 4b 03 00 00       	push   $0x34b
f0101a27:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101a2c:	e8 ba e6 ff ff       	call   f01000eb <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a31:	6a 06                	push   $0x6
f0101a33:	68 00 10 00 00       	push   $0x1000
f0101a38:	56                   	push   %esi
f0101a39:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101a3f:	e8 03 f6 ff ff       	call   f0101047 <page_insert>
f0101a44:	83 c4 10             	add    $0x10,%esp
f0101a47:	85 c0                	test   %eax,%eax
f0101a49:	74 19                	je     f0101a64 <mem_init+0x9a5>
f0101a4b:	68 54 43 10 f0       	push   $0xf0104354
f0101a50:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101a55:	68 4e 03 00 00       	push   $0x34e
f0101a5a:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101a5f:	e8 87 e6 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a64:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101a6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a6f:	89 f8                	mov    %edi,%eax
f0101a71:	e8 45 ef ff ff       	call   f01009bb <check_va2pa>
f0101a76:	89 f2                	mov    %esi,%edx
f0101a78:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101a7e:	c1 fa 03             	sar    $0x3,%edx
f0101a81:	c1 e2 0c             	shl    $0xc,%edx
f0101a84:	39 d0                	cmp    %edx,%eax
f0101a86:	74 19                	je     f0101aa1 <mem_init+0x9e2>
f0101a88:	68 e4 42 10 f0       	push   $0xf01042e4
f0101a8d:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101a92:	68 4f 03 00 00       	push   $0x34f
f0101a97:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101a9c:	e8 4a e6 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f0101aa1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aa6:	74 19                	je     f0101ac1 <mem_init+0xa02>
f0101aa8:	68 dd 3e 10 f0       	push   $0xf0103edd
f0101aad:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101ab2:	68 50 03 00 00       	push   $0x350
f0101ab7:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101abc:	e8 2a e6 ff ff       	call   f01000eb <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ac1:	83 ec 04             	sub    $0x4,%esp
f0101ac4:	6a 00                	push   $0x0
f0101ac6:	68 00 10 00 00       	push   $0x1000
f0101acb:	57                   	push   %edi
f0101acc:	e8 98 f3 ff ff       	call   f0100e69 <pgdir_walk>
f0101ad1:	83 c4 10             	add    $0x10,%esp
f0101ad4:	f6 00 04             	testb  $0x4,(%eax)
f0101ad7:	75 19                	jne    f0101af2 <mem_init+0xa33>
f0101ad9:	68 94 43 10 f0       	push   $0xf0104394
f0101ade:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101ae3:	68 51 03 00 00       	push   $0x351
f0101ae8:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101aed:	e8 f9 e5 ff ff       	call   f01000eb <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101af2:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0101af7:	f6 00 04             	testb  $0x4,(%eax)
f0101afa:	75 19                	jne    f0101b15 <mem_init+0xa56>
f0101afc:	68 ee 3e 10 f0       	push   $0xf0103eee
f0101b01:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101b06:	68 52 03 00 00       	push   $0x352
f0101b0b:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101b10:	e8 d6 e5 ff ff       	call   f01000eb <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b15:	6a 02                	push   $0x2
f0101b17:	68 00 10 00 00       	push   $0x1000
f0101b1c:	56                   	push   %esi
f0101b1d:	50                   	push   %eax
f0101b1e:	e8 24 f5 ff ff       	call   f0101047 <page_insert>
f0101b23:	83 c4 10             	add    $0x10,%esp
f0101b26:	85 c0                	test   %eax,%eax
f0101b28:	74 19                	je     f0101b43 <mem_init+0xa84>
f0101b2a:	68 a8 42 10 f0       	push   $0xf01042a8
f0101b2f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101b34:	68 55 03 00 00       	push   $0x355
f0101b39:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101b3e:	e8 a8 e5 ff ff       	call   f01000eb <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b43:	83 ec 04             	sub    $0x4,%esp
f0101b46:	6a 00                	push   $0x0
f0101b48:	68 00 10 00 00       	push   $0x1000
f0101b4d:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101b53:	e8 11 f3 ff ff       	call   f0100e69 <pgdir_walk>
f0101b58:	83 c4 10             	add    $0x10,%esp
f0101b5b:	f6 00 02             	testb  $0x2,(%eax)
f0101b5e:	75 19                	jne    f0101b79 <mem_init+0xaba>
f0101b60:	68 c8 43 10 f0       	push   $0xf01043c8
f0101b65:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101b6a:	68 56 03 00 00       	push   $0x356
f0101b6f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101b74:	e8 72 e5 ff ff       	call   f01000eb <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b79:	83 ec 04             	sub    $0x4,%esp
f0101b7c:	6a 00                	push   $0x0
f0101b7e:	68 00 10 00 00       	push   $0x1000
f0101b83:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101b89:	e8 db f2 ff ff       	call   f0100e69 <pgdir_walk>
f0101b8e:	83 c4 10             	add    $0x10,%esp
f0101b91:	f6 00 04             	testb  $0x4,(%eax)
f0101b94:	74 19                	je     f0101baf <mem_init+0xaf0>
f0101b96:	68 fc 43 10 f0       	push   $0xf01043fc
f0101b9b:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101ba0:	68 57 03 00 00       	push   $0x357
f0101ba5:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101baa:	e8 3c e5 ff ff       	call   f01000eb <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101baf:	6a 02                	push   $0x2
f0101bb1:	68 00 00 40 00       	push   $0x400000
f0101bb6:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bb9:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101bbf:	e8 83 f4 ff ff       	call   f0101047 <page_insert>
f0101bc4:	83 c4 10             	add    $0x10,%esp
f0101bc7:	85 c0                	test   %eax,%eax
f0101bc9:	78 19                	js     f0101be4 <mem_init+0xb25>
f0101bcb:	68 34 44 10 f0       	push   $0xf0104434
f0101bd0:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101bd5:	68 5a 03 00 00       	push   $0x35a
f0101bda:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101bdf:	e8 07 e5 ff ff       	call   f01000eb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101be4:	6a 02                	push   $0x2
f0101be6:	68 00 10 00 00       	push   $0x1000
f0101beb:	53                   	push   %ebx
f0101bec:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101bf2:	e8 50 f4 ff ff       	call   f0101047 <page_insert>
f0101bf7:	83 c4 10             	add    $0x10,%esp
f0101bfa:	85 c0                	test   %eax,%eax
f0101bfc:	74 19                	je     f0101c17 <mem_init+0xb58>
f0101bfe:	68 6c 44 10 f0       	push   $0xf010446c
f0101c03:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101c08:	68 5d 03 00 00       	push   $0x35d
f0101c0d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101c12:	e8 d4 e4 ff ff       	call   f01000eb <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c17:	83 ec 04             	sub    $0x4,%esp
f0101c1a:	6a 00                	push   $0x0
f0101c1c:	68 00 10 00 00       	push   $0x1000
f0101c21:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101c27:	e8 3d f2 ff ff       	call   f0100e69 <pgdir_walk>
f0101c2c:	83 c4 10             	add    $0x10,%esp
f0101c2f:	f6 00 04             	testb  $0x4,(%eax)
f0101c32:	74 19                	je     f0101c4d <mem_init+0xb8e>
f0101c34:	68 fc 43 10 f0       	push   $0xf01043fc
f0101c39:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101c3e:	68 5e 03 00 00       	push   $0x35e
f0101c43:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101c48:	e8 9e e4 ff ff       	call   f01000eb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c4d:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101c53:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c58:	89 f8                	mov    %edi,%eax
f0101c5a:	e8 5c ed ff ff       	call   f01009bb <check_va2pa>
f0101c5f:	89 c1                	mov    %eax,%ecx
f0101c61:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c64:	89 d8                	mov    %ebx,%eax
f0101c66:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101c6c:	c1 f8 03             	sar    $0x3,%eax
f0101c6f:	c1 e0 0c             	shl    $0xc,%eax
f0101c72:	39 c1                	cmp    %eax,%ecx
f0101c74:	74 19                	je     f0101c8f <mem_init+0xbd0>
f0101c76:	68 a8 44 10 f0       	push   $0xf01044a8
f0101c7b:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101c80:	68 61 03 00 00       	push   $0x361
f0101c85:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101c8a:	e8 5c e4 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c8f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c94:	89 f8                	mov    %edi,%eax
f0101c96:	e8 20 ed ff ff       	call   f01009bb <check_va2pa>
f0101c9b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c9e:	74 19                	je     f0101cb9 <mem_init+0xbfa>
f0101ca0:	68 d4 44 10 f0       	push   $0xf01044d4
f0101ca5:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101caa:	68 62 03 00 00       	push   $0x362
f0101caf:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101cb4:	e8 32 e4 ff ff       	call   f01000eb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cb9:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cbe:	74 19                	je     f0101cd9 <mem_init+0xc1a>
f0101cc0:	68 04 3f 10 f0       	push   $0xf0103f04
f0101cc5:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101cca:	68 64 03 00 00       	push   $0x364
f0101ccf:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101cd4:	e8 12 e4 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101cd9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cde:	74 19                	je     f0101cf9 <mem_init+0xc3a>
f0101ce0:	68 15 3f 10 f0       	push   $0xf0103f15
f0101ce5:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101cea:	68 65 03 00 00       	push   $0x365
f0101cef:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101cf4:	e8 f2 e3 ff ff       	call   f01000eb <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cf9:	83 ec 0c             	sub    $0xc,%esp
f0101cfc:	6a 00                	push   $0x0
f0101cfe:	e8 51 f0 ff ff       	call   f0100d54 <page_alloc>
f0101d03:	83 c4 10             	add    $0x10,%esp
f0101d06:	85 c0                	test   %eax,%eax
f0101d08:	74 04                	je     f0101d0e <mem_init+0xc4f>
f0101d0a:	39 c6                	cmp    %eax,%esi
f0101d0c:	74 19                	je     f0101d27 <mem_init+0xc68>
f0101d0e:	68 04 45 10 f0       	push   $0xf0104504
f0101d13:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101d18:	68 68 03 00 00       	push   $0x368
f0101d1d:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101d22:	e8 c4 e3 ff ff       	call   f01000eb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d27:	83 ec 08             	sub    $0x8,%esp
f0101d2a:	6a 00                	push   $0x0
f0101d2c:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101d32:	e8 d5 f2 ff ff       	call   f010100c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d37:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101d3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d42:	89 f8                	mov    %edi,%eax
f0101d44:	e8 72 ec ff ff       	call   f01009bb <check_va2pa>
f0101d49:	83 c4 10             	add    $0x10,%esp
f0101d4c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d4f:	74 19                	je     f0101d6a <mem_init+0xcab>
f0101d51:	68 28 45 10 f0       	push   $0xf0104528
f0101d56:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101d5b:	68 6c 03 00 00       	push   $0x36c
f0101d60:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101d65:	e8 81 e3 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d6f:	89 f8                	mov    %edi,%eax
f0101d71:	e8 45 ec ff ff       	call   f01009bb <check_va2pa>
f0101d76:	89 da                	mov    %ebx,%edx
f0101d78:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101d7e:	c1 fa 03             	sar    $0x3,%edx
f0101d81:	c1 e2 0c             	shl    $0xc,%edx
f0101d84:	39 d0                	cmp    %edx,%eax
f0101d86:	74 19                	je     f0101da1 <mem_init+0xce2>
f0101d88:	68 d4 44 10 f0       	push   $0xf01044d4
f0101d8d:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101d92:	68 6d 03 00 00       	push   $0x36d
f0101d97:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101d9c:	e8 4a e3 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 1);
f0101da1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101da6:	74 19                	je     f0101dc1 <mem_init+0xd02>
f0101da8:	68 bb 3e 10 f0       	push   $0xf0103ebb
f0101dad:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101db2:	68 6e 03 00 00       	push   $0x36e
f0101db7:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101dbc:	e8 2a e3 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101dc1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101dc6:	74 19                	je     f0101de1 <mem_init+0xd22>
f0101dc8:	68 15 3f 10 f0       	push   $0xf0103f15
f0101dcd:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101dd2:	68 6f 03 00 00       	push   $0x36f
f0101dd7:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101ddc:	e8 0a e3 ff ff       	call   f01000eb <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101de1:	6a 00                	push   $0x0
f0101de3:	68 00 10 00 00       	push   $0x1000
f0101de8:	53                   	push   %ebx
f0101de9:	57                   	push   %edi
f0101dea:	e8 58 f2 ff ff       	call   f0101047 <page_insert>
f0101def:	83 c4 10             	add    $0x10,%esp
f0101df2:	85 c0                	test   %eax,%eax
f0101df4:	74 19                	je     f0101e0f <mem_init+0xd50>
f0101df6:	68 4c 45 10 f0       	push   $0xf010454c
f0101dfb:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101e00:	68 72 03 00 00       	push   $0x372
f0101e05:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101e0a:	e8 dc e2 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref);
f0101e0f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e14:	75 19                	jne    f0101e2f <mem_init+0xd70>
f0101e16:	68 26 3f 10 f0       	push   $0xf0103f26
f0101e1b:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101e20:	68 73 03 00 00       	push   $0x373
f0101e25:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101e2a:	e8 bc e2 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_link == NULL);
f0101e2f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e32:	74 19                	je     f0101e4d <mem_init+0xd8e>
f0101e34:	68 32 3f 10 f0       	push   $0xf0103f32
f0101e39:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101e3e:	68 74 03 00 00       	push   $0x374
f0101e43:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101e48:	e8 9e e2 ff ff       	call   f01000eb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e4d:	83 ec 08             	sub    $0x8,%esp
f0101e50:	68 00 10 00 00       	push   $0x1000
f0101e55:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101e5b:	e8 ac f1 ff ff       	call   f010100c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e60:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101e66:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e6b:	89 f8                	mov    %edi,%eax
f0101e6d:	e8 49 eb ff ff       	call   f01009bb <check_va2pa>
f0101e72:	83 c4 10             	add    $0x10,%esp
f0101e75:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e78:	74 19                	je     f0101e93 <mem_init+0xdd4>
f0101e7a:	68 28 45 10 f0       	push   $0xf0104528
f0101e7f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101e84:	68 78 03 00 00       	push   $0x378
f0101e89:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101e8e:	e8 58 e2 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e98:	89 f8                	mov    %edi,%eax
f0101e9a:	e8 1c eb ff ff       	call   f01009bb <check_va2pa>
f0101e9f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ea2:	74 19                	je     f0101ebd <mem_init+0xdfe>
f0101ea4:	68 84 45 10 f0       	push   $0xf0104584
f0101ea9:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101eae:	68 79 03 00 00       	push   $0x379
f0101eb3:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101eb8:	e8 2e e2 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 0);
f0101ebd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ec2:	74 19                	je     f0101edd <mem_init+0xe1e>
f0101ec4:	68 47 3f 10 f0       	push   $0xf0103f47
f0101ec9:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101ece:	68 7a 03 00 00       	push   $0x37a
f0101ed3:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101ed8:	e8 0e e2 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101edd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ee2:	74 19                	je     f0101efd <mem_init+0xe3e>
f0101ee4:	68 15 3f 10 f0       	push   $0xf0103f15
f0101ee9:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101eee:	68 7b 03 00 00       	push   $0x37b
f0101ef3:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101ef8:	e8 ee e1 ff ff       	call   f01000eb <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101efd:	83 ec 0c             	sub    $0xc,%esp
f0101f00:	6a 00                	push   $0x0
f0101f02:	e8 4d ee ff ff       	call   f0100d54 <page_alloc>
f0101f07:	83 c4 10             	add    $0x10,%esp
f0101f0a:	39 c3                	cmp    %eax,%ebx
f0101f0c:	75 04                	jne    f0101f12 <mem_init+0xe53>
f0101f0e:	85 c0                	test   %eax,%eax
f0101f10:	75 19                	jne    f0101f2b <mem_init+0xe6c>
f0101f12:	68 ac 45 10 f0       	push   $0xf01045ac
f0101f17:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101f1c:	68 7e 03 00 00       	push   $0x37e
f0101f21:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101f26:	e8 c0 e1 ff ff       	call   f01000eb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f2b:	83 ec 0c             	sub    $0xc,%esp
f0101f2e:	6a 00                	push   $0x0
f0101f30:	e8 1f ee ff ff       	call   f0100d54 <page_alloc>
f0101f35:	83 c4 10             	add    $0x10,%esp
f0101f38:	85 c0                	test   %eax,%eax
f0101f3a:	74 19                	je     f0101f55 <mem_init+0xe96>
f0101f3c:	68 69 3e 10 f0       	push   $0xf0103e69
f0101f41:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101f46:	68 81 03 00 00       	push   $0x381
f0101f4b:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101f50:	e8 96 e1 ff ff       	call   f01000eb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f55:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f0101f5b:	8b 11                	mov    (%ecx),%edx
f0101f5d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f66:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101f6c:	c1 f8 03             	sar    $0x3,%eax
f0101f6f:	c1 e0 0c             	shl    $0xc,%eax
f0101f72:	39 c2                	cmp    %eax,%edx
f0101f74:	74 19                	je     f0101f8f <mem_init+0xed0>
f0101f76:	68 50 42 10 f0       	push   $0xf0104250
f0101f7b:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101f80:	68 84 03 00 00       	push   $0x384
f0101f85:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101f8a:	e8 5c e1 ff ff       	call   f01000eb <_panic>
	kern_pgdir[0] = 0;
f0101f8f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f98:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f9d:	74 19                	je     f0101fb8 <mem_init+0xef9>
f0101f9f:	68 cc 3e 10 f0       	push   $0xf0103ecc
f0101fa4:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0101fa9:	68 86 03 00 00       	push   $0x386
f0101fae:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0101fb3:	e8 33 e1 ff ff       	call   f01000eb <_panic>
	pp0->pp_ref = 0;
f0101fb8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fbb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fc1:	83 ec 0c             	sub    $0xc,%esp
f0101fc4:	50                   	push   %eax
f0101fc5:	e8 fa ed ff ff       	call   f0100dc4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fca:	83 c4 0c             	add    $0xc,%esp
f0101fcd:	6a 01                	push   $0x1
f0101fcf:	68 00 10 40 00       	push   $0x401000
f0101fd4:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101fda:	e8 8a ee ff ff       	call   f0100e69 <pgdir_walk>
f0101fdf:	89 c7                	mov    %eax,%edi
f0101fe1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101fe4:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0101fe9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fec:	8b 40 04             	mov    0x4(%eax),%eax
f0101fef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ff4:	8b 0d 44 79 11 f0    	mov    0xf0117944,%ecx
f0101ffa:	89 c2                	mov    %eax,%edx
f0101ffc:	c1 ea 0c             	shr    $0xc,%edx
f0101fff:	83 c4 10             	add    $0x10,%esp
f0102002:	39 ca                	cmp    %ecx,%edx
f0102004:	72 15                	jb     f010201b <mem_init+0xf5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102006:	50                   	push   %eax
f0102007:	68 d0 3f 10 f0       	push   $0xf0103fd0
f010200c:	68 8d 03 00 00       	push   $0x38d
f0102011:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102016:	e8 d0 e0 ff ff       	call   f01000eb <_panic>
	assert(ptep == ptep1 + PTX(va));
f010201b:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102020:	39 c7                	cmp    %eax,%edi
f0102022:	74 19                	je     f010203d <mem_init+0xf7e>
f0102024:	68 58 3f 10 f0       	push   $0xf0103f58
f0102029:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010202e:	68 8e 03 00 00       	push   $0x38e
f0102033:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102038:	e8 ae e0 ff ff       	call   f01000eb <_panic>
	kern_pgdir[PDX(va)] = 0;
f010203d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102040:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102047:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010204a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102050:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0102056:	c1 f8 03             	sar    $0x3,%eax
f0102059:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010205c:	89 c2                	mov    %eax,%edx
f010205e:	c1 ea 0c             	shr    $0xc,%edx
f0102061:	39 d1                	cmp    %edx,%ecx
f0102063:	77 12                	ja     f0102077 <mem_init+0xfb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102065:	50                   	push   %eax
f0102066:	68 d0 3f 10 f0       	push   $0xf0103fd0
f010206b:	6a 52                	push   $0x52
f010206d:	68 de 3c 10 f0       	push   $0xf0103cde
f0102072:	e8 74 e0 ff ff       	call   f01000eb <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102077:	83 ec 04             	sub    $0x4,%esp
f010207a:	68 00 10 00 00       	push   $0x1000
f010207f:	68 ff 00 00 00       	push   $0xff
f0102084:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102089:	50                   	push   %eax
f010208a:	e8 5e 12 00 00       	call   f01032ed <memset>
	page_free(pp0);
f010208f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102092:	89 3c 24             	mov    %edi,(%esp)
f0102095:	e8 2a ed ff ff       	call   f0100dc4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010209a:	83 c4 0c             	add    $0xc,%esp
f010209d:	6a 01                	push   $0x1
f010209f:	6a 00                	push   $0x0
f01020a1:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01020a7:	e8 bd ed ff ff       	call   f0100e69 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020ac:	89 fa                	mov    %edi,%edx
f01020ae:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f01020b4:	c1 fa 03             	sar    $0x3,%edx
f01020b7:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020ba:	89 d0                	mov    %edx,%eax
f01020bc:	c1 e8 0c             	shr    $0xc,%eax
f01020bf:	83 c4 10             	add    $0x10,%esp
f01020c2:	3b 05 44 79 11 f0    	cmp    0xf0117944,%eax
f01020c8:	72 12                	jb     f01020dc <mem_init+0x101d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020ca:	52                   	push   %edx
f01020cb:	68 d0 3f 10 f0       	push   $0xf0103fd0
f01020d0:	6a 52                	push   $0x52
f01020d2:	68 de 3c 10 f0       	push   $0xf0103cde
f01020d7:	e8 0f e0 ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f01020dc:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020e5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020eb:	f6 00 01             	testb  $0x1,(%eax)
f01020ee:	74 19                	je     f0102109 <mem_init+0x104a>
f01020f0:	68 70 3f 10 f0       	push   $0xf0103f70
f01020f5:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01020fa:	68 98 03 00 00       	push   $0x398
f01020ff:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102104:	e8 e2 df ff ff       	call   f01000eb <_panic>
f0102109:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010210c:	39 d0                	cmp    %edx,%eax
f010210e:	75 db                	jne    f01020eb <mem_init+0x102c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102110:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0102115:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010211b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010211e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102124:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102127:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f010212d:	83 ec 0c             	sub    $0xc,%esp
f0102130:	50                   	push   %eax
f0102131:	e8 8e ec ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f0102136:	89 1c 24             	mov    %ebx,(%esp)
f0102139:	e8 86 ec ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f010213e:	89 34 24             	mov    %esi,(%esp)
f0102141:	e8 7e ec ff ff       	call   f0100dc4 <page_free>
	cprintf("check_page() succeeded!\n");
f0102146:	c7 04 24 87 3f 10 f0 	movl   $0xf0103f87,(%esp)
f010214d:	e8 4b 06 00 00       	call   f010279d <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f0102152:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102157:	83 c4 10             	add    $0x10,%esp
f010215a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010215f:	77 15                	ja     f0102176 <mem_init+0x10b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102161:	50                   	push   %eax
f0102162:	68 b8 40 10 f0       	push   $0xf01040b8
f0102167:	68 c5 00 00 00       	push   $0xc5
f010216c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102171:	e8 75 df ff ff       	call   f01000eb <_panic>
f0102176:	83 ec 08             	sub    $0x8,%esp
f0102179:	6a 04                	push   $0x4
f010217b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102180:	50                   	push   %eax
f0102181:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102186:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010218b:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0102190:	e8 c0 ed ff ff       	call   f0100f55 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102195:	83 c4 10             	add    $0x10,%esp
f0102198:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f010219d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021a2:	77 15                	ja     f01021b9 <mem_init+0x10fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021a4:	50                   	push   %eax
f01021a5:	68 b8 40 10 f0       	push   $0xf01040b8
f01021aa:	68 d3 00 00 00       	push   $0xd3
f01021af:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01021b4:	e8 32 df ff ff       	call   f01000eb <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f01021b9:	83 ec 08             	sub    $0x8,%esp
f01021bc:	6a 02                	push   $0x2
f01021be:	68 00 d0 10 00       	push   $0x10d000
f01021c3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021c8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021cd:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f01021d2:	e8 7e ed ff ff       	call   f0100f55 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W);
f01021d7:	83 c4 08             	add    $0x8,%esp
f01021da:	6a 02                	push   $0x2
f01021dc:	6a 00                	push   $0x0
f01021de:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01021e3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021e8:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f01021ed:	e8 63 ed ff ff       	call   f0100f55 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01021f2:	8b 35 48 79 11 f0    	mov    0xf0117948,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021f8:	a1 44 79 11 f0       	mov    0xf0117944,%eax
f01021fd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102200:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102207:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010220c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010220f:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102215:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102218:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010221b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102220:	eb 55                	jmp    f0102277 <mem_init+0x11b8>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102222:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102228:	89 f0                	mov    %esi,%eax
f010222a:	e8 8c e7 ff ff       	call   f01009bb <check_va2pa>
f010222f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102236:	77 15                	ja     f010224d <mem_init+0x118e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102238:	57                   	push   %edi
f0102239:	68 b8 40 10 f0       	push   $0xf01040b8
f010223e:	68 da 02 00 00       	push   $0x2da
f0102243:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102248:	e8 9e de ff ff       	call   f01000eb <_panic>
f010224d:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102254:	39 c2                	cmp    %eax,%edx
f0102256:	74 19                	je     f0102271 <mem_init+0x11b2>
f0102258:	68 d0 45 10 f0       	push   $0xf01045d0
f010225d:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102262:	68 da 02 00 00       	push   $0x2da
f0102267:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010226c:	e8 7a de ff ff       	call   f01000eb <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102271:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102277:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010227a:	77 a6                	ja     f0102222 <mem_init+0x1163>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010227c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010227f:	c1 e7 0c             	shl    $0xc,%edi
f0102282:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102287:	eb 30                	jmp    f01022b9 <mem_init+0x11fa>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102289:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010228f:	89 f0                	mov    %esi,%eax
f0102291:	e8 25 e7 ff ff       	call   f01009bb <check_va2pa>
f0102296:	39 c3                	cmp    %eax,%ebx
f0102298:	74 19                	je     f01022b3 <mem_init+0x11f4>
f010229a:	68 04 46 10 f0       	push   $0xf0104604
f010229f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01022a4:	68 df 02 00 00       	push   $0x2df
f01022a9:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01022ae:	e8 38 de ff ff       	call   f01000eb <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022b3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022b9:	39 fb                	cmp    %edi,%ebx
f01022bb:	72 cc                	jb     f0102289 <mem_init+0x11ca>
f01022bd:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022c2:	89 da                	mov    %ebx,%edx
f01022c4:	89 f0                	mov    %esi,%eax
f01022c6:	e8 f0 e6 ff ff       	call   f01009bb <check_va2pa>
f01022cb:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f01022d1:	39 c2                	cmp    %eax,%edx
f01022d3:	74 19                	je     f01022ee <mem_init+0x122f>
f01022d5:	68 2c 46 10 f0       	push   $0xf010462c
f01022da:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01022df:	68 e3 02 00 00       	push   $0x2e3
f01022e4:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01022e9:	e8 fd dd ff ff       	call   f01000eb <_panic>
f01022ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022f4:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01022fa:	75 c6                	jne    f01022c2 <mem_init+0x1203>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022fc:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102301:	89 f0                	mov    %esi,%eax
f0102303:	e8 b3 e6 ff ff       	call   f01009bb <check_va2pa>
f0102308:	83 f8 ff             	cmp    $0xffffffff,%eax
f010230b:	74 51                	je     f010235e <mem_init+0x129f>
f010230d:	68 74 46 10 f0       	push   $0xf0104674
f0102312:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102317:	68 e4 02 00 00       	push   $0x2e4
f010231c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102321:	e8 c5 dd ff ff       	call   f01000eb <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102326:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010232b:	72 36                	jb     f0102363 <mem_init+0x12a4>
f010232d:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102332:	76 07                	jbe    f010233b <mem_init+0x127c>
f0102334:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102339:	75 28                	jne    f0102363 <mem_init+0x12a4>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010233b:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010233f:	0f 85 83 00 00 00    	jne    f01023c8 <mem_init+0x1309>
f0102345:	68 a0 3f 10 f0       	push   $0xf0103fa0
f010234a:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010234f:	68 ec 02 00 00       	push   $0x2ec
f0102354:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102359:	e8 8d dd ff ff       	call   f01000eb <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010235e:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102363:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102368:	76 3f                	jbe    f01023a9 <mem_init+0x12ea>
				assert(pgdir[i] & PTE_P);
f010236a:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010236d:	f6 c2 01             	test   $0x1,%dl
f0102370:	75 19                	jne    f010238b <mem_init+0x12cc>
f0102372:	68 a0 3f 10 f0       	push   $0xf0103fa0
f0102377:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010237c:	68 f0 02 00 00       	push   $0x2f0
f0102381:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102386:	e8 60 dd ff ff       	call   f01000eb <_panic>
				assert(pgdir[i] & PTE_W);
f010238b:	f6 c2 02             	test   $0x2,%dl
f010238e:	75 38                	jne    f01023c8 <mem_init+0x1309>
f0102390:	68 b1 3f 10 f0       	push   $0xf0103fb1
f0102395:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010239a:	68 f1 02 00 00       	push   $0x2f1
f010239f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01023a4:	e8 42 dd ff ff       	call   f01000eb <_panic>
			} else
				assert(pgdir[i] == 0);
f01023a9:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01023ad:	74 19                	je     f01023c8 <mem_init+0x1309>
f01023af:	68 c2 3f 10 f0       	push   $0xf0103fc2
f01023b4:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01023b9:	68 f3 02 00 00       	push   $0x2f3
f01023be:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01023c3:	e8 23 dd ff ff       	call   f01000eb <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01023c8:	83 c0 01             	add    $0x1,%eax
f01023cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01023d0:	0f 86 50 ff ff ff    	jbe    f0102326 <mem_init+0x1267>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01023d6:	83 ec 0c             	sub    $0xc,%esp
f01023d9:	68 a4 46 10 f0       	push   $0xf01046a4
f01023de:	e8 ba 03 00 00       	call   f010279d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01023e3:	a1 48 79 11 f0       	mov    0xf0117948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023e8:	83 c4 10             	add    $0x10,%esp
f01023eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023f0:	77 15                	ja     f0102407 <mem_init+0x1348>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023f2:	50                   	push   %eax
f01023f3:	68 b8 40 10 f0       	push   $0xf01040b8
f01023f8:	68 ea 00 00 00       	push   $0xea
f01023fd:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102402:	e8 e4 dc ff ff       	call   f01000eb <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102407:	05 00 00 00 10       	add    $0x10000000,%eax
f010240c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010240f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102414:	e8 06 e6 ff ff       	call   f0100a1f <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102419:	0f 20 c0             	mov    %cr0,%eax
f010241c:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010241f:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102424:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102427:	83 ec 0c             	sub    $0xc,%esp
f010242a:	6a 00                	push   $0x0
f010242c:	e8 23 e9 ff ff       	call   f0100d54 <page_alloc>
f0102431:	89 c3                	mov    %eax,%ebx
f0102433:	83 c4 10             	add    $0x10,%esp
f0102436:	85 c0                	test   %eax,%eax
f0102438:	75 19                	jne    f0102453 <mem_init+0x1394>
f010243a:	68 be 3d 10 f0       	push   $0xf0103dbe
f010243f:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102444:	68 b2 03 00 00       	push   $0x3b2
f0102449:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010244e:	e8 98 dc ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f0102453:	83 ec 0c             	sub    $0xc,%esp
f0102456:	6a 00                	push   $0x0
f0102458:	e8 f7 e8 ff ff       	call   f0100d54 <page_alloc>
f010245d:	89 c7                	mov    %eax,%edi
f010245f:	83 c4 10             	add    $0x10,%esp
f0102462:	85 c0                	test   %eax,%eax
f0102464:	75 19                	jne    f010247f <mem_init+0x13c0>
f0102466:	68 d4 3d 10 f0       	push   $0xf0103dd4
f010246b:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102470:	68 b3 03 00 00       	push   $0x3b3
f0102475:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010247a:	e8 6c dc ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f010247f:	83 ec 0c             	sub    $0xc,%esp
f0102482:	6a 00                	push   $0x0
f0102484:	e8 cb e8 ff ff       	call   f0100d54 <page_alloc>
f0102489:	89 c6                	mov    %eax,%esi
f010248b:	83 c4 10             	add    $0x10,%esp
f010248e:	85 c0                	test   %eax,%eax
f0102490:	75 19                	jne    f01024ab <mem_init+0x13ec>
f0102492:	68 ea 3d 10 f0       	push   $0xf0103dea
f0102497:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010249c:	68 b4 03 00 00       	push   $0x3b4
f01024a1:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01024a6:	e8 40 dc ff ff       	call   f01000eb <_panic>
	page_free(pp0);
f01024ab:	83 ec 0c             	sub    $0xc,%esp
f01024ae:	53                   	push   %ebx
f01024af:	e8 10 e9 ff ff       	call   f0100dc4 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024b4:	89 f8                	mov    %edi,%eax
f01024b6:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01024bc:	c1 f8 03             	sar    $0x3,%eax
f01024bf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024c2:	89 c2                	mov    %eax,%edx
f01024c4:	c1 ea 0c             	shr    $0xc,%edx
f01024c7:	83 c4 10             	add    $0x10,%esp
f01024ca:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f01024d0:	72 12                	jb     f01024e4 <mem_init+0x1425>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024d2:	50                   	push   %eax
f01024d3:	68 d0 3f 10 f0       	push   $0xf0103fd0
f01024d8:	6a 52                	push   $0x52
f01024da:	68 de 3c 10 f0       	push   $0xf0103cde
f01024df:	e8 07 dc ff ff       	call   f01000eb <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01024e4:	83 ec 04             	sub    $0x4,%esp
f01024e7:	68 00 10 00 00       	push   $0x1000
f01024ec:	6a 01                	push   $0x1
f01024ee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024f3:	50                   	push   %eax
f01024f4:	e8 f4 0d 00 00       	call   f01032ed <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024f9:	89 f0                	mov    %esi,%eax
f01024fb:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0102501:	c1 f8 03             	sar    $0x3,%eax
f0102504:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102507:	89 c2                	mov    %eax,%edx
f0102509:	c1 ea 0c             	shr    $0xc,%edx
f010250c:	83 c4 10             	add    $0x10,%esp
f010250f:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0102515:	72 12                	jb     f0102529 <mem_init+0x146a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102517:	50                   	push   %eax
f0102518:	68 d0 3f 10 f0       	push   $0xf0103fd0
f010251d:	6a 52                	push   $0x52
f010251f:	68 de 3c 10 f0       	push   $0xf0103cde
f0102524:	e8 c2 db ff ff       	call   f01000eb <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102529:	83 ec 04             	sub    $0x4,%esp
f010252c:	68 00 10 00 00       	push   $0x1000
f0102531:	6a 02                	push   $0x2
f0102533:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102538:	50                   	push   %eax
f0102539:	e8 af 0d 00 00       	call   f01032ed <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010253e:	6a 02                	push   $0x2
f0102540:	68 00 10 00 00       	push   $0x1000
f0102545:	57                   	push   %edi
f0102546:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010254c:	e8 f6 ea ff ff       	call   f0101047 <page_insert>
	assert(pp1->pp_ref == 1);
f0102551:	83 c4 20             	add    $0x20,%esp
f0102554:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102559:	74 19                	je     f0102574 <mem_init+0x14b5>
f010255b:	68 bb 3e 10 f0       	push   $0xf0103ebb
f0102560:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102565:	68 b9 03 00 00       	push   $0x3b9
f010256a:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010256f:	e8 77 db ff ff       	call   f01000eb <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102574:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010257b:	01 01 01 
f010257e:	74 19                	je     f0102599 <mem_init+0x14da>
f0102580:	68 c4 46 10 f0       	push   $0xf01046c4
f0102585:	68 f8 3c 10 f0       	push   $0xf0103cf8
f010258a:	68 ba 03 00 00       	push   $0x3ba
f010258f:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102594:	e8 52 db ff ff       	call   f01000eb <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102599:	6a 02                	push   $0x2
f010259b:	68 00 10 00 00       	push   $0x1000
f01025a0:	56                   	push   %esi
f01025a1:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01025a7:	e8 9b ea ff ff       	call   f0101047 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025ac:	83 c4 10             	add    $0x10,%esp
f01025af:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025b6:	02 02 02 
f01025b9:	74 19                	je     f01025d4 <mem_init+0x1515>
f01025bb:	68 e8 46 10 f0       	push   $0xf01046e8
f01025c0:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01025c5:	68 bc 03 00 00       	push   $0x3bc
f01025ca:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01025cf:	e8 17 db ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f01025d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025d9:	74 19                	je     f01025f4 <mem_init+0x1535>
f01025db:	68 dd 3e 10 f0       	push   $0xf0103edd
f01025e0:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01025e5:	68 bd 03 00 00       	push   $0x3bd
f01025ea:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01025ef:	e8 f7 da ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 0);
f01025f4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025f9:	74 19                	je     f0102614 <mem_init+0x1555>
f01025fb:	68 47 3f 10 f0       	push   $0xf0103f47
f0102600:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102605:	68 be 03 00 00       	push   $0x3be
f010260a:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010260f:	e8 d7 da ff ff       	call   f01000eb <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102614:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010261b:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010261e:	89 f0                	mov    %esi,%eax
f0102620:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0102626:	c1 f8 03             	sar    $0x3,%eax
f0102629:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010262c:	89 c2                	mov    %eax,%edx
f010262e:	c1 ea 0c             	shr    $0xc,%edx
f0102631:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0102637:	72 12                	jb     f010264b <mem_init+0x158c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102639:	50                   	push   %eax
f010263a:	68 d0 3f 10 f0       	push   $0xf0103fd0
f010263f:	6a 52                	push   $0x52
f0102641:	68 de 3c 10 f0       	push   $0xf0103cde
f0102646:	e8 a0 da ff ff       	call   f01000eb <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010264b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102652:	03 03 03 
f0102655:	74 19                	je     f0102670 <mem_init+0x15b1>
f0102657:	68 0c 47 10 f0       	push   $0xf010470c
f010265c:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102661:	68 c0 03 00 00       	push   $0x3c0
f0102666:	68 d2 3c 10 f0       	push   $0xf0103cd2
f010266b:	e8 7b da ff ff       	call   f01000eb <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102670:	83 ec 08             	sub    $0x8,%esp
f0102673:	68 00 10 00 00       	push   $0x1000
f0102678:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010267e:	e8 89 e9 ff ff       	call   f010100c <page_remove>
	assert(pp2->pp_ref == 0);
f0102683:	83 c4 10             	add    $0x10,%esp
f0102686:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010268b:	74 19                	je     f01026a6 <mem_init+0x15e7>
f010268d:	68 15 3f 10 f0       	push   $0xf0103f15
f0102692:	68 f8 3c 10 f0       	push   $0xf0103cf8
f0102697:	68 c2 03 00 00       	push   $0x3c2
f010269c:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01026a1:	e8 45 da ff ff       	call   f01000eb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026a6:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f01026ac:	8b 11                	mov    (%ecx),%edx
f01026ae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026b4:	89 d8                	mov    %ebx,%eax
f01026b6:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01026bc:	c1 f8 03             	sar    $0x3,%eax
f01026bf:	c1 e0 0c             	shl    $0xc,%eax
f01026c2:	39 c2                	cmp    %eax,%edx
f01026c4:	74 19                	je     f01026df <mem_init+0x1620>
f01026c6:	68 50 42 10 f0       	push   $0xf0104250
f01026cb:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01026d0:	68 c5 03 00 00       	push   $0x3c5
f01026d5:	68 d2 3c 10 f0       	push   $0xf0103cd2
f01026da:	e8 0c da ff ff       	call   f01000eb <_panic>
	kern_pgdir[0] = 0;
f01026df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026e5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026ea:	74 19                	je     f0102705 <mem_init+0x1646>
f01026ec:	68 cc 3e 10 f0       	push   $0xf0103ecc
f01026f1:	68 f8 3c 10 f0       	push   $0xf0103cf8
f01026f6:	68 c7 03 00 00       	push   $0x3c7
f01026fb:	68 d2 3c 10 f0       	push   $0xf0103cd2
f0102700:	e8 e6 d9 ff ff       	call   f01000eb <_panic>
	pp0->pp_ref = 0;
f0102705:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010270b:	83 ec 0c             	sub    $0xc,%esp
f010270e:	53                   	push   %ebx
f010270f:	e8 b0 e6 ff ff       	call   f0100dc4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102714:	c7 04 24 38 47 10 f0 	movl   $0xf0104738,(%esp)
f010271b:	e8 7d 00 00 00       	call   f010279d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102720:	83 c4 10             	add    $0x10,%esp
f0102723:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102726:	5b                   	pop    %ebx
f0102727:	5e                   	pop    %esi
f0102728:	5f                   	pop    %edi
f0102729:	5d                   	pop    %ebp
f010272a:	c3                   	ret    

f010272b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010272b:	55                   	push   %ebp
f010272c:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010272e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102731:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102734:	5d                   	pop    %ebp
f0102735:	c3                   	ret    

f0102736 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102736:	55                   	push   %ebp
f0102737:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102739:	ba 70 00 00 00       	mov    $0x70,%edx
f010273e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102741:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102742:	ba 71 00 00 00       	mov    $0x71,%edx
f0102747:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102748:	0f b6 c0             	movzbl %al,%eax
}
f010274b:	5d                   	pop    %ebp
f010274c:	c3                   	ret    

f010274d <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010274d:	55                   	push   %ebp
f010274e:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102750:	ba 70 00 00 00       	mov    $0x70,%edx
f0102755:	8b 45 08             	mov    0x8(%ebp),%eax
f0102758:	ee                   	out    %al,(%dx)
f0102759:	ba 71 00 00 00       	mov    $0x71,%edx
f010275e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102761:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102762:	5d                   	pop    %ebp
f0102763:	c3                   	ret    

f0102764 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102764:	55                   	push   %ebp
f0102765:	89 e5                	mov    %esp,%ebp
f0102767:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010276a:	ff 75 08             	pushl  0x8(%ebp)
f010276d:	e8 ee de ff ff       	call   f0100660 <cputchar>
	*cnt++;
}
f0102772:	83 c4 10             	add    $0x10,%esp
f0102775:	c9                   	leave  
f0102776:	c3                   	ret    

f0102777 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102777:	55                   	push   %ebp
f0102778:	89 e5                	mov    %esp,%ebp
f010277a:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010277d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102784:	ff 75 0c             	pushl  0xc(%ebp)
f0102787:	ff 75 08             	pushl  0x8(%ebp)
f010278a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010278d:	50                   	push   %eax
f010278e:	68 64 27 10 f0       	push   $0xf0102764
f0102793:	e8 08 04 00 00       	call   f0102ba0 <vprintfmt>
	return cnt;
}
f0102798:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010279b:	c9                   	leave  
f010279c:	c3                   	ret    

f010279d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010279d:	55                   	push   %ebp
f010279e:	89 e5                	mov    %esp,%ebp
f01027a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01027a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01027a6:	50                   	push   %eax
f01027a7:	ff 75 08             	pushl  0x8(%ebp)
f01027aa:	e8 c8 ff ff ff       	call   f0102777 <vcprintf>
	va_end(ap);

	return cnt;
}
f01027af:	c9                   	leave  
f01027b0:	c3                   	ret    

f01027b1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01027b1:	55                   	push   %ebp
f01027b2:	89 e5                	mov    %esp,%ebp
f01027b4:	57                   	push   %edi
f01027b5:	56                   	push   %esi
f01027b6:	53                   	push   %ebx
f01027b7:	83 ec 14             	sub    $0x14,%esp
f01027ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01027bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01027c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01027c6:	8b 1a                	mov    (%edx),%ebx
f01027c8:	8b 01                	mov    (%ecx),%eax
f01027ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027cd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01027d4:	eb 7f                	jmp    f0102855 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01027d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01027d9:	01 d8                	add    %ebx,%eax
f01027db:	89 c6                	mov    %eax,%esi
f01027dd:	c1 ee 1f             	shr    $0x1f,%esi
f01027e0:	01 c6                	add    %eax,%esi
f01027e2:	d1 fe                	sar    %esi
f01027e4:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01027e7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027ea:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01027ed:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027ef:	eb 03                	jmp    f01027f4 <stab_binsearch+0x43>
			m--;
f01027f1:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01027f4:	39 c3                	cmp    %eax,%ebx
f01027f6:	7f 0d                	jg     f0102805 <stab_binsearch+0x54>
f01027f8:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01027fc:	83 ea 0c             	sub    $0xc,%edx
f01027ff:	39 f9                	cmp    %edi,%ecx
f0102801:	75 ee                	jne    f01027f1 <stab_binsearch+0x40>
f0102803:	eb 05                	jmp    f010280a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102805:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102808:	eb 4b                	jmp    f0102855 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010280a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010280d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102810:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102814:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102817:	76 11                	jbe    f010282a <stab_binsearch+0x79>
			*region_left = m;
f0102819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010281c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010281e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102821:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102828:	eb 2b                	jmp    f0102855 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010282a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010282d:	73 14                	jae    f0102843 <stab_binsearch+0x92>
			*region_right = m - 1;
f010282f:	83 e8 01             	sub    $0x1,%eax
f0102832:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102835:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102838:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010283a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102841:	eb 12                	jmp    f0102855 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102843:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102846:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102848:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010284c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010284e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102855:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102858:	0f 8e 78 ff ff ff    	jle    f01027d6 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010285e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102862:	75 0f                	jne    f0102873 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102864:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102867:	8b 00                	mov    (%eax),%eax
f0102869:	83 e8 01             	sub    $0x1,%eax
f010286c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010286f:	89 06                	mov    %eax,(%esi)
f0102871:	eb 2c                	jmp    f010289f <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102873:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102876:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102878:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010287b:	8b 0e                	mov    (%esi),%ecx
f010287d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102880:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102883:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102886:	eb 03                	jmp    f010288b <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102888:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010288b:	39 c8                	cmp    %ecx,%eax
f010288d:	7e 0b                	jle    f010289a <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010288f:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102893:	83 ea 0c             	sub    $0xc,%edx
f0102896:	39 df                	cmp    %ebx,%edi
f0102898:	75 ee                	jne    f0102888 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f010289a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010289d:	89 06                	mov    %eax,(%esi)
	}
}
f010289f:	83 c4 14             	add    $0x14,%esp
f01028a2:	5b                   	pop    %ebx
f01028a3:	5e                   	pop    %esi
f01028a4:	5f                   	pop    %edi
f01028a5:	5d                   	pop    %ebp
f01028a6:	c3                   	ret    

f01028a7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01028a7:	55                   	push   %ebp
f01028a8:	89 e5                	mov    %esp,%ebp
f01028aa:	57                   	push   %edi
f01028ab:	56                   	push   %esi
f01028ac:	53                   	push   %ebx
f01028ad:	83 ec 3c             	sub    $0x3c,%esp
f01028b0:	8b 75 08             	mov    0x8(%ebp),%esi
f01028b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01028b6:	c7 03 64 47 10 f0    	movl   $0xf0104764,(%ebx)
	info->eip_line = 0;
f01028bc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01028c3:	c7 43 08 64 47 10 f0 	movl   $0xf0104764,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01028ca:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01028d1:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01028d4:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01028db:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01028e1:	76 11                	jbe    f01028f4 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028e3:	b8 fe c1 10 f0       	mov    $0xf010c1fe,%eax
f01028e8:	3d 11 a4 10 f0       	cmp    $0xf010a411,%eax
f01028ed:	77 19                	ja     f0102908 <debuginfo_eip+0x61>
f01028ef:	e9 a1 01 00 00       	jmp    f0102a95 <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01028f4:	83 ec 04             	sub    $0x4,%esp
f01028f7:	68 6e 47 10 f0       	push   $0xf010476e
f01028fc:	6a 7f                	push   $0x7f
f01028fe:	68 7b 47 10 f0       	push   $0xf010477b
f0102903:	e8 e3 d7 ff ff       	call   f01000eb <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102908:	80 3d fd c1 10 f0 00 	cmpb   $0x0,0xf010c1fd
f010290f:	0f 85 87 01 00 00    	jne    f0102a9c <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102915:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010291c:	b8 10 a4 10 f0       	mov    $0xf010a410,%eax
f0102921:	2d 98 49 10 f0       	sub    $0xf0104998,%eax
f0102926:	c1 f8 02             	sar    $0x2,%eax
f0102929:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010292f:	83 e8 01             	sub    $0x1,%eax
f0102932:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102935:	83 ec 08             	sub    $0x8,%esp
f0102938:	56                   	push   %esi
f0102939:	6a 64                	push   $0x64
f010293b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010293e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102941:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f0102946:	e8 66 fe ff ff       	call   f01027b1 <stab_binsearch>
	if (lfile == 0)
f010294b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010294e:	83 c4 10             	add    $0x10,%esp
f0102951:	85 c0                	test   %eax,%eax
f0102953:	0f 84 4a 01 00 00    	je     f0102aa3 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102959:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010295c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010295f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102962:	83 ec 08             	sub    $0x8,%esp
f0102965:	56                   	push   %esi
f0102966:	6a 24                	push   $0x24
f0102968:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010296b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010296e:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f0102973:	e8 39 fe ff ff       	call   f01027b1 <stab_binsearch>

	if (lfun <= rfun) {
f0102978:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010297b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010297e:	83 c4 10             	add    $0x10,%esp
f0102981:	39 d0                	cmp    %edx,%eax
f0102983:	7f 40                	jg     f01029c5 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102985:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102988:	c1 e1 02             	shl    $0x2,%ecx
f010298b:	8d b9 98 49 10 f0    	lea    -0xfefb668(%ecx),%edi
f0102991:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102994:	8b b9 98 49 10 f0    	mov    -0xfefb668(%ecx),%edi
f010299a:	b9 fe c1 10 f0       	mov    $0xf010c1fe,%ecx
f010299f:	81 e9 11 a4 10 f0    	sub    $0xf010a411,%ecx
f01029a5:	39 cf                	cmp    %ecx,%edi
f01029a7:	73 09                	jae    f01029b2 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01029a9:	81 c7 11 a4 10 f0    	add    $0xf010a411,%edi
f01029af:	89 7b 08             	mov    %edi,0x8(%ebx)
			
			
		info->eip_fn_addr = stabs[lfun].n_value;
f01029b2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01029b5:	8b 4f 08             	mov    0x8(%edi),%ecx
f01029b8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01029bb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01029bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01029c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01029c3:	eb 0f                	jmp    f01029d4 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01029c5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01029c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01029ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01029d4:	83 ec 08             	sub    $0x8,%esp
f01029d7:	6a 3a                	push   $0x3a
f01029d9:	ff 73 08             	pushl  0x8(%ebx)
f01029dc:	e8 f0 08 00 00       	call   f01032d1 <strfind>
f01029e1:	2b 43 08             	sub    0x8(%ebx),%eax
f01029e4:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01029e7:	83 c4 08             	add    $0x8,%esp
f01029ea:	56                   	push   %esi
f01029eb:	6a 44                	push   $0x44
f01029ed:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01029f0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01029f3:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f01029f8:	e8 b4 fd ff ff       	call   f01027b1 <stab_binsearch>
    info->eip_line=stabs[lline].n_desc;		
f01029fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a00:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a03:	8d 04 85 98 49 10 f0 	lea    -0xfefb668(,%eax,4),%eax
f0102a0a:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102a0e:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a11:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a14:	83 c4 10             	add    $0x10,%esp
f0102a17:	eb 06                	jmp    f0102a1f <debuginfo_eip+0x178>
f0102a19:	83 ea 01             	sub    $0x1,%edx
f0102a1c:	83 e8 0c             	sub    $0xc,%eax
f0102a1f:	39 d6                	cmp    %edx,%esi
f0102a21:	7f 34                	jg     f0102a57 <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0102a23:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102a27:	80 f9 84             	cmp    $0x84,%cl
f0102a2a:	74 0b                	je     f0102a37 <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102a2c:	80 f9 64             	cmp    $0x64,%cl
f0102a2f:	75 e8                	jne    f0102a19 <debuginfo_eip+0x172>
f0102a31:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a35:	74 e2                	je     f0102a19 <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a37:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a3a:	8b 14 85 98 49 10 f0 	mov    -0xfefb668(,%eax,4),%edx
f0102a41:	b8 fe c1 10 f0       	mov    $0xf010c1fe,%eax
f0102a46:	2d 11 a4 10 f0       	sub    $0xf010a411,%eax
f0102a4b:	39 c2                	cmp    %eax,%edx
f0102a4d:	73 08                	jae    f0102a57 <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a4f:	81 c2 11 a4 10 f0    	add    $0xf010a411,%edx
f0102a55:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a57:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a5a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102a5d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a62:	39 f2                	cmp    %esi,%edx
f0102a64:	7d 49                	jge    f0102aaf <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0102a66:	83 c2 01             	add    $0x1,%edx
f0102a69:	89 d0                	mov    %edx,%eax
f0102a6b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a6e:	8d 14 95 98 49 10 f0 	lea    -0xfefb668(,%edx,4),%edx
f0102a75:	eb 04                	jmp    f0102a7b <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
		     {
			info->eip_fn_narg++;
f0102a77:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102a7b:	39 c6                	cmp    %eax,%esi
f0102a7d:	7e 2b                	jle    f0102aaa <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a7f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102a83:	83 c0 01             	add    $0x1,%eax
f0102a86:	83 c2 0c             	add    $0xc,%edx
f0102a89:	80 f9 a0             	cmp    $0xa0,%cl
f0102a8c:	74 e9                	je     f0102a77 <debuginfo_eip+0x1d0>
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102a8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a93:	eb 1a                	jmp    f0102aaf <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a9a:	eb 13                	jmp    f0102aaf <debuginfo_eip+0x208>
f0102a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102aa1:	eb 0c                	jmp    f0102aaf <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102aa8:	eb 05                	jmp    f0102aaf <debuginfo_eip+0x208>
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102aaa:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102aaf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ab2:	5b                   	pop    %ebx
f0102ab3:	5e                   	pop    %esi
f0102ab4:	5f                   	pop    %edi
f0102ab5:	5d                   	pop    %ebp
f0102ab6:	c3                   	ret    

f0102ab7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102ab7:	55                   	push   %ebp
f0102ab8:	89 e5                	mov    %esp,%ebp
f0102aba:	57                   	push   %edi
f0102abb:	56                   	push   %esi
f0102abc:	53                   	push   %ebx
f0102abd:	83 ec 1c             	sub    $0x1c,%esp
f0102ac0:	89 c7                	mov    %eax,%edi
f0102ac2:	89 d6                	mov    %edx,%esi
f0102ac4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ac7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102aca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102acd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102ad3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ad8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102adb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102ade:	39 d3                	cmp    %edx,%ebx
f0102ae0:	72 05                	jb     f0102ae7 <printnum+0x30>
f0102ae2:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102ae5:	77 45                	ja     f0102b2c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102ae7:	83 ec 0c             	sub    $0xc,%esp
f0102aea:	ff 75 18             	pushl  0x18(%ebp)
f0102aed:	8b 45 14             	mov    0x14(%ebp),%eax
f0102af0:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102af3:	53                   	push   %ebx
f0102af4:	ff 75 10             	pushl  0x10(%ebp)
f0102af7:	83 ec 08             	sub    $0x8,%esp
f0102afa:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102afd:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b00:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b03:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b06:	e8 e5 09 00 00       	call   f01034f0 <__udivdi3>
f0102b0b:	83 c4 18             	add    $0x18,%esp
f0102b0e:	52                   	push   %edx
f0102b0f:	50                   	push   %eax
f0102b10:	89 f2                	mov    %esi,%edx
f0102b12:	89 f8                	mov    %edi,%eax
f0102b14:	e8 9e ff ff ff       	call   f0102ab7 <printnum>
f0102b19:	83 c4 20             	add    $0x20,%esp
f0102b1c:	eb 18                	jmp    f0102b36 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b1e:	83 ec 08             	sub    $0x8,%esp
f0102b21:	56                   	push   %esi
f0102b22:	ff 75 18             	pushl  0x18(%ebp)
f0102b25:	ff d7                	call   *%edi
f0102b27:	83 c4 10             	add    $0x10,%esp
f0102b2a:	eb 03                	jmp    f0102b2f <printnum+0x78>
f0102b2c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b2f:	83 eb 01             	sub    $0x1,%ebx
f0102b32:	85 db                	test   %ebx,%ebx
f0102b34:	7f e8                	jg     f0102b1e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b36:	83 ec 08             	sub    $0x8,%esp
f0102b39:	56                   	push   %esi
f0102b3a:	83 ec 04             	sub    $0x4,%esp
f0102b3d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b40:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b43:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b46:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b49:	e8 d2 0a 00 00       	call   f0103620 <__umoddi3>
f0102b4e:	83 c4 14             	add    $0x14,%esp
f0102b51:	0f be 80 89 47 10 f0 	movsbl -0xfefb877(%eax),%eax
f0102b58:	50                   	push   %eax
f0102b59:	ff d7                	call   *%edi
}
f0102b5b:	83 c4 10             	add    $0x10,%esp
f0102b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b61:	5b                   	pop    %ebx
f0102b62:	5e                   	pop    %esi
f0102b63:	5f                   	pop    %edi
f0102b64:	5d                   	pop    %ebp
f0102b65:	c3                   	ret    

f0102b66 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b66:	55                   	push   %ebp
f0102b67:	89 e5                	mov    %esp,%ebp
f0102b69:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b6c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102b70:	8b 10                	mov    (%eax),%edx
f0102b72:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b75:	73 0a                	jae    f0102b81 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102b77:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b7a:	89 08                	mov    %ecx,(%eax)
f0102b7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7f:	88 02                	mov    %al,(%edx)
}
f0102b81:	5d                   	pop    %ebp
f0102b82:	c3                   	ret    

f0102b83 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b83:	55                   	push   %ebp
f0102b84:	89 e5                	mov    %esp,%ebp
f0102b86:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b89:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b8c:	50                   	push   %eax
f0102b8d:	ff 75 10             	pushl  0x10(%ebp)
f0102b90:	ff 75 0c             	pushl  0xc(%ebp)
f0102b93:	ff 75 08             	pushl  0x8(%ebp)
f0102b96:	e8 05 00 00 00       	call   f0102ba0 <vprintfmt>
	va_end(ap);
}
f0102b9b:	83 c4 10             	add    $0x10,%esp
f0102b9e:	c9                   	leave  
f0102b9f:	c3                   	ret    

f0102ba0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102ba0:	55                   	push   %ebp
f0102ba1:	89 e5                	mov    %esp,%ebp
f0102ba3:	57                   	push   %edi
f0102ba4:	56                   	push   %esi
f0102ba5:	53                   	push   %ebx
f0102ba6:	83 ec 2c             	sub    $0x2c,%esp
f0102ba9:	8b 75 08             	mov    0x8(%ebp),%esi
f0102bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102baf:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102bb2:	eb 12                	jmp    f0102bc6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102bb4:	85 c0                	test   %eax,%eax
f0102bb6:	0f 84 6a 04 00 00    	je     f0103026 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
f0102bbc:	83 ec 08             	sub    $0x8,%esp
f0102bbf:	53                   	push   %ebx
f0102bc0:	50                   	push   %eax
f0102bc1:	ff d6                	call   *%esi
f0102bc3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102bc6:	83 c7 01             	add    $0x1,%edi
f0102bc9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102bcd:	83 f8 25             	cmp    $0x25,%eax
f0102bd0:	75 e2                	jne    f0102bb4 <vprintfmt+0x14>
f0102bd2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102bd6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102bdd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102be4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102beb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102bf0:	eb 07                	jmp    f0102bf9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102bf5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bf9:	8d 47 01             	lea    0x1(%edi),%eax
f0102bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102bff:	0f b6 07             	movzbl (%edi),%eax
f0102c02:	0f b6 d0             	movzbl %al,%edx
f0102c05:	83 e8 23             	sub    $0x23,%eax
f0102c08:	3c 55                	cmp    $0x55,%al
f0102c0a:	0f 87 fb 03 00 00    	ja     f010300b <vprintfmt+0x46b>
f0102c10:	0f b6 c0             	movzbl %al,%eax
f0102c13:	ff 24 85 14 48 10 f0 	jmp    *-0xfefb7ec(,%eax,4)
f0102c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102c1d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c21:	eb d6                	jmp    f0102bf9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102c2e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c31:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0102c35:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102c38:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102c3b:	83 f9 09             	cmp    $0x9,%ecx
f0102c3e:	77 3f                	ja     f0102c7f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c40:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102c43:	eb e9                	jmp    f0102c2e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c45:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c48:	8b 00                	mov    (%eax),%eax
f0102c4a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c50:	8d 40 04             	lea    0x4(%eax),%eax
f0102c53:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c59:	eb 2a                	jmp    f0102c85 <vprintfmt+0xe5>
f0102c5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c5e:	85 c0                	test   %eax,%eax
f0102c60:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c65:	0f 49 d0             	cmovns %eax,%edx
f0102c68:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c6e:	eb 89                	jmp    f0102bf9 <vprintfmt+0x59>
f0102c70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102c73:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102c7a:	e9 7a ff ff ff       	jmp    f0102bf9 <vprintfmt+0x59>
f0102c7f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102c82:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102c85:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c89:	0f 89 6a ff ff ff    	jns    f0102bf9 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102c8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102c95:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c9c:	e9 58 ff ff ff       	jmp    f0102bf9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102ca1:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ca4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102ca7:	e9 4d ff ff ff       	jmp    f0102bf9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102cac:	8b 45 14             	mov    0x14(%ebp),%eax
f0102caf:	8d 78 04             	lea    0x4(%eax),%edi
f0102cb2:	83 ec 08             	sub    $0x8,%esp
f0102cb5:	53                   	push   %ebx
f0102cb6:	ff 30                	pushl  (%eax)
f0102cb8:	ff d6                	call   *%esi
			break;
f0102cba:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102cbd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102cc3:	e9 fe fe ff ff       	jmp    f0102bc6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102cc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ccb:	8d 78 04             	lea    0x4(%eax),%edi
f0102cce:	8b 00                	mov    (%eax),%eax
f0102cd0:	99                   	cltd   
f0102cd1:	31 d0                	xor    %edx,%eax
f0102cd3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102cd5:	83 f8 06             	cmp    $0x6,%eax
f0102cd8:	7f 0b                	jg     f0102ce5 <vprintfmt+0x145>
f0102cda:	8b 14 85 6c 49 10 f0 	mov    -0xfefb694(,%eax,4),%edx
f0102ce1:	85 d2                	test   %edx,%edx
f0102ce3:	75 1b                	jne    f0102d00 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0102ce5:	50                   	push   %eax
f0102ce6:	68 a1 47 10 f0       	push   $0xf01047a1
f0102ceb:	53                   	push   %ebx
f0102cec:	56                   	push   %esi
f0102ced:	e8 91 fe ff ff       	call   f0102b83 <printfmt>
f0102cf2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102cf5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102cfb:	e9 c6 fe ff ff       	jmp    f0102bc6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102d00:	52                   	push   %edx
f0102d01:	68 0a 3d 10 f0       	push   $0xf0103d0a
f0102d06:	53                   	push   %ebx
f0102d07:	56                   	push   %esi
f0102d08:	e8 76 fe ff ff       	call   f0102b83 <printfmt>
f0102d0d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d10:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d16:	e9 ab fe ff ff       	jmp    f0102bc6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102d1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d1e:	83 c0 04             	add    $0x4,%eax
f0102d21:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102d24:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d27:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102d29:	85 ff                	test   %edi,%edi
f0102d2b:	b8 9a 47 10 f0       	mov    $0xf010479a,%eax
f0102d30:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102d33:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d37:	0f 8e 94 00 00 00    	jle    f0102dd1 <vprintfmt+0x231>
f0102d3d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d41:	0f 84 98 00 00 00    	je     f0102ddf <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d47:	83 ec 08             	sub    $0x8,%esp
f0102d4a:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d4d:	57                   	push   %edi
f0102d4e:	e8 34 04 00 00       	call   f0103187 <strnlen>
f0102d53:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d56:	29 c1                	sub    %eax,%ecx
f0102d58:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102d5b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102d5e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d62:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d65:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d68:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d6a:	eb 0f                	jmp    f0102d7b <vprintfmt+0x1db>
					putch(padc, putdat);
f0102d6c:	83 ec 08             	sub    $0x8,%esp
f0102d6f:	53                   	push   %ebx
f0102d70:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d73:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d75:	83 ef 01             	sub    $0x1,%edi
f0102d78:	83 c4 10             	add    $0x10,%esp
f0102d7b:	85 ff                	test   %edi,%edi
f0102d7d:	7f ed                	jg     f0102d6c <vprintfmt+0x1cc>
f0102d7f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d82:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102d85:	85 c9                	test   %ecx,%ecx
f0102d87:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d8c:	0f 49 c1             	cmovns %ecx,%eax
f0102d8f:	29 c1                	sub    %eax,%ecx
f0102d91:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d94:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d97:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d9a:	89 cb                	mov    %ecx,%ebx
f0102d9c:	eb 4d                	jmp    f0102deb <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102d9e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102da2:	74 1b                	je     f0102dbf <vprintfmt+0x21f>
f0102da4:	0f be c0             	movsbl %al,%eax
f0102da7:	83 e8 20             	sub    $0x20,%eax
f0102daa:	83 f8 5e             	cmp    $0x5e,%eax
f0102dad:	76 10                	jbe    f0102dbf <vprintfmt+0x21f>
					putch('?', putdat);
f0102daf:	83 ec 08             	sub    $0x8,%esp
f0102db2:	ff 75 0c             	pushl  0xc(%ebp)
f0102db5:	6a 3f                	push   $0x3f
f0102db7:	ff 55 08             	call   *0x8(%ebp)
f0102dba:	83 c4 10             	add    $0x10,%esp
f0102dbd:	eb 0d                	jmp    f0102dcc <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0102dbf:	83 ec 08             	sub    $0x8,%esp
f0102dc2:	ff 75 0c             	pushl  0xc(%ebp)
f0102dc5:	52                   	push   %edx
f0102dc6:	ff 55 08             	call   *0x8(%ebp)
f0102dc9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102dcc:	83 eb 01             	sub    $0x1,%ebx
f0102dcf:	eb 1a                	jmp    f0102deb <vprintfmt+0x24b>
f0102dd1:	89 75 08             	mov    %esi,0x8(%ebp)
f0102dd4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dd7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102dda:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102ddd:	eb 0c                	jmp    f0102deb <vprintfmt+0x24b>
f0102ddf:	89 75 08             	mov    %esi,0x8(%ebp)
f0102de2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102de5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102de8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102deb:	83 c7 01             	add    $0x1,%edi
f0102dee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102df2:	0f be d0             	movsbl %al,%edx
f0102df5:	85 d2                	test   %edx,%edx
f0102df7:	74 23                	je     f0102e1c <vprintfmt+0x27c>
f0102df9:	85 f6                	test   %esi,%esi
f0102dfb:	78 a1                	js     f0102d9e <vprintfmt+0x1fe>
f0102dfd:	83 ee 01             	sub    $0x1,%esi
f0102e00:	79 9c                	jns    f0102d9e <vprintfmt+0x1fe>
f0102e02:	89 df                	mov    %ebx,%edi
f0102e04:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e0a:	eb 18                	jmp    f0102e24 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102e0c:	83 ec 08             	sub    $0x8,%esp
f0102e0f:	53                   	push   %ebx
f0102e10:	6a 20                	push   $0x20
f0102e12:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102e14:	83 ef 01             	sub    $0x1,%edi
f0102e17:	83 c4 10             	add    $0x10,%esp
f0102e1a:	eb 08                	jmp    f0102e24 <vprintfmt+0x284>
f0102e1c:	89 df                	mov    %ebx,%edi
f0102e1e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e24:	85 ff                	test   %edi,%edi
f0102e26:	7f e4                	jg     f0102e0c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102e28:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e2b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e31:	e9 90 fd ff ff       	jmp    f0102bc6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e36:	83 f9 01             	cmp    $0x1,%ecx
f0102e39:	7e 19                	jle    f0102e54 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0102e3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e3e:	8b 50 04             	mov    0x4(%eax),%edx
f0102e41:	8b 00                	mov    (%eax),%eax
f0102e43:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e46:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e49:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e4c:	8d 40 08             	lea    0x8(%eax),%eax
f0102e4f:	89 45 14             	mov    %eax,0x14(%ebp)
f0102e52:	eb 38                	jmp    f0102e8c <vprintfmt+0x2ec>
	else if (lflag)
f0102e54:	85 c9                	test   %ecx,%ecx
f0102e56:	74 1b                	je     f0102e73 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0102e58:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e5b:	8b 00                	mov    (%eax),%eax
f0102e5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e60:	89 c1                	mov    %eax,%ecx
f0102e62:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e65:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e68:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e6b:	8d 40 04             	lea    0x4(%eax),%eax
f0102e6e:	89 45 14             	mov    %eax,0x14(%ebp)
f0102e71:	eb 19                	jmp    f0102e8c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0102e73:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e76:	8b 00                	mov    (%eax),%eax
f0102e78:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e7b:	89 c1                	mov    %eax,%ecx
f0102e7d:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e80:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e83:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e86:	8d 40 04             	lea    0x4(%eax),%eax
f0102e89:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102e8c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e8f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102e92:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102e97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102e9b:	0f 89 36 01 00 00    	jns    f0102fd7 <vprintfmt+0x437>
				putch('-', putdat);
f0102ea1:	83 ec 08             	sub    $0x8,%esp
f0102ea4:	53                   	push   %ebx
f0102ea5:	6a 2d                	push   $0x2d
f0102ea7:	ff d6                	call   *%esi
				num = -(long long) num;
f0102ea9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102eac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102eaf:	f7 da                	neg    %edx
f0102eb1:	83 d1 00             	adc    $0x0,%ecx
f0102eb4:	f7 d9                	neg    %ecx
f0102eb6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102eb9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102ebe:	e9 14 01 00 00       	jmp    f0102fd7 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102ec3:	83 f9 01             	cmp    $0x1,%ecx
f0102ec6:	7e 18                	jle    f0102ee0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0102ec8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ecb:	8b 10                	mov    (%eax),%edx
f0102ecd:	8b 48 04             	mov    0x4(%eax),%ecx
f0102ed0:	8d 40 08             	lea    0x8(%eax),%eax
f0102ed3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102ed6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102edb:	e9 f7 00 00 00       	jmp    f0102fd7 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102ee0:	85 c9                	test   %ecx,%ecx
f0102ee2:	74 1a                	je     f0102efe <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0102ee4:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ee7:	8b 10                	mov    (%eax),%edx
f0102ee9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102eee:	8d 40 04             	lea    0x4(%eax),%eax
f0102ef1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102ef4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102ef9:	e9 d9 00 00 00       	jmp    f0102fd7 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102efe:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f01:	8b 10                	mov    (%eax),%edx
f0102f03:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102f08:	8d 40 04             	lea    0x4(%eax),%eax
f0102f0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f0e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102f13:	e9 bf 00 00 00       	jmp    f0102fd7 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f18:	83 f9 01             	cmp    $0x1,%ecx
f0102f1b:	7e 13                	jle    f0102f30 <vprintfmt+0x390>
		return va_arg(*ap, long long);
f0102f1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f20:	8b 50 04             	mov    0x4(%eax),%edx
f0102f23:	8b 00                	mov    (%eax),%eax
f0102f25:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f28:	8d 49 08             	lea    0x8(%ecx),%ecx
f0102f2b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102f2e:	eb 28                	jmp    f0102f58 <vprintfmt+0x3b8>
	else if (lflag)
f0102f30:	85 c9                	test   %ecx,%ecx
f0102f32:	74 13                	je     f0102f47 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
f0102f34:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f37:	8b 10                	mov    (%eax),%edx
f0102f39:	89 d0                	mov    %edx,%eax
f0102f3b:	99                   	cltd   
f0102f3c:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f3f:	8d 49 04             	lea    0x4(%ecx),%ecx
f0102f42:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102f45:	eb 11                	jmp    f0102f58 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
f0102f47:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f4a:	8b 10                	mov    (%eax),%edx
f0102f4c:	89 d0                	mov    %edx,%eax
f0102f4e:	99                   	cltd   
f0102f4f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f52:	8d 49 04             	lea    0x4(%ecx),%ecx
f0102f55:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f0102f58:	89 d1                	mov    %edx,%ecx
f0102f5a:	89 c2                	mov    %eax,%edx
			base = 8;
f0102f5c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0102f61:	eb 74                	jmp    f0102fd7 <vprintfmt+0x437>

		// pointer
		case 'p':
			putch('0', putdat);
f0102f63:	83 ec 08             	sub    $0x8,%esp
f0102f66:	53                   	push   %ebx
f0102f67:	6a 30                	push   $0x30
f0102f69:	ff d6                	call   *%esi
			putch('x', putdat);
f0102f6b:	83 c4 08             	add    $0x8,%esp
f0102f6e:	53                   	push   %ebx
f0102f6f:	6a 78                	push   $0x78
f0102f71:	ff d6                	call   *%esi
			num = (unsigned long long)
f0102f73:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f76:	8b 10                	mov    (%eax),%edx
f0102f78:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102f7d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102f80:	8d 40 04             	lea    0x4(%eax),%eax
f0102f83:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102f86:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102f8b:	eb 4a                	jmp    f0102fd7 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f8d:	83 f9 01             	cmp    $0x1,%ecx
f0102f90:	7e 15                	jle    f0102fa7 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
f0102f92:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f95:	8b 10                	mov    (%eax),%edx
f0102f97:	8b 48 04             	mov    0x4(%eax),%ecx
f0102f9a:	8d 40 08             	lea    0x8(%eax),%eax
f0102f9d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fa0:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fa5:	eb 30                	jmp    f0102fd7 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102fa7:	85 c9                	test   %ecx,%ecx
f0102fa9:	74 17                	je     f0102fc2 <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
f0102fab:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fae:	8b 10                	mov    (%eax),%edx
f0102fb0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fb5:	8d 40 04             	lea    0x4(%eax),%eax
f0102fb8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fbb:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fc0:	eb 15                	jmp    f0102fd7 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102fc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fc5:	8b 10                	mov    (%eax),%edx
f0102fc7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fcc:	8d 40 04             	lea    0x4(%eax),%eax
f0102fcf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fd2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102fd7:	83 ec 0c             	sub    $0xc,%esp
f0102fda:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102fde:	57                   	push   %edi
f0102fdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0102fe2:	50                   	push   %eax
f0102fe3:	51                   	push   %ecx
f0102fe4:	52                   	push   %edx
f0102fe5:	89 da                	mov    %ebx,%edx
f0102fe7:	89 f0                	mov    %esi,%eax
f0102fe9:	e8 c9 fa ff ff       	call   f0102ab7 <printnum>
			break;
f0102fee:	83 c4 20             	add    $0x20,%esp
f0102ff1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ff4:	e9 cd fb ff ff       	jmp    f0102bc6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102ff9:	83 ec 08             	sub    $0x8,%esp
f0102ffc:	53                   	push   %ebx
f0102ffd:	52                   	push   %edx
f0102ffe:	ff d6                	call   *%esi
			break;
f0103000:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103003:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103006:	e9 bb fb ff ff       	jmp    f0102bc6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010300b:	83 ec 08             	sub    $0x8,%esp
f010300e:	53                   	push   %ebx
f010300f:	6a 25                	push   $0x25
f0103011:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103013:	83 c4 10             	add    $0x10,%esp
f0103016:	eb 03                	jmp    f010301b <vprintfmt+0x47b>
f0103018:	83 ef 01             	sub    $0x1,%edi
f010301b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010301f:	75 f7                	jne    f0103018 <vprintfmt+0x478>
f0103021:	e9 a0 fb ff ff       	jmp    f0102bc6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103026:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103029:	5b                   	pop    %ebx
f010302a:	5e                   	pop    %esi
f010302b:	5f                   	pop    %edi
f010302c:	5d                   	pop    %ebp
f010302d:	c3                   	ret    

f010302e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010302e:	55                   	push   %ebp
f010302f:	89 e5                	mov    %esp,%ebp
f0103031:	83 ec 18             	sub    $0x18,%esp
f0103034:	8b 45 08             	mov    0x8(%ebp),%eax
f0103037:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010303a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010303d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103041:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010304b:	85 c0                	test   %eax,%eax
f010304d:	74 26                	je     f0103075 <vsnprintf+0x47>
f010304f:	85 d2                	test   %edx,%edx
f0103051:	7e 22                	jle    f0103075 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103053:	ff 75 14             	pushl  0x14(%ebp)
f0103056:	ff 75 10             	pushl  0x10(%ebp)
f0103059:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010305c:	50                   	push   %eax
f010305d:	68 66 2b 10 f0       	push   $0xf0102b66
f0103062:	e8 39 fb ff ff       	call   f0102ba0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103067:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010306a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010306d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103070:	83 c4 10             	add    $0x10,%esp
f0103073:	eb 05                	jmp    f010307a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103075:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010307a:	c9                   	leave  
f010307b:	c3                   	ret    

f010307c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103082:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103085:	50                   	push   %eax
f0103086:	ff 75 10             	pushl  0x10(%ebp)
f0103089:	ff 75 0c             	pushl  0xc(%ebp)
f010308c:	ff 75 08             	pushl  0x8(%ebp)
f010308f:	e8 9a ff ff ff       	call   f010302e <vsnprintf>
	va_end(ap);

	return rc;
}
f0103094:	c9                   	leave  
f0103095:	c3                   	ret    

f0103096 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103096:	55                   	push   %ebp
f0103097:	89 e5                	mov    %esp,%ebp
f0103099:	57                   	push   %edi
f010309a:	56                   	push   %esi
f010309b:	53                   	push   %ebx
f010309c:	83 ec 0c             	sub    $0xc,%esp
f010309f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01030a2:	85 c0                	test   %eax,%eax
f01030a4:	74 11                	je     f01030b7 <readline+0x21>
		cprintf("%s", prompt);
f01030a6:	83 ec 08             	sub    $0x8,%esp
f01030a9:	50                   	push   %eax
f01030aa:	68 0a 3d 10 f0       	push   $0xf0103d0a
f01030af:	e8 e9 f6 ff ff       	call   f010279d <cprintf>
f01030b4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01030b7:	83 ec 0c             	sub    $0xc,%esp
f01030ba:	6a 00                	push   $0x0
f01030bc:	e8 c0 d5 ff ff       	call   f0100681 <iscons>
f01030c1:	89 c7                	mov    %eax,%edi
f01030c3:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01030c6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01030cb:	e8 a0 d5 ff ff       	call   f0100670 <getchar>
f01030d0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01030d2:	85 c0                	test   %eax,%eax
f01030d4:	79 18                	jns    f01030ee <readline+0x58>
			cprintf("read error: %e\n", c);
f01030d6:	83 ec 08             	sub    $0x8,%esp
f01030d9:	50                   	push   %eax
f01030da:	68 88 49 10 f0       	push   $0xf0104988
f01030df:	e8 b9 f6 ff ff       	call   f010279d <cprintf>
			return NULL;
f01030e4:	83 c4 10             	add    $0x10,%esp
f01030e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ec:	eb 79                	jmp    f0103167 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030ee:	83 f8 08             	cmp    $0x8,%eax
f01030f1:	0f 94 c2             	sete   %dl
f01030f4:	83 f8 7f             	cmp    $0x7f,%eax
f01030f7:	0f 94 c0             	sete   %al
f01030fa:	08 c2                	or     %al,%dl
f01030fc:	74 1a                	je     f0103118 <readline+0x82>
f01030fe:	85 f6                	test   %esi,%esi
f0103100:	7e 16                	jle    f0103118 <readline+0x82>
			if (echoing)
f0103102:	85 ff                	test   %edi,%edi
f0103104:	74 0d                	je     f0103113 <readline+0x7d>
				cputchar('\b');
f0103106:	83 ec 0c             	sub    $0xc,%esp
f0103109:	6a 08                	push   $0x8
f010310b:	e8 50 d5 ff ff       	call   f0100660 <cputchar>
f0103110:	83 c4 10             	add    $0x10,%esp
			i--;
f0103113:	83 ee 01             	sub    $0x1,%esi
f0103116:	eb b3                	jmp    f01030cb <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103118:	83 fb 1f             	cmp    $0x1f,%ebx
f010311b:	7e 23                	jle    f0103140 <readline+0xaa>
f010311d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103123:	7f 1b                	jg     f0103140 <readline+0xaa>
			if (echoing)
f0103125:	85 ff                	test   %edi,%edi
f0103127:	74 0c                	je     f0103135 <readline+0x9f>
				cputchar(c);
f0103129:	83 ec 0c             	sub    $0xc,%esp
f010312c:	53                   	push   %ebx
f010312d:	e8 2e d5 ff ff       	call   f0100660 <cputchar>
f0103132:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103135:	88 9e 40 75 11 f0    	mov    %bl,-0xfee8ac0(%esi)
f010313b:	8d 76 01             	lea    0x1(%esi),%esi
f010313e:	eb 8b                	jmp    f01030cb <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103140:	83 fb 0a             	cmp    $0xa,%ebx
f0103143:	74 05                	je     f010314a <readline+0xb4>
f0103145:	83 fb 0d             	cmp    $0xd,%ebx
f0103148:	75 81                	jne    f01030cb <readline+0x35>
			if (echoing)
f010314a:	85 ff                	test   %edi,%edi
f010314c:	74 0d                	je     f010315b <readline+0xc5>
				cputchar('\n');
f010314e:	83 ec 0c             	sub    $0xc,%esp
f0103151:	6a 0a                	push   $0xa
f0103153:	e8 08 d5 ff ff       	call   f0100660 <cputchar>
f0103158:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010315b:	c6 86 40 75 11 f0 00 	movb   $0x0,-0xfee8ac0(%esi)
			return buf;
f0103162:	b8 40 75 11 f0       	mov    $0xf0117540,%eax
		}
	}
}
f0103167:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010316a:	5b                   	pop    %ebx
f010316b:	5e                   	pop    %esi
f010316c:	5f                   	pop    %edi
f010316d:	5d                   	pop    %ebp
f010316e:	c3                   	ret    

f010316f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010316f:	55                   	push   %ebp
f0103170:	89 e5                	mov    %esp,%ebp
f0103172:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103175:	b8 00 00 00 00       	mov    $0x0,%eax
f010317a:	eb 03                	jmp    f010317f <strlen+0x10>
		n++;
f010317c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010317f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103183:	75 f7                	jne    f010317c <strlen+0xd>
		n++;
	return n;
}
f0103185:	5d                   	pop    %ebp
f0103186:	c3                   	ret    

f0103187 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103187:	55                   	push   %ebp
f0103188:	89 e5                	mov    %esp,%ebp
f010318a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010318d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103190:	ba 00 00 00 00       	mov    $0x0,%edx
f0103195:	eb 03                	jmp    f010319a <strnlen+0x13>
		n++;
f0103197:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010319a:	39 c2                	cmp    %eax,%edx
f010319c:	74 08                	je     f01031a6 <strnlen+0x1f>
f010319e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01031a2:	75 f3                	jne    f0103197 <strnlen+0x10>
f01031a4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01031a6:	5d                   	pop    %ebp
f01031a7:	c3                   	ret    

f01031a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01031a8:	55                   	push   %ebp
f01031a9:	89 e5                	mov    %esp,%ebp
f01031ab:	53                   	push   %ebx
f01031ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01031af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01031b2:	89 c2                	mov    %eax,%edx
f01031b4:	83 c2 01             	add    $0x1,%edx
f01031b7:	83 c1 01             	add    $0x1,%ecx
f01031ba:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01031be:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031c1:	84 db                	test   %bl,%bl
f01031c3:	75 ef                	jne    f01031b4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01031c5:	5b                   	pop    %ebx
f01031c6:	5d                   	pop    %ebp
f01031c7:	c3                   	ret    

f01031c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01031c8:	55                   	push   %ebp
f01031c9:	89 e5                	mov    %esp,%ebp
f01031cb:	53                   	push   %ebx
f01031cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01031cf:	53                   	push   %ebx
f01031d0:	e8 9a ff ff ff       	call   f010316f <strlen>
f01031d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01031d8:	ff 75 0c             	pushl  0xc(%ebp)
f01031db:	01 d8                	add    %ebx,%eax
f01031dd:	50                   	push   %eax
f01031de:	e8 c5 ff ff ff       	call   f01031a8 <strcpy>
	return dst;
}
f01031e3:	89 d8                	mov    %ebx,%eax
f01031e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031e8:	c9                   	leave  
f01031e9:	c3                   	ret    

f01031ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01031ea:	55                   	push   %ebp
f01031eb:	89 e5                	mov    %esp,%ebp
f01031ed:	56                   	push   %esi
f01031ee:	53                   	push   %ebx
f01031ef:	8b 75 08             	mov    0x8(%ebp),%esi
f01031f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031f5:	89 f3                	mov    %esi,%ebx
f01031f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01031fa:	89 f2                	mov    %esi,%edx
f01031fc:	eb 0f                	jmp    f010320d <strncpy+0x23>
		*dst++ = *src;
f01031fe:	83 c2 01             	add    $0x1,%edx
f0103201:	0f b6 01             	movzbl (%ecx),%eax
f0103204:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103207:	80 39 01             	cmpb   $0x1,(%ecx)
f010320a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010320d:	39 da                	cmp    %ebx,%edx
f010320f:	75 ed                	jne    f01031fe <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103211:	89 f0                	mov    %esi,%eax
f0103213:	5b                   	pop    %ebx
f0103214:	5e                   	pop    %esi
f0103215:	5d                   	pop    %ebp
f0103216:	c3                   	ret    

f0103217 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103217:	55                   	push   %ebp
f0103218:	89 e5                	mov    %esp,%ebp
f010321a:	56                   	push   %esi
f010321b:	53                   	push   %ebx
f010321c:	8b 75 08             	mov    0x8(%ebp),%esi
f010321f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103222:	8b 55 10             	mov    0x10(%ebp),%edx
f0103225:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103227:	85 d2                	test   %edx,%edx
f0103229:	74 21                	je     f010324c <strlcpy+0x35>
f010322b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010322f:	89 f2                	mov    %esi,%edx
f0103231:	eb 09                	jmp    f010323c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103233:	83 c2 01             	add    $0x1,%edx
f0103236:	83 c1 01             	add    $0x1,%ecx
f0103239:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010323c:	39 c2                	cmp    %eax,%edx
f010323e:	74 09                	je     f0103249 <strlcpy+0x32>
f0103240:	0f b6 19             	movzbl (%ecx),%ebx
f0103243:	84 db                	test   %bl,%bl
f0103245:	75 ec                	jne    f0103233 <strlcpy+0x1c>
f0103247:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103249:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010324c:	29 f0                	sub    %esi,%eax
}
f010324e:	5b                   	pop    %ebx
f010324f:	5e                   	pop    %esi
f0103250:	5d                   	pop    %ebp
f0103251:	c3                   	ret    

f0103252 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103252:	55                   	push   %ebp
f0103253:	89 e5                	mov    %esp,%ebp
f0103255:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103258:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010325b:	eb 06                	jmp    f0103263 <strcmp+0x11>
		p++, q++;
f010325d:	83 c1 01             	add    $0x1,%ecx
f0103260:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103263:	0f b6 01             	movzbl (%ecx),%eax
f0103266:	84 c0                	test   %al,%al
f0103268:	74 04                	je     f010326e <strcmp+0x1c>
f010326a:	3a 02                	cmp    (%edx),%al
f010326c:	74 ef                	je     f010325d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010326e:	0f b6 c0             	movzbl %al,%eax
f0103271:	0f b6 12             	movzbl (%edx),%edx
f0103274:	29 d0                	sub    %edx,%eax
}
f0103276:	5d                   	pop    %ebp
f0103277:	c3                   	ret    

f0103278 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103278:	55                   	push   %ebp
f0103279:	89 e5                	mov    %esp,%ebp
f010327b:	53                   	push   %ebx
f010327c:	8b 45 08             	mov    0x8(%ebp),%eax
f010327f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103282:	89 c3                	mov    %eax,%ebx
f0103284:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103287:	eb 06                	jmp    f010328f <strncmp+0x17>
		n--, p++, q++;
f0103289:	83 c0 01             	add    $0x1,%eax
f010328c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010328f:	39 d8                	cmp    %ebx,%eax
f0103291:	74 15                	je     f01032a8 <strncmp+0x30>
f0103293:	0f b6 08             	movzbl (%eax),%ecx
f0103296:	84 c9                	test   %cl,%cl
f0103298:	74 04                	je     f010329e <strncmp+0x26>
f010329a:	3a 0a                	cmp    (%edx),%cl
f010329c:	74 eb                	je     f0103289 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010329e:	0f b6 00             	movzbl (%eax),%eax
f01032a1:	0f b6 12             	movzbl (%edx),%edx
f01032a4:	29 d0                	sub    %edx,%eax
f01032a6:	eb 05                	jmp    f01032ad <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01032a8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01032ad:	5b                   	pop    %ebx
f01032ae:	5d                   	pop    %ebp
f01032af:	c3                   	ret    

f01032b0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01032b0:	55                   	push   %ebp
f01032b1:	89 e5                	mov    %esp,%ebp
f01032b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032ba:	eb 07                	jmp    f01032c3 <strchr+0x13>
		if (*s == c)
f01032bc:	38 ca                	cmp    %cl,%dl
f01032be:	74 0f                	je     f01032cf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01032c0:	83 c0 01             	add    $0x1,%eax
f01032c3:	0f b6 10             	movzbl (%eax),%edx
f01032c6:	84 d2                	test   %dl,%dl
f01032c8:	75 f2                	jne    f01032bc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01032ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032cf:	5d                   	pop    %ebp
f01032d0:	c3                   	ret    

f01032d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01032d1:	55                   	push   %ebp
f01032d2:	89 e5                	mov    %esp,%ebp
f01032d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032db:	eb 03                	jmp    f01032e0 <strfind+0xf>
f01032dd:	83 c0 01             	add    $0x1,%eax
f01032e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01032e3:	38 ca                	cmp    %cl,%dl
f01032e5:	74 04                	je     f01032eb <strfind+0x1a>
f01032e7:	84 d2                	test   %dl,%dl
f01032e9:	75 f2                	jne    f01032dd <strfind+0xc>
			break;
	return (char *) s;
}
f01032eb:	5d                   	pop    %ebp
f01032ec:	c3                   	ret    

f01032ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01032ed:	55                   	push   %ebp
f01032ee:	89 e5                	mov    %esp,%ebp
f01032f0:	57                   	push   %edi
f01032f1:	56                   	push   %esi
f01032f2:	53                   	push   %ebx
f01032f3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01032f9:	85 c9                	test   %ecx,%ecx
f01032fb:	74 36                	je     f0103333 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01032fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103303:	75 28                	jne    f010332d <memset+0x40>
f0103305:	f6 c1 03             	test   $0x3,%cl
f0103308:	75 23                	jne    f010332d <memset+0x40>
		c &= 0xFF;
f010330a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010330e:	89 d3                	mov    %edx,%ebx
f0103310:	c1 e3 08             	shl    $0x8,%ebx
f0103313:	89 d6                	mov    %edx,%esi
f0103315:	c1 e6 18             	shl    $0x18,%esi
f0103318:	89 d0                	mov    %edx,%eax
f010331a:	c1 e0 10             	shl    $0x10,%eax
f010331d:	09 f0                	or     %esi,%eax
f010331f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103321:	89 d8                	mov    %ebx,%eax
f0103323:	09 d0                	or     %edx,%eax
f0103325:	c1 e9 02             	shr    $0x2,%ecx
f0103328:	fc                   	cld    
f0103329:	f3 ab                	rep stos %eax,%es:(%edi)
f010332b:	eb 06                	jmp    f0103333 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010332d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103330:	fc                   	cld    
f0103331:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103333:	89 f8                	mov    %edi,%eax
f0103335:	5b                   	pop    %ebx
f0103336:	5e                   	pop    %esi
f0103337:	5f                   	pop    %edi
f0103338:	5d                   	pop    %ebp
f0103339:	c3                   	ret    

f010333a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010333a:	55                   	push   %ebp
f010333b:	89 e5                	mov    %esp,%ebp
f010333d:	57                   	push   %edi
f010333e:	56                   	push   %esi
f010333f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103342:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103345:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103348:	39 c6                	cmp    %eax,%esi
f010334a:	73 35                	jae    f0103381 <memmove+0x47>
f010334c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010334f:	39 d0                	cmp    %edx,%eax
f0103351:	73 2e                	jae    f0103381 <memmove+0x47>
		s += n;
		d += n;
f0103353:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103356:	89 d6                	mov    %edx,%esi
f0103358:	09 fe                	or     %edi,%esi
f010335a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103360:	75 13                	jne    f0103375 <memmove+0x3b>
f0103362:	f6 c1 03             	test   $0x3,%cl
f0103365:	75 0e                	jne    f0103375 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103367:	83 ef 04             	sub    $0x4,%edi
f010336a:	8d 72 fc             	lea    -0x4(%edx),%esi
f010336d:	c1 e9 02             	shr    $0x2,%ecx
f0103370:	fd                   	std    
f0103371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103373:	eb 09                	jmp    f010337e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103375:	83 ef 01             	sub    $0x1,%edi
f0103378:	8d 72 ff             	lea    -0x1(%edx),%esi
f010337b:	fd                   	std    
f010337c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010337e:	fc                   	cld    
f010337f:	eb 1d                	jmp    f010339e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103381:	89 f2                	mov    %esi,%edx
f0103383:	09 c2                	or     %eax,%edx
f0103385:	f6 c2 03             	test   $0x3,%dl
f0103388:	75 0f                	jne    f0103399 <memmove+0x5f>
f010338a:	f6 c1 03             	test   $0x3,%cl
f010338d:	75 0a                	jne    f0103399 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010338f:	c1 e9 02             	shr    $0x2,%ecx
f0103392:	89 c7                	mov    %eax,%edi
f0103394:	fc                   	cld    
f0103395:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103397:	eb 05                	jmp    f010339e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103399:	89 c7                	mov    %eax,%edi
f010339b:	fc                   	cld    
f010339c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010339e:	5e                   	pop    %esi
f010339f:	5f                   	pop    %edi
f01033a0:	5d                   	pop    %ebp
f01033a1:	c3                   	ret    

f01033a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01033a2:	55                   	push   %ebp
f01033a3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01033a5:	ff 75 10             	pushl  0x10(%ebp)
f01033a8:	ff 75 0c             	pushl  0xc(%ebp)
f01033ab:	ff 75 08             	pushl  0x8(%ebp)
f01033ae:	e8 87 ff ff ff       	call   f010333a <memmove>
}
f01033b3:	c9                   	leave  
f01033b4:	c3                   	ret    

f01033b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01033b5:	55                   	push   %ebp
f01033b6:	89 e5                	mov    %esp,%ebp
f01033b8:	56                   	push   %esi
f01033b9:	53                   	push   %ebx
f01033ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01033bd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033c0:	89 c6                	mov    %eax,%esi
f01033c2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033c5:	eb 1a                	jmp    f01033e1 <memcmp+0x2c>
		if (*s1 != *s2)
f01033c7:	0f b6 08             	movzbl (%eax),%ecx
f01033ca:	0f b6 1a             	movzbl (%edx),%ebx
f01033cd:	38 d9                	cmp    %bl,%cl
f01033cf:	74 0a                	je     f01033db <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01033d1:	0f b6 c1             	movzbl %cl,%eax
f01033d4:	0f b6 db             	movzbl %bl,%ebx
f01033d7:	29 d8                	sub    %ebx,%eax
f01033d9:	eb 0f                	jmp    f01033ea <memcmp+0x35>
		s1++, s2++;
f01033db:	83 c0 01             	add    $0x1,%eax
f01033de:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033e1:	39 f0                	cmp    %esi,%eax
f01033e3:	75 e2                	jne    f01033c7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01033e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033ea:	5b                   	pop    %ebx
f01033eb:	5e                   	pop    %esi
f01033ec:	5d                   	pop    %ebp
f01033ed:	c3                   	ret    

f01033ee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01033ee:	55                   	push   %ebp
f01033ef:	89 e5                	mov    %esp,%ebp
f01033f1:	53                   	push   %ebx
f01033f2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01033f5:	89 c1                	mov    %eax,%ecx
f01033f7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01033fa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033fe:	eb 0a                	jmp    f010340a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103400:	0f b6 10             	movzbl (%eax),%edx
f0103403:	39 da                	cmp    %ebx,%edx
f0103405:	74 07                	je     f010340e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103407:	83 c0 01             	add    $0x1,%eax
f010340a:	39 c8                	cmp    %ecx,%eax
f010340c:	72 f2                	jb     f0103400 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010340e:	5b                   	pop    %ebx
f010340f:	5d                   	pop    %ebp
f0103410:	c3                   	ret    

f0103411 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103411:	55                   	push   %ebp
f0103412:	89 e5                	mov    %esp,%ebp
f0103414:	57                   	push   %edi
f0103415:	56                   	push   %esi
f0103416:	53                   	push   %ebx
f0103417:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010341a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010341d:	eb 03                	jmp    f0103422 <strtol+0x11>
		s++;
f010341f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103422:	0f b6 01             	movzbl (%ecx),%eax
f0103425:	3c 20                	cmp    $0x20,%al
f0103427:	74 f6                	je     f010341f <strtol+0xe>
f0103429:	3c 09                	cmp    $0x9,%al
f010342b:	74 f2                	je     f010341f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010342d:	3c 2b                	cmp    $0x2b,%al
f010342f:	75 0a                	jne    f010343b <strtol+0x2a>
		s++;
f0103431:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103434:	bf 00 00 00 00       	mov    $0x0,%edi
f0103439:	eb 11                	jmp    f010344c <strtol+0x3b>
f010343b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103440:	3c 2d                	cmp    $0x2d,%al
f0103442:	75 08                	jne    f010344c <strtol+0x3b>
		s++, neg = 1;
f0103444:	83 c1 01             	add    $0x1,%ecx
f0103447:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010344c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103452:	75 15                	jne    f0103469 <strtol+0x58>
f0103454:	80 39 30             	cmpb   $0x30,(%ecx)
f0103457:	75 10                	jne    f0103469 <strtol+0x58>
f0103459:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010345d:	75 7c                	jne    f01034db <strtol+0xca>
		s += 2, base = 16;
f010345f:	83 c1 02             	add    $0x2,%ecx
f0103462:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103467:	eb 16                	jmp    f010347f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103469:	85 db                	test   %ebx,%ebx
f010346b:	75 12                	jne    f010347f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010346d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103472:	80 39 30             	cmpb   $0x30,(%ecx)
f0103475:	75 08                	jne    f010347f <strtol+0x6e>
		s++, base = 8;
f0103477:	83 c1 01             	add    $0x1,%ecx
f010347a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010347f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103484:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103487:	0f b6 11             	movzbl (%ecx),%edx
f010348a:	8d 72 d0             	lea    -0x30(%edx),%esi
f010348d:	89 f3                	mov    %esi,%ebx
f010348f:	80 fb 09             	cmp    $0x9,%bl
f0103492:	77 08                	ja     f010349c <strtol+0x8b>
			dig = *s - '0';
f0103494:	0f be d2             	movsbl %dl,%edx
f0103497:	83 ea 30             	sub    $0x30,%edx
f010349a:	eb 22                	jmp    f01034be <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010349c:	8d 72 9f             	lea    -0x61(%edx),%esi
f010349f:	89 f3                	mov    %esi,%ebx
f01034a1:	80 fb 19             	cmp    $0x19,%bl
f01034a4:	77 08                	ja     f01034ae <strtol+0x9d>
			dig = *s - 'a' + 10;
f01034a6:	0f be d2             	movsbl %dl,%edx
f01034a9:	83 ea 57             	sub    $0x57,%edx
f01034ac:	eb 10                	jmp    f01034be <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01034ae:	8d 72 bf             	lea    -0x41(%edx),%esi
f01034b1:	89 f3                	mov    %esi,%ebx
f01034b3:	80 fb 19             	cmp    $0x19,%bl
f01034b6:	77 16                	ja     f01034ce <strtol+0xbd>
			dig = *s - 'A' + 10;
f01034b8:	0f be d2             	movsbl %dl,%edx
f01034bb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01034be:	3b 55 10             	cmp    0x10(%ebp),%edx
f01034c1:	7d 0b                	jge    f01034ce <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01034c3:	83 c1 01             	add    $0x1,%ecx
f01034c6:	0f af 45 10          	imul   0x10(%ebp),%eax
f01034ca:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01034cc:	eb b9                	jmp    f0103487 <strtol+0x76>

	if (endptr)
f01034ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01034d2:	74 0d                	je     f01034e1 <strtol+0xd0>
		*endptr = (char *) s;
f01034d4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01034d7:	89 0e                	mov    %ecx,(%esi)
f01034d9:	eb 06                	jmp    f01034e1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034db:	85 db                	test   %ebx,%ebx
f01034dd:	74 98                	je     f0103477 <strtol+0x66>
f01034df:	eb 9e                	jmp    f010347f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01034e1:	89 c2                	mov    %eax,%edx
f01034e3:	f7 da                	neg    %edx
f01034e5:	85 ff                	test   %edi,%edi
f01034e7:	0f 45 c2             	cmovne %edx,%eax
}
f01034ea:	5b                   	pop    %ebx
f01034eb:	5e                   	pop    %esi
f01034ec:	5f                   	pop    %edi
f01034ed:	5d                   	pop    %ebp
f01034ee:	c3                   	ret    
f01034ef:	90                   	nop

f01034f0 <__udivdi3>:
f01034f0:	55                   	push   %ebp
f01034f1:	57                   	push   %edi
f01034f2:	56                   	push   %esi
f01034f3:	53                   	push   %ebx
f01034f4:	83 ec 1c             	sub    $0x1c,%esp
f01034f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01034fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01034ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103503:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103507:	85 f6                	test   %esi,%esi
f0103509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010350d:	89 ca                	mov    %ecx,%edx
f010350f:	89 f8                	mov    %edi,%eax
f0103511:	75 3d                	jne    f0103550 <__udivdi3+0x60>
f0103513:	39 cf                	cmp    %ecx,%edi
f0103515:	0f 87 c5 00 00 00    	ja     f01035e0 <__udivdi3+0xf0>
f010351b:	85 ff                	test   %edi,%edi
f010351d:	89 fd                	mov    %edi,%ebp
f010351f:	75 0b                	jne    f010352c <__udivdi3+0x3c>
f0103521:	b8 01 00 00 00       	mov    $0x1,%eax
f0103526:	31 d2                	xor    %edx,%edx
f0103528:	f7 f7                	div    %edi
f010352a:	89 c5                	mov    %eax,%ebp
f010352c:	89 c8                	mov    %ecx,%eax
f010352e:	31 d2                	xor    %edx,%edx
f0103530:	f7 f5                	div    %ebp
f0103532:	89 c1                	mov    %eax,%ecx
f0103534:	89 d8                	mov    %ebx,%eax
f0103536:	89 cf                	mov    %ecx,%edi
f0103538:	f7 f5                	div    %ebp
f010353a:	89 c3                	mov    %eax,%ebx
f010353c:	89 d8                	mov    %ebx,%eax
f010353e:	89 fa                	mov    %edi,%edx
f0103540:	83 c4 1c             	add    $0x1c,%esp
f0103543:	5b                   	pop    %ebx
f0103544:	5e                   	pop    %esi
f0103545:	5f                   	pop    %edi
f0103546:	5d                   	pop    %ebp
f0103547:	c3                   	ret    
f0103548:	90                   	nop
f0103549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103550:	39 ce                	cmp    %ecx,%esi
f0103552:	77 74                	ja     f01035c8 <__udivdi3+0xd8>
f0103554:	0f bd fe             	bsr    %esi,%edi
f0103557:	83 f7 1f             	xor    $0x1f,%edi
f010355a:	0f 84 98 00 00 00    	je     f01035f8 <__udivdi3+0x108>
f0103560:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103565:	89 f9                	mov    %edi,%ecx
f0103567:	89 c5                	mov    %eax,%ebp
f0103569:	29 fb                	sub    %edi,%ebx
f010356b:	d3 e6                	shl    %cl,%esi
f010356d:	89 d9                	mov    %ebx,%ecx
f010356f:	d3 ed                	shr    %cl,%ebp
f0103571:	89 f9                	mov    %edi,%ecx
f0103573:	d3 e0                	shl    %cl,%eax
f0103575:	09 ee                	or     %ebp,%esi
f0103577:	89 d9                	mov    %ebx,%ecx
f0103579:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357d:	89 d5                	mov    %edx,%ebp
f010357f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103583:	d3 ed                	shr    %cl,%ebp
f0103585:	89 f9                	mov    %edi,%ecx
f0103587:	d3 e2                	shl    %cl,%edx
f0103589:	89 d9                	mov    %ebx,%ecx
f010358b:	d3 e8                	shr    %cl,%eax
f010358d:	09 c2                	or     %eax,%edx
f010358f:	89 d0                	mov    %edx,%eax
f0103591:	89 ea                	mov    %ebp,%edx
f0103593:	f7 f6                	div    %esi
f0103595:	89 d5                	mov    %edx,%ebp
f0103597:	89 c3                	mov    %eax,%ebx
f0103599:	f7 64 24 0c          	mull   0xc(%esp)
f010359d:	39 d5                	cmp    %edx,%ebp
f010359f:	72 10                	jb     f01035b1 <__udivdi3+0xc1>
f01035a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01035a5:	89 f9                	mov    %edi,%ecx
f01035a7:	d3 e6                	shl    %cl,%esi
f01035a9:	39 c6                	cmp    %eax,%esi
f01035ab:	73 07                	jae    f01035b4 <__udivdi3+0xc4>
f01035ad:	39 d5                	cmp    %edx,%ebp
f01035af:	75 03                	jne    f01035b4 <__udivdi3+0xc4>
f01035b1:	83 eb 01             	sub    $0x1,%ebx
f01035b4:	31 ff                	xor    %edi,%edi
f01035b6:	89 d8                	mov    %ebx,%eax
f01035b8:	89 fa                	mov    %edi,%edx
f01035ba:	83 c4 1c             	add    $0x1c,%esp
f01035bd:	5b                   	pop    %ebx
f01035be:	5e                   	pop    %esi
f01035bf:	5f                   	pop    %edi
f01035c0:	5d                   	pop    %ebp
f01035c1:	c3                   	ret    
f01035c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01035c8:	31 ff                	xor    %edi,%edi
f01035ca:	31 db                	xor    %ebx,%ebx
f01035cc:	89 d8                	mov    %ebx,%eax
f01035ce:	89 fa                	mov    %edi,%edx
f01035d0:	83 c4 1c             	add    $0x1c,%esp
f01035d3:	5b                   	pop    %ebx
f01035d4:	5e                   	pop    %esi
f01035d5:	5f                   	pop    %edi
f01035d6:	5d                   	pop    %ebp
f01035d7:	c3                   	ret    
f01035d8:	90                   	nop
f01035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035e0:	89 d8                	mov    %ebx,%eax
f01035e2:	f7 f7                	div    %edi
f01035e4:	31 ff                	xor    %edi,%edi
f01035e6:	89 c3                	mov    %eax,%ebx
f01035e8:	89 d8                	mov    %ebx,%eax
f01035ea:	89 fa                	mov    %edi,%edx
f01035ec:	83 c4 1c             	add    $0x1c,%esp
f01035ef:	5b                   	pop    %ebx
f01035f0:	5e                   	pop    %esi
f01035f1:	5f                   	pop    %edi
f01035f2:	5d                   	pop    %ebp
f01035f3:	c3                   	ret    
f01035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01035f8:	39 ce                	cmp    %ecx,%esi
f01035fa:	72 0c                	jb     f0103608 <__udivdi3+0x118>
f01035fc:	31 db                	xor    %ebx,%ebx
f01035fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103602:	0f 87 34 ff ff ff    	ja     f010353c <__udivdi3+0x4c>
f0103608:	bb 01 00 00 00       	mov    $0x1,%ebx
f010360d:	e9 2a ff ff ff       	jmp    f010353c <__udivdi3+0x4c>
f0103612:	66 90                	xchg   %ax,%ax
f0103614:	66 90                	xchg   %ax,%ax
f0103616:	66 90                	xchg   %ax,%ax
f0103618:	66 90                	xchg   %ax,%ax
f010361a:	66 90                	xchg   %ax,%ax
f010361c:	66 90                	xchg   %ax,%ax
f010361e:	66 90                	xchg   %ax,%ax

f0103620 <__umoddi3>:
f0103620:	55                   	push   %ebp
f0103621:	57                   	push   %edi
f0103622:	56                   	push   %esi
f0103623:	53                   	push   %ebx
f0103624:	83 ec 1c             	sub    $0x1c,%esp
f0103627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010362b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010362f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103633:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103637:	85 d2                	test   %edx,%edx
f0103639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010363d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103641:	89 f3                	mov    %esi,%ebx
f0103643:	89 3c 24             	mov    %edi,(%esp)
f0103646:	89 74 24 04          	mov    %esi,0x4(%esp)
f010364a:	75 1c                	jne    f0103668 <__umoddi3+0x48>
f010364c:	39 f7                	cmp    %esi,%edi
f010364e:	76 50                	jbe    f01036a0 <__umoddi3+0x80>
f0103650:	89 c8                	mov    %ecx,%eax
f0103652:	89 f2                	mov    %esi,%edx
f0103654:	f7 f7                	div    %edi
f0103656:	89 d0                	mov    %edx,%eax
f0103658:	31 d2                	xor    %edx,%edx
f010365a:	83 c4 1c             	add    $0x1c,%esp
f010365d:	5b                   	pop    %ebx
f010365e:	5e                   	pop    %esi
f010365f:	5f                   	pop    %edi
f0103660:	5d                   	pop    %ebp
f0103661:	c3                   	ret    
f0103662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103668:	39 f2                	cmp    %esi,%edx
f010366a:	89 d0                	mov    %edx,%eax
f010366c:	77 52                	ja     f01036c0 <__umoddi3+0xa0>
f010366e:	0f bd ea             	bsr    %edx,%ebp
f0103671:	83 f5 1f             	xor    $0x1f,%ebp
f0103674:	75 5a                	jne    f01036d0 <__umoddi3+0xb0>
f0103676:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010367a:	0f 82 e0 00 00 00    	jb     f0103760 <__umoddi3+0x140>
f0103680:	39 0c 24             	cmp    %ecx,(%esp)
f0103683:	0f 86 d7 00 00 00    	jbe    f0103760 <__umoddi3+0x140>
f0103689:	8b 44 24 08          	mov    0x8(%esp),%eax
f010368d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103691:	83 c4 1c             	add    $0x1c,%esp
f0103694:	5b                   	pop    %ebx
f0103695:	5e                   	pop    %esi
f0103696:	5f                   	pop    %edi
f0103697:	5d                   	pop    %ebp
f0103698:	c3                   	ret    
f0103699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01036a0:	85 ff                	test   %edi,%edi
f01036a2:	89 fd                	mov    %edi,%ebp
f01036a4:	75 0b                	jne    f01036b1 <__umoddi3+0x91>
f01036a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01036ab:	31 d2                	xor    %edx,%edx
f01036ad:	f7 f7                	div    %edi
f01036af:	89 c5                	mov    %eax,%ebp
f01036b1:	89 f0                	mov    %esi,%eax
f01036b3:	31 d2                	xor    %edx,%edx
f01036b5:	f7 f5                	div    %ebp
f01036b7:	89 c8                	mov    %ecx,%eax
f01036b9:	f7 f5                	div    %ebp
f01036bb:	89 d0                	mov    %edx,%eax
f01036bd:	eb 99                	jmp    f0103658 <__umoddi3+0x38>
f01036bf:	90                   	nop
f01036c0:	89 c8                	mov    %ecx,%eax
f01036c2:	89 f2                	mov    %esi,%edx
f01036c4:	83 c4 1c             	add    $0x1c,%esp
f01036c7:	5b                   	pop    %ebx
f01036c8:	5e                   	pop    %esi
f01036c9:	5f                   	pop    %edi
f01036ca:	5d                   	pop    %ebp
f01036cb:	c3                   	ret    
f01036cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01036d0:	8b 34 24             	mov    (%esp),%esi
f01036d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01036d8:	89 e9                	mov    %ebp,%ecx
f01036da:	29 ef                	sub    %ebp,%edi
f01036dc:	d3 e0                	shl    %cl,%eax
f01036de:	89 f9                	mov    %edi,%ecx
f01036e0:	89 f2                	mov    %esi,%edx
f01036e2:	d3 ea                	shr    %cl,%edx
f01036e4:	89 e9                	mov    %ebp,%ecx
f01036e6:	09 c2                	or     %eax,%edx
f01036e8:	89 d8                	mov    %ebx,%eax
f01036ea:	89 14 24             	mov    %edx,(%esp)
f01036ed:	89 f2                	mov    %esi,%edx
f01036ef:	d3 e2                	shl    %cl,%edx
f01036f1:	89 f9                	mov    %edi,%ecx
f01036f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01036fb:	d3 e8                	shr    %cl,%eax
f01036fd:	89 e9                	mov    %ebp,%ecx
f01036ff:	89 c6                	mov    %eax,%esi
f0103701:	d3 e3                	shl    %cl,%ebx
f0103703:	89 f9                	mov    %edi,%ecx
f0103705:	89 d0                	mov    %edx,%eax
f0103707:	d3 e8                	shr    %cl,%eax
f0103709:	89 e9                	mov    %ebp,%ecx
f010370b:	09 d8                	or     %ebx,%eax
f010370d:	89 d3                	mov    %edx,%ebx
f010370f:	89 f2                	mov    %esi,%edx
f0103711:	f7 34 24             	divl   (%esp)
f0103714:	89 d6                	mov    %edx,%esi
f0103716:	d3 e3                	shl    %cl,%ebx
f0103718:	f7 64 24 04          	mull   0x4(%esp)
f010371c:	39 d6                	cmp    %edx,%esi
f010371e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103722:	89 d1                	mov    %edx,%ecx
f0103724:	89 c3                	mov    %eax,%ebx
f0103726:	72 08                	jb     f0103730 <__umoddi3+0x110>
f0103728:	75 11                	jne    f010373b <__umoddi3+0x11b>
f010372a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010372e:	73 0b                	jae    f010373b <__umoddi3+0x11b>
f0103730:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103734:	1b 14 24             	sbb    (%esp),%edx
f0103737:	89 d1                	mov    %edx,%ecx
f0103739:	89 c3                	mov    %eax,%ebx
f010373b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010373f:	29 da                	sub    %ebx,%edx
f0103741:	19 ce                	sbb    %ecx,%esi
f0103743:	89 f9                	mov    %edi,%ecx
f0103745:	89 f0                	mov    %esi,%eax
f0103747:	d3 e0                	shl    %cl,%eax
f0103749:	89 e9                	mov    %ebp,%ecx
f010374b:	d3 ea                	shr    %cl,%edx
f010374d:	89 e9                	mov    %ebp,%ecx
f010374f:	d3 ee                	shr    %cl,%esi
f0103751:	09 d0                	or     %edx,%eax
f0103753:	89 f2                	mov    %esi,%edx
f0103755:	83 c4 1c             	add    $0x1c,%esp
f0103758:	5b                   	pop    %ebx
f0103759:	5e                   	pop    %esi
f010375a:	5f                   	pop    %edi
f010375b:	5d                   	pop    %ebp
f010375c:	c3                   	ret    
f010375d:	8d 76 00             	lea    0x0(%esi),%esi
f0103760:	29 f9                	sub    %edi,%ecx
f0103762:	19 d6                	sbb    %edx,%esi
f0103764:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010376c:	e9 18 ff ff ff       	jmp    f0103689 <__umoddi3+0x69>
