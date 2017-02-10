
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
f010004b:	68 c0 37 10 f0       	push   $0xf01037c0
f0100050:	e8 82 27 00 00       	call   f01027d7 <cprintf>
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
f0100082:	68 dc 37 10 f0       	push   $0xf01037dc
f0100087:	e8 4b 27 00 00       	call   f01027d7 <cprintf>
	
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
f01000ac:	e8 76 32 00 00       	call   f0103327 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 a2 04 00 00       	call   f0100558 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 f7 37 10 f0       	push   $0xf01037f7
f01000c3:	e8 0f 27 00 00       	call   f01027d7 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 2c 10 00 00       	call   f01010f9 <mem_init>
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
f0100110:	68 12 38 10 f0       	push   $0xf0103812
f0100115:	e8 bd 26 00 00       	call   f01027d7 <cprintf>
	vcprintf(fmt, ap);
f010011a:	83 c4 08             	add    $0x8,%esp
f010011d:	53                   	push   %ebx
f010011e:	56                   	push   %esi
f010011f:	e8 8d 26 00 00       	call   f01027b1 <vcprintf>
	cprintf("\n");
f0100124:	c7 04 24 de 3f 10 f0 	movl   $0xf0103fde,(%esp)
f010012b:	e8 a7 26 00 00       	call   f01027d7 <cprintf>
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
f0100152:	68 2a 38 10 f0       	push   $0xf010382a
f0100157:	e8 7b 26 00 00       	call   f01027d7 <cprintf>
	vcprintf(fmt, ap);
f010015c:	83 c4 08             	add    $0x8,%esp
f010015f:	53                   	push   %ebx
f0100160:	ff 75 10             	pushl  0x10(%ebp)
f0100163:	e8 49 26 00 00       	call   f01027b1 <vcprintf>
	cprintf("\n");
f0100168:	c7 04 24 de 3f 10 f0 	movl   $0xf0103fde,(%esp)
f010016f:	e8 63 26 00 00       	call   f01027d7 <cprintf>
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
f010022e:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
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
f010026a:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
f0100271:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100277:	0f b6 8a a0 38 10 f0 	movzbl -0xfefc760(%edx),%ecx
f010027e:	31 c8                	xor    %ecx,%eax
f0100280:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100285:	89 c1                	mov    %eax,%ecx
f0100287:	83 e1 03             	and    $0x3,%ecx
f010028a:	8b 0c 8d 80 38 10 f0 	mov    -0xfefc780(,%ecx,4),%ecx
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
f01002c8:	68 44 38 10 f0       	push   $0xf0103844
f01002cd:	e8 05 25 00 00       	call   f01027d7 <cprintf>
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
f010047c:	e8 f3 2e 00 00       	call   f0103374 <memmove>
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
f010064b:	68 50 38 10 f0       	push   $0xf0103850
f0100650:	e8 82 21 00 00       	call   f01027d7 <cprintf>
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
f0100691:	68 a0 3a 10 f0       	push   $0xf0103aa0
f0100696:	68 be 3a 10 f0       	push   $0xf0103abe
f010069b:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006a0:	e8 32 21 00 00       	call   f01027d7 <cprintf>
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 44 3b 10 f0       	push   $0xf0103b44
f01006ad:	68 cc 3a 10 f0       	push   $0xf0103acc
f01006b2:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006b7:	e8 1b 21 00 00       	call   f01027d7 <cprintf>
f01006bc:	83 c4 0c             	add    $0xc,%esp
f01006bf:	68 44 3b 10 f0       	push   $0xf0103b44
f01006c4:	68 d5 3a 10 f0       	push   $0xf0103ad5
f01006c9:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006ce:	e8 04 21 00 00       	call   f01027d7 <cprintf>
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
f01006e0:	68 df 3a 10 f0       	push   $0xf0103adf
f01006e5:	e8 ed 20 00 00       	call   f01027d7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ea:	83 c4 08             	add    $0x8,%esp
f01006ed:	68 0c 00 10 00       	push   $0x10000c
f01006f2:	68 6c 3b 10 f0       	push   $0xf0103b6c
f01006f7:	e8 db 20 00 00       	call   f01027d7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006fc:	83 c4 0c             	add    $0xc,%esp
f01006ff:	68 0c 00 10 00       	push   $0x10000c
f0100704:	68 0c 00 10 f0       	push   $0xf010000c
f0100709:	68 94 3b 10 f0       	push   $0xf0103b94
f010070e:	e8 c4 20 00 00       	call   f01027d7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100713:	83 c4 0c             	add    $0xc,%esp
f0100716:	68 b1 37 10 00       	push   $0x1037b1
f010071b:	68 b1 37 10 f0       	push   $0xf01037b1
f0100720:	68 b8 3b 10 f0       	push   $0xf0103bb8
f0100725:	e8 ad 20 00 00       	call   f01027d7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010072a:	83 c4 0c             	add    $0xc,%esp
f010072d:	68 00 73 11 00       	push   $0x117300
f0100732:	68 00 73 11 f0       	push   $0xf0117300
f0100737:	68 dc 3b 10 f0       	push   $0xf0103bdc
f010073c:	e8 96 20 00 00       	call   f01027d7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100741:	83 c4 0c             	add    $0xc,%esp
f0100744:	68 50 79 11 00       	push   $0x117950
f0100749:	68 50 79 11 f0       	push   $0xf0117950
f010074e:	68 00 3c 10 f0       	push   $0xf0103c00
f0100753:	e8 7f 20 00 00       	call   f01027d7 <cprintf>
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
f0100779:	68 24 3c 10 f0       	push   $0xf0103c24
f010077e:	e8 54 20 00 00       	call   f01027d7 <cprintf>
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
f01007ac:	68 50 3c 10 f0       	push   $0xf0103c50
f01007b1:	e8 21 20 00 00       	call   f01027d7 <cprintf>
	    debuginfo_eip(pointer[1],&info);
f01007b6:	83 c4 18             	add    $0x18,%esp
f01007b9:	56                   	push   %esi
f01007ba:	ff 73 04             	pushl  0x4(%ebx)
f01007bd:	e8 1f 21 00 00       	call   f01028e1 <debuginfo_eip>
	    cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(pointer[1]-info.eip_fn_addr));
f01007c2:	83 c4 08             	add    $0x8,%esp
f01007c5:	8b 43 04             	mov    0x4(%ebx),%eax
f01007c8:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007cb:	50                   	push   %eax
f01007cc:	ff 75 e8             	pushl  -0x18(%ebp)
f01007cf:	ff 75 ec             	pushl  -0x14(%ebp)
f01007d2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007d5:	ff 75 e0             	pushl  -0x20(%ebp)
f01007d8:	68 f8 3a 10 f0       	push   $0xf0103af8
f01007dd:	e8 f5 1f 00 00       	call   f01027d7 <cprintf>
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
f0100800:	68 84 3c 10 f0       	push   $0xf0103c84
f0100805:	e8 cd 1f 00 00       	call   f01027d7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010080a:	c7 04 24 a8 3c 10 f0 	movl   $0xf0103ca8,(%esp)
f0100811:	e8 c1 1f 00 00       	call   f01027d7 <cprintf>
f0100816:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100819:	83 ec 0c             	sub    $0xc,%esp
f010081c:	68 08 3b 10 f0       	push   $0xf0103b08
f0100821:	e8 aa 28 00 00       	call   f01030d0 <readline>
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
f0100855:	68 0c 3b 10 f0       	push   $0xf0103b0c
f010085a:	e8 8b 2a 00 00       	call   f01032ea <strchr>
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
f0100875:	68 11 3b 10 f0       	push   $0xf0103b11
f010087a:	e8 58 1f 00 00       	call   f01027d7 <cprintf>
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
f010089e:	68 0c 3b 10 f0       	push   $0xf0103b0c
f01008a3:	e8 42 2a 00 00       	call   f01032ea <strchr>
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
f01008cc:	ff 34 85 e0 3c 10 f0 	pushl  -0xfefc320(,%eax,4)
f01008d3:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d6:	e8 b1 29 00 00       	call   f010328c <strcmp>
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
f01008f0:	ff 14 85 e8 3c 10 f0 	call   *-0xfefc318(,%eax,4)


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
f0100911:	68 2e 3b 10 f0       	push   $0xf0103b2e
f0100916:	e8 bc 1e 00 00       	call   f01027d7 <cprintf>
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
f0100936:	e8 35 1e 00 00       	call   f0102770 <mc146818_read>
f010093b:	89 c6                	mov    %eax,%esi
f010093d:	83 c3 01             	add    $0x1,%ebx
f0100940:	89 1c 24             	mov    %ebx,(%esp)
f0100943:	e8 28 1e 00 00       	call   f0102770 <mc146818_read>
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
f01009a8:	68 04 3d 10 f0       	push   $0xf0103d04
f01009ad:	6a 73                	push   $0x73
f01009af:	68 12 3d 10 f0       	push   $0xf0103d12
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
f01009e0:	68 10 40 10 f0       	push   $0xf0104010
f01009e5:	68 08 03 00 00       	push   $0x308
f01009ea:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100a38:	68 34 40 10 f0       	push   $0xf0104034
f0100a3d:	68 49 02 00 00       	push   $0x249
f0100a42:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100ac7:	68 10 40 10 f0       	push   $0xf0104010
f0100acc:	6a 52                	push   $0x52
f0100ace:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100ad3:	e8 13 f6 ff ff       	call   f01000eb <_panic>
	
	memset(page2kva(pp), 0x97, 128);
f0100ad8:	83 ec 04             	sub    $0x4,%esp
f0100adb:	68 80 00 00 00       	push   $0x80
f0100ae0:	68 97 00 00 00       	push   $0x97
f0100ae5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100aea:	50                   	push   %eax
f0100aeb:	e8 37 28 00 00       	call   f0103327 <memset>
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
f0100b31:	68 2c 3d 10 f0       	push   $0xf0103d2c
f0100b36:	68 38 3d 10 f0       	push   $0xf0103d38
f0100b3b:	68 65 02 00 00       	push   $0x265
f0100b40:	68 12 3d 10 f0       	push   $0xf0103d12
f0100b45:	e8 a1 f5 ff ff       	call   f01000eb <_panic>
		assert(pp < pages + npages);
f0100b4a:	39 fa                	cmp    %edi,%edx
f0100b4c:	72 19                	jb     f0100b67 <check_page_free_list+0x148>
f0100b4e:	68 4d 3d 10 f0       	push   $0xf0103d4d
f0100b53:	68 38 3d 10 f0       	push   $0xf0103d38
f0100b58:	68 66 02 00 00       	push   $0x266
f0100b5d:	68 12 3d 10 f0       	push   $0xf0103d12
f0100b62:	e8 84 f5 ff ff       	call   f01000eb <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b67:	89 d0                	mov    %edx,%eax
f0100b69:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b6c:	a8 07                	test   $0x7,%al
f0100b6e:	74 19                	je     f0100b89 <check_page_free_list+0x16a>
f0100b70:	68 58 40 10 f0       	push   $0xf0104058
f0100b75:	68 38 3d 10 f0       	push   $0xf0103d38
f0100b7a:	68 67 02 00 00       	push   $0x267
f0100b7f:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100b93:	68 61 3d 10 f0       	push   $0xf0103d61
f0100b98:	68 38 3d 10 f0       	push   $0xf0103d38
f0100b9d:	68 6a 02 00 00       	push   $0x26a
f0100ba2:	68 12 3d 10 f0       	push   $0xf0103d12
f0100ba7:	e8 3f f5 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bac:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bb1:	75 19                	jne    f0100bcc <check_page_free_list+0x1ad>
f0100bb3:	68 72 3d 10 f0       	push   $0xf0103d72
f0100bb8:	68 38 3d 10 f0       	push   $0xf0103d38
f0100bbd:	68 6b 02 00 00       	push   $0x26b
f0100bc2:	68 12 3d 10 f0       	push   $0xf0103d12
f0100bc7:	e8 1f f5 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bcc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bd1:	75 19                	jne    f0100bec <check_page_free_list+0x1cd>
f0100bd3:	68 8c 40 10 f0       	push   $0xf010408c
f0100bd8:	68 38 3d 10 f0       	push   $0xf0103d38
f0100bdd:	68 6c 02 00 00       	push   $0x26c
f0100be2:	68 12 3d 10 f0       	push   $0xf0103d12
f0100be7:	e8 ff f4 ff ff       	call   f01000eb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bec:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bf1:	75 19                	jne    f0100c0c <check_page_free_list+0x1ed>
f0100bf3:	68 8b 3d 10 f0       	push   $0xf0103d8b
f0100bf8:	68 38 3d 10 f0       	push   $0xf0103d38
f0100bfd:	68 6d 02 00 00       	push   $0x26d
f0100c02:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100c1e:	68 10 40 10 f0       	push   $0xf0104010
f0100c23:	6a 52                	push   $0x52
f0100c25:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100c2a:	e8 bc f4 ff ff       	call   f01000eb <_panic>
f0100c2f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c34:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c37:	76 1e                	jbe    f0100c57 <check_page_free_list+0x238>
f0100c39:	68 b0 40 10 f0       	push   $0xf01040b0
f0100c3e:	68 38 3d 10 f0       	push   $0xf0103d38
f0100c43:	68 6e 02 00 00       	push   $0x26e
f0100c48:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100c6c:	68 a5 3d 10 f0       	push   $0xf0103da5
f0100c71:	68 38 3d 10 f0       	push   $0xf0103d38
f0100c76:	68 76 02 00 00       	push   $0x276
f0100c7b:	68 12 3d 10 f0       	push   $0xf0103d12
f0100c80:	e8 66 f4 ff ff       	call   f01000eb <_panic>
	assert(nfree_extmem > 0);
f0100c85:	85 db                	test   %ebx,%ebx
f0100c87:	7f 42                	jg     f0100ccb <check_page_free_list+0x2ac>
f0100c89:	68 b7 3d 10 f0       	push   $0xf0103db7
f0100c8e:	68 38 3d 10 f0       	push   $0xf0103d38
f0100c93:	68 77 02 00 00       	push   $0x277
f0100c98:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100d94:	68 10 40 10 f0       	push   $0xf0104010
f0100d99:	6a 52                	push   $0x52
f0100d9b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100da0:	e8 46 f3 ff ff       	call   f01000eb <_panic>
	{
		memset(page2kva(pp), 0, PGSIZE);
f0100da5:	83 ec 04             	sub    $0x4,%esp
f0100da8:	68 00 10 00 00       	push   $0x1000
f0100dad:	6a 00                	push   $0x0
f0100daf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100db4:	50                   	push   %eax
f0100db5:	e8 6d 25 00 00       	call   f0103327 <memset>
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
f0100ddc:	68 c8 3d 10 f0       	push   $0xf0103dc8
f0100de1:	68 5b 01 00 00       	push   $0x15b
f0100de6:	68 12 3d 10 f0       	push   $0xf0103d12
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
f0100e17:	68 10 40 10 f0       	push   $0xf0104010
f0100e1c:	6a 52                	push   $0x52
f0100e1e:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100e23:	e8 c3 f2 ff ff       	call   f01000eb <_panic>
        memset(page2kva(pp), 0, PGSIZE);
f0100e28:	83 ec 04             	sub    $0x4,%esp
f0100e2b:	68 00 10 00 00       	push   $0x1000
f0100e30:	6a 00                	push   $0x0
f0100e32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e37:	50                   	push   %eax
f0100e38:	e8 ea 24 00 00       	call   f0103327 <memset>
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
f0100e6c:	56                   	push   %esi
f0100e6d:	53                   	push   %ebx
f0100e6e:	83 ec 10             	sub    $0x10,%esp
f0100e71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
      pde_t * pde; //va(virtual address) point to pa(physical address)
      pte_t * pgtable; //same as pde
      struct PageInfo *pp;

      pde = &pgdir[PDX(va)]; // va->pgdir
f0100e74:	89 d8                	mov    %ebx,%eax
f0100e76:	c1 e8 16             	shr    $0x16,%eax
f0100e79:	c1 e0 02             	shl    $0x2,%eax
f0100e7c:	03 45 08             	add    0x8(%ebp),%eax
f0100e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(*pde & PTE_P) {
f0100e82:	8b 30                	mov    (%eax),%esi
f0100e84:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100e8a:	74 33                	je     f0100ebf <pgdir_walk+0x56>
          pgtable = (KADDR(PTE_ADDR(*pde)));
f0100e8c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e92:	89 f0                	mov    %esi,%eax
f0100e94:	c1 e8 0c             	shr    $0xc,%eax
f0100e97:	39 05 44 79 11 f0    	cmp    %eax,0xf0117944
f0100e9d:	77 15                	ja     f0100eb4 <pgdir_walk+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e9f:	56                   	push   %esi
f0100ea0:	68 10 40 10 f0       	push   $0xf0104010
f0100ea5:	68 8f 01 00 00       	push   $0x18f
f0100eaa:	68 12 3d 10 f0       	push   $0xf0103d12
f0100eaf:	e8 37 f2 ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f0100eb4:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0100eba:	e9 82 00 00 00       	jmp    f0100f41 <pgdir_walk+0xd8>
      } else {
        //page table page not exist
        if(!create ||
f0100ebf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ec3:	0f 84 aa 00 00 00    	je     f0100f73 <pgdir_walk+0x10a>
f0100ec9:	83 ec 0c             	sub    $0xc,%esp
f0100ecc:	6a 01                	push   $0x1
f0100ece:	e8 81 fe ff ff       	call   f0100d54 <page_alloc>
f0100ed3:	83 c4 10             	add    $0x10,%esp
f0100ed6:	85 c0                	test   %eax,%eax
f0100ed8:	0f 84 9c 00 00 00    	je     f0100f7a <pgdir_walk+0x111>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ede:	89 c2                	mov    %eax,%edx
f0100ee0:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0100ee6:	c1 fa 03             	sar    $0x3,%edx
f0100ee9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eec:	89 d1                	mov    %edx,%ecx
f0100eee:	c1 e9 0c             	shr    $0xc,%ecx
f0100ef1:	3b 0d 44 79 11 f0    	cmp    0xf0117944,%ecx
f0100ef7:	72 12                	jb     f0100f0b <pgdir_walk+0xa2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ef9:	52                   	push   %edx
f0100efa:	68 10 40 10 f0       	push   $0xf0104010
f0100eff:	6a 52                	push   $0x52
f0100f01:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0100f06:	e8 e0 f1 ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f0100f0b:	8d 8a 00 00 00 f0    	lea    -0x10000000(%edx),%ecx
f0100f11:	89 ce                	mov    %ecx,%esi
           !(pp = page_alloc(ALLOC_ZERO)) ||
f0100f13:	85 c9                	test   %ecx,%ecx
f0100f15:	74 6a                	je     f0100f81 <pgdir_walk+0x118>
           !(pgtable = (pte_t*)page2kva(pp)))
            return NULL;
           
        pp->pp_ref++;
f0100f17:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
f0100f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f1f:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0100f25:	77 15                	ja     f0100f3c <pgdir_walk+0xd3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f27:	51                   	push   %ecx
f0100f28:	68 f8 40 10 f0       	push   $0xf01040f8
f0100f2d:	68 98 01 00 00       	push   $0x198
f0100f32:	68 12 3d 10 f0       	push   $0xf0103d12
f0100f37:	e8 af f1 ff ff       	call   f01000eb <_panic>
f0100f3c:	83 ca 07             	or     $0x7,%edx
f0100f3f:	89 10                	mov    %edx,(%eax)
    }
	cprintf("\n PDE = %x addr = %x val = %x\n",pde,&pde,*pde);
f0100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f44:	ff 30                	pushl  (%eax)
f0100f46:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0100f49:	52                   	push   %edx
f0100f4a:	50                   	push   %eax
f0100f4b:	68 1c 41 10 f0       	push   $0xf010411c
f0100f50:	e8 82 18 00 00       	call   f01027d7 <cprintf>
	cprintf("\n PTE = %x addr = %x val = %x\n",pgtable,&pgtable[PTX(va)],*pgtable);
f0100f55:	c1 eb 0a             	shr    $0xa,%ebx
f0100f58:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f5e:	01 f3                	add    %esi,%ebx
f0100f60:	ff 36                	pushl  (%esi)
f0100f62:	53                   	push   %ebx
f0100f63:	56                   	push   %esi
f0100f64:	68 3c 41 10 f0       	push   $0xf010413c
f0100f69:	e8 69 18 00 00       	call   f01027d7 <cprintf>
    return &pgtable[PTX(va)];
f0100f6e:	83 c4 20             	add    $0x20,%esp
f0100f71:	eb 13                	jmp    f0100f86 <pgdir_walk+0x11d>
      } else {
        //page table page not exist
        if(!create ||
           !(pp = page_alloc(ALLOC_ZERO)) ||
           !(pgtable = (pte_t*)page2kva(pp)))
            return NULL;
f0100f73:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f78:	eb 0c                	jmp    f0100f86 <pgdir_walk+0x11d>
f0100f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f7f:	eb 05                	jmp    f0100f86 <pgdir_walk+0x11d>
f0100f81:	bb 00 00 00 00       	mov    $0x0,%ebx
        *pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
    }
	cprintf("\n PDE = %x addr = %x val = %x\n",pde,&pde,*pde);
	cprintf("\n PTE = %x addr = %x val = %x\n",pgtable,&pgtable[PTX(va)],*pgtable);
    return &pgtable[PTX(va)];
}
f0100f86:	89 d8                	mov    %ebx,%eax
f0100f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f8b:	5b                   	pop    %ebx
f0100f8c:	5e                   	pop    %esi
f0100f8d:	5d                   	pop    %ebp
f0100f8e:	c3                   	ret    

f0100f8f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f8f:	55                   	push   %ebp
f0100f90:	89 e5                	mov    %esp,%ebp
f0100f92:	57                   	push   %edi
f0100f93:	56                   	push   %esi
f0100f94:	53                   	push   %ebx
f0100f95:	83 ec 1c             	sub    $0x1c,%esp
f0100f98:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Fill this function in
	//for (uint32_t i=0; i < size ; i=i+PGSIZE)
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
f0100f9b:	c1 e9 0c             	shr    $0xc,%ecx
f0100f9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	
	while(i<x)
f0100fa1:	89 d6                	mov    %edx,%esi
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	//for (uint32_t i=0; i < size ; i=i+PGSIZE)
	
	uint32_t i=0, x=0;
f0100fa3:	bf 00 00 00 00       	mov    $0x0,%edi
f0100fa8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fab:	29 d0                	sub    %edx,%eax
f0100fad:	89 45 e0             	mov    %eax,-0x20(%ebp)
	x=size/(PGSIZE);
	
	while(i<x)
	{
		pte_t *PTE = pgdir_walk(pgdir,(void *)va,1);
		*PTE = (PTE_ADDR(pa)) | perm | PTE_P;
f0100fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb3:	83 c8 01             	or     $0x1,%eax
f0100fb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
	
	while(i<x)
f0100fb9:	eb 25                	jmp    f0100fe0 <boot_map_region+0x51>
	{
		pte_t *PTE = pgdir_walk(pgdir,(void *)va,1);
f0100fbb:	83 ec 04             	sub    $0x4,%esp
f0100fbe:	6a 01                	push   $0x1
f0100fc0:	56                   	push   %esi
f0100fc1:	ff 75 dc             	pushl  -0x24(%ebp)
f0100fc4:	e8 a0 fe ff ff       	call   f0100e69 <pgdir_walk>
		*PTE = (PTE_ADDR(pa)) | perm | PTE_P;
f0100fc9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100fcf:	0b 5d d8             	or     -0x28(%ebp),%ebx
f0100fd2:	89 18                	mov    %ebx,(%eax)
		va=va+PGSIZE;
f0100fd4:	81 c6 00 10 00 00    	add    $0x1000,%esi
		pa=pa+PGSIZE;
		i++;
f0100fda:	83 c7 01             	add    $0x1,%edi
f0100fdd:	83 c4 10             	add    $0x10,%esp
f0100fe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fe3:	8d 1c 30             	lea    (%eax,%esi,1),%ebx
	
	uint32_t i=0, x=0;
	
	x=size/(PGSIZE);
	
	while(i<x)
f0100fe6:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100fe9:	75 d0                	jne    f0100fbb <boot_map_region+0x2c>
		va=va+PGSIZE;
		pa=pa+PGSIZE;
		i++;
	}
	
}
f0100feb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fee:	5b                   	pop    %ebx
f0100fef:	5e                   	pop    %esi
f0100ff0:	5f                   	pop    %edi
f0100ff1:	5d                   	pop    %ebp
f0100ff2:	c3                   	ret    

f0100ff3 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ff3:	55                   	push   %ebp
f0100ff4:	89 e5                	mov    %esp,%ebp
f0100ff6:	83 ec 0c             	sub    $0xc,%esp
	// Fill this function in
	struct PageInfo *PP=NULL;
	
	pte_t *PTE = pgdir_walk(pgdir,va,0);
f0100ff9:	6a 00                	push   $0x0
f0100ffb:	ff 75 0c             	pushl  0xc(%ebp)
f0100ffe:	ff 75 08             	pushl  0x8(%ebp)
f0101001:	e8 63 fe ff ff       	call   f0100e69 <pgdir_walk>
	
	if(PTE == NULL)
f0101006:	83 c4 10             	add    $0x10,%esp
f0101009:	85 c0                	test   %eax,%eax
f010100b:	74 32                	je     f010103f <page_lookup+0x4c>
f010100d:	89 c1                	mov    %eax,%ecx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010100f:	8b 10                	mov    (%eax),%edx
f0101011:	c1 ea 0c             	shr    $0xc,%edx
f0101014:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f010101a:	72 14                	jb     f0101030 <page_lookup+0x3d>
		panic("pa2page called with invalid pa");
f010101c:	83 ec 04             	sub    $0x4,%esp
f010101f:	68 5c 41 10 f0       	push   $0xf010415c
f0101024:	6a 4b                	push   $0x4b
f0101026:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010102b:	e8 bb f0 ff ff       	call   f01000eb <_panic>
	return &pages[PGNUM(pa)];
f0101030:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0101035:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return NULL;
	}
	
	PP=pa2page(PTE_ADDR(*PTE));
	
	*pte_store=PTE;
f0101038:	8b 55 10             	mov    0x10(%ebp),%edx
f010103b:	89 0a                	mov    %ecx,(%edx)
	
	return PP;
f010103d:	eb 05                	jmp    f0101044 <page_lookup+0x51>
	
	pte_t *PTE = pgdir_walk(pgdir,va,0);
	
	if(PTE == NULL)
	{
		return NULL;
f010103f:	b8 00 00 00 00       	mov    $0x0,%eax
	PP=pa2page(PTE_ADDR(*PTE));
	
	*pte_store=PTE;
	
	return PP;
}
f0101044:	c9                   	leave  
f0101045:	c3                   	ret    

f0101046 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
//     tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101046:	55                   	push   %ebp
f0101047:	89 e5                	mov    %esp,%ebp
f0101049:	53                   	push   %ebx
f010104a:	83 ec 18             	sub    $0x18,%esp
f010104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo *PP=page_lookup(pgdir,va,&pte_store);
f0101050:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101053:	50                   	push   %eax
f0101054:	53                   	push   %ebx
f0101055:	ff 75 08             	pushl  0x8(%ebp)
f0101058:	e8 96 ff ff ff       	call   f0100ff3 <page_lookup>
	
	if(PP == NULL)
f010105d:	83 c4 10             	add    $0x10,%esp
f0101060:	85 c0                	test   %eax,%eax
f0101062:	74 18                	je     f010107c <page_remove+0x36>
	{
		return;
	}
		page_decref(PP);
f0101064:	83 ec 0c             	sub    $0xc,%esp
f0101067:	50                   	push   %eax
f0101068:	e8 d5 fd ff ff       	call   f0100e42 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010106d:	0f 01 3b             	invlpg (%ebx)
		tlb_invalidate(pgdir, va);
	*pte_store=0;
f0101070:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101073:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101079:	83 c4 10             	add    $0x10,%esp
}
f010107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010107f:	c9                   	leave  
f0101080:	c3                   	ret    

f0101081 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101081:	55                   	push   %ebp
f0101082:	89 e5                	mov    %esp,%ebp
f0101084:	57                   	push   %edi
f0101085:	56                   	push   %esi
f0101086:	53                   	push   %ebx
f0101087:	83 ec 10             	sub    $0x10,%esp
f010108a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010108d:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101090:	6a 01                	push   $0x1
f0101092:	57                   	push   %edi
f0101093:	ff 75 08             	pushl  0x8(%ebp)
f0101096:	e8 ce fd ff ff       	call   f0100e69 <pgdir_walk>
 

    if (pte != NULL) {
f010109b:	83 c4 10             	add    $0x10,%esp
f010109e:	85 c0                	test   %eax,%eax
f01010a0:	74 4a                	je     f01010ec <page_insert+0x6b>
f01010a2:	89 c3                	mov    %eax,%ebx
     
        if (*pte & PTE_P)
f01010a4:	f6 00 01             	testb  $0x1,(%eax)
f01010a7:	74 0f                	je     f01010b8 <page_insert+0x37>
            page_remove(pgdir, va);
f01010a9:	83 ec 08             	sub    $0x8,%esp
f01010ac:	57                   	push   %edi
f01010ad:	ff 75 08             	pushl  0x8(%ebp)
f01010b0:	e8 91 ff ff ff       	call   f0101046 <page_remove>
f01010b5:	83 c4 10             	add    $0x10,%esp
        if (page_free_list == pp)
f01010b8:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01010bd:	39 f0                	cmp    %esi,%eax
f01010bf:	75 07                	jne    f01010c8 <page_insert+0x47>
            page_free_list = page_free_list->pp_link;
f01010c1:	8b 00                	mov    (%eax),%eax
f01010c3:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
    }
    else {
            return -E_NO_MEM;
    }
    *pte = page2pa(pp) | perm | PTE_P;
f01010c8:	89 f0                	mov    %esi,%eax
f01010ca:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01010d0:	c1 f8 03             	sar    $0x3,%eax
f01010d3:	c1 e0 0c             	shl    $0xc,%eax
f01010d6:	8b 55 14             	mov    0x14(%ebp),%edx
f01010d9:	83 ca 01             	or     $0x1,%edx
f01010dc:	09 d0                	or     %edx,%eax
f01010de:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++;
f01010e0:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

    return 0;
f01010e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ea:	eb 05                	jmp    f01010f1 <page_insert+0x70>
            page_remove(pgdir, va);
        if (page_free_list == pp)
            page_free_list = page_free_list->pp_link;
    }
    else {
            return -E_NO_MEM;
f01010ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    }
    *pte = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;

    return 0;
}
f01010f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f4:	5b                   	pop    %ebx
f01010f5:	5e                   	pop    %esi
f01010f6:	5f                   	pop    %edi
f01010f7:	5d                   	pop    %ebp
f01010f8:	c3                   	ret    

f01010f9 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010f9:	55                   	push   %ebp
f01010fa:	89 e5                	mov    %esp,%ebp
f01010fc:	57                   	push   %edi
f01010fd:	56                   	push   %esi
f01010fe:	53                   	push   %ebx
f01010ff:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101102:	b8 15 00 00 00       	mov    $0x15,%eax
f0101107:	e8 1f f8 ff ff       	call   f010092b <nvram_read>
f010110c:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f010110e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101113:	e8 13 f8 ff ff       	call   f010092b <nvram_read>
f0101118:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010111a:	b8 34 00 00 00       	mov    $0x34,%eax
f010111f:	e8 07 f8 ff ff       	call   f010092b <nvram_read>
f0101124:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
f0101127:	8d 98 00 40 00 00    	lea    0x4000(%eax),%ebx
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010112d:	85 c0                	test   %eax,%eax
f010112f:	75 0b                	jne    f010113c <mem_init+0x43>
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101131:	8d 9f 00 04 00 00    	lea    0x400(%edi),%ebx
f0101137:	85 ff                	test   %edi,%edi
f0101139:	0f 44 de             	cmove  %esi,%ebx
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010113c:	89 da                	mov    %ebx,%edx
f010113e:	c1 ea 02             	shr    $0x2,%edx
f0101141:	89 15 44 79 11 f0    	mov    %edx,0xf0117944
	npages_basemem = basemem / (PGSIZE / 1024);
    cprintf("\n npages = %u  npages_basemem = %u extmem = %d ext16mem = %d\n", npages,npages_basemem,extmem,ext16mem);
f0101147:	83 ec 0c             	sub    $0xc,%esp
f010114a:	50                   	push   %eax
f010114b:	57                   	push   %edi
f010114c:	89 f0                	mov    %esi,%eax
f010114e:	c1 e8 02             	shr    $0x2,%eax
f0101151:	50                   	push   %eax
f0101152:	52                   	push   %edx
f0101153:	68 7c 41 10 f0       	push   $0xf010417c
f0101158:	e8 7a 16 00 00       	call   f01027d7 <cprintf>
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010115d:	83 c4 20             	add    $0x20,%esp
f0101160:	89 d8                	mov    %ebx,%eax
f0101162:	29 f0                	sub    %esi,%eax
f0101164:	50                   	push   %eax
f0101165:	56                   	push   %esi
f0101166:	53                   	push   %ebx
f0101167:	68 bc 41 10 f0       	push   $0xf01041bc
f010116c:	e8 66 16 00 00       	call   f01027d7 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101171:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101176:	e8 d9 f7 ff ff       	call   f0100954 <boot_alloc>
f010117b:	a3 48 79 11 f0       	mov    %eax,0xf0117948
	memset(kern_pgdir, 0, PGSIZE);
f0101180:	83 c4 0c             	add    $0xc,%esp
f0101183:	68 00 10 00 00       	push   $0x1000
f0101188:	6a 00                	push   $0x0
f010118a:	50                   	push   %eax
f010118b:	e8 97 21 00 00       	call   f0103327 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101190:	a1 48 79 11 f0       	mov    0xf0117948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101195:	83 c4 10             	add    $0x10,%esp
f0101198:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010119d:	77 15                	ja     f01011b4 <mem_init+0xbb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010119f:	50                   	push   %eax
f01011a0:	68 f8 40 10 f0       	push   $0xf01040f8
f01011a5:	68 9a 00 00 00       	push   $0x9a
f01011aa:	68 12 3d 10 f0       	push   $0xf0103d12
f01011af:	e8 37 ef ff ff       	call   f01000eb <_panic>
f01011b4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011ba:	83 ca 05             	or     $0x5,%edx
f01011bd:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01011c3:	a1 44 79 11 f0       	mov    0xf0117944,%eax
f01011c8:	c1 e0 03             	shl    $0x3,%eax
f01011cb:	e8 84 f7 ff ff       	call   f0100954 <boot_alloc>
f01011d0:	a3 4c 79 11 f0       	mov    %eax,0xf011794c
    size_t i;
    for (i = 0; i < npages ; i++) {
f01011d5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011da:	eb 2d                	jmp    f0101209 <mem_init+0x110>
		pages[i].pp_link = NULL;
f01011dc:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01011e1:	c7 04 d8 00 00 00 00 	movl   $0x0,(%eax,%ebx,8)
		pages[i].pp_ref = 0;
f01011e8:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01011ed:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f01011f0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		memset(&pages[i], 0, sizeof(struct PageInfo));
f01011f6:	83 ec 04             	sub    $0x4,%esp
f01011f9:	6a 08                	push   $0x8
f01011fb:	6a 00                	push   $0x0
f01011fd:	50                   	push   %eax
f01011fe:	e8 24 21 00 00       	call   f0103327 <memset>
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    
    pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
    size_t i;
    for (i = 0; i < npages ; i++) {
f0101203:	83 c3 01             	add    $0x1,%ebx
f0101206:	83 c4 10             	add    $0x10,%esp
f0101209:	3b 1d 44 79 11 f0    	cmp    0xf0117944,%ebx
f010120f:	72 cb                	jb     f01011dc <mem_init+0xe3>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101211:	e8 bd fa ff ff       	call   f0100cd3 <page_init>
	check_page_free_list(1);
f0101216:	b8 01 00 00 00       	mov    $0x1,%eax
f010121b:	e8 ff f7 ff ff       	call   f0100a1f <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101220:	83 3d 4c 79 11 f0 00 	cmpl   $0x0,0xf011794c
f0101227:	75 17                	jne    f0101240 <mem_init+0x147>
		panic("'pages' is a null pointer!");
f0101229:	83 ec 04             	sub    $0x4,%esp
f010122c:	68 e3 3d 10 f0       	push   $0xf0103de3
f0101231:	68 88 02 00 00       	push   $0x288
f0101236:	68 12 3d 10 f0       	push   $0xf0103d12
f010123b:	e8 ab ee ff ff       	call   f01000eb <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101240:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101245:	bb 00 00 00 00       	mov    $0x0,%ebx
f010124a:	eb 05                	jmp    f0101251 <mem_init+0x158>
		++nfree;
f010124c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010124f:	8b 00                	mov    (%eax),%eax
f0101251:	85 c0                	test   %eax,%eax
f0101253:	75 f7                	jne    f010124c <mem_init+0x153>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101255:	83 ec 0c             	sub    $0xc,%esp
f0101258:	6a 00                	push   $0x0
f010125a:	e8 f5 fa ff ff       	call   f0100d54 <page_alloc>
f010125f:	89 c7                	mov    %eax,%edi
f0101261:	83 c4 10             	add    $0x10,%esp
f0101264:	85 c0                	test   %eax,%eax
f0101266:	75 19                	jne    f0101281 <mem_init+0x188>
f0101268:	68 fe 3d 10 f0       	push   $0xf0103dfe
f010126d:	68 38 3d 10 f0       	push   $0xf0103d38
f0101272:	68 90 02 00 00       	push   $0x290
f0101277:	68 12 3d 10 f0       	push   $0xf0103d12
f010127c:	e8 6a ee ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f0101281:	83 ec 0c             	sub    $0xc,%esp
f0101284:	6a 00                	push   $0x0
f0101286:	e8 c9 fa ff ff       	call   f0100d54 <page_alloc>
f010128b:	89 c6                	mov    %eax,%esi
f010128d:	83 c4 10             	add    $0x10,%esp
f0101290:	85 c0                	test   %eax,%eax
f0101292:	75 19                	jne    f01012ad <mem_init+0x1b4>
f0101294:	68 14 3e 10 f0       	push   $0xf0103e14
f0101299:	68 38 3d 10 f0       	push   $0xf0103d38
f010129e:	68 91 02 00 00       	push   $0x291
f01012a3:	68 12 3d 10 f0       	push   $0xf0103d12
f01012a8:	e8 3e ee ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f01012ad:	83 ec 0c             	sub    $0xc,%esp
f01012b0:	6a 00                	push   $0x0
f01012b2:	e8 9d fa ff ff       	call   f0100d54 <page_alloc>
f01012b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012ba:	83 c4 10             	add    $0x10,%esp
f01012bd:	85 c0                	test   %eax,%eax
f01012bf:	75 19                	jne    f01012da <mem_init+0x1e1>
f01012c1:	68 2a 3e 10 f0       	push   $0xf0103e2a
f01012c6:	68 38 3d 10 f0       	push   $0xf0103d38
f01012cb:	68 92 02 00 00       	push   $0x292
f01012d0:	68 12 3d 10 f0       	push   $0xf0103d12
f01012d5:	e8 11 ee ff ff       	call   f01000eb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012da:	39 f7                	cmp    %esi,%edi
f01012dc:	75 19                	jne    f01012f7 <mem_init+0x1fe>
f01012de:	68 40 3e 10 f0       	push   $0xf0103e40
f01012e3:	68 38 3d 10 f0       	push   $0xf0103d38
f01012e8:	68 95 02 00 00       	push   $0x295
f01012ed:	68 12 3d 10 f0       	push   $0xf0103d12
f01012f2:	e8 f4 ed ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012fa:	39 c6                	cmp    %eax,%esi
f01012fc:	74 04                	je     f0101302 <mem_init+0x209>
f01012fe:	39 c7                	cmp    %eax,%edi
f0101300:	75 19                	jne    f010131b <mem_init+0x222>
f0101302:	68 f8 41 10 f0       	push   $0xf01041f8
f0101307:	68 38 3d 10 f0       	push   $0xf0103d38
f010130c:	68 96 02 00 00       	push   $0x296
f0101311:	68 12 3d 10 f0       	push   $0xf0103d12
f0101316:	e8 d0 ed ff ff       	call   f01000eb <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010131b:	8b 0d 4c 79 11 f0    	mov    0xf011794c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101321:	8b 15 44 79 11 f0    	mov    0xf0117944,%edx
f0101327:	c1 e2 0c             	shl    $0xc,%edx
f010132a:	89 f8                	mov    %edi,%eax
f010132c:	29 c8                	sub    %ecx,%eax
f010132e:	c1 f8 03             	sar    $0x3,%eax
f0101331:	c1 e0 0c             	shl    $0xc,%eax
f0101334:	39 d0                	cmp    %edx,%eax
f0101336:	72 19                	jb     f0101351 <mem_init+0x258>
f0101338:	68 52 3e 10 f0       	push   $0xf0103e52
f010133d:	68 38 3d 10 f0       	push   $0xf0103d38
f0101342:	68 97 02 00 00       	push   $0x297
f0101347:	68 12 3d 10 f0       	push   $0xf0103d12
f010134c:	e8 9a ed ff ff       	call   f01000eb <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101351:	89 f0                	mov    %esi,%eax
f0101353:	29 c8                	sub    %ecx,%eax
f0101355:	c1 f8 03             	sar    $0x3,%eax
f0101358:	c1 e0 0c             	shl    $0xc,%eax
f010135b:	39 c2                	cmp    %eax,%edx
f010135d:	77 19                	ja     f0101378 <mem_init+0x27f>
f010135f:	68 6f 3e 10 f0       	push   $0xf0103e6f
f0101364:	68 38 3d 10 f0       	push   $0xf0103d38
f0101369:	68 98 02 00 00       	push   $0x298
f010136e:	68 12 3d 10 f0       	push   $0xf0103d12
f0101373:	e8 73 ed ff ff       	call   f01000eb <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010137b:	29 c8                	sub    %ecx,%eax
f010137d:	c1 f8 03             	sar    $0x3,%eax
f0101380:	c1 e0 0c             	shl    $0xc,%eax
f0101383:	39 c2                	cmp    %eax,%edx
f0101385:	77 19                	ja     f01013a0 <mem_init+0x2a7>
f0101387:	68 8c 3e 10 f0       	push   $0xf0103e8c
f010138c:	68 38 3d 10 f0       	push   $0xf0103d38
f0101391:	68 99 02 00 00       	push   $0x299
f0101396:	68 12 3d 10 f0       	push   $0xf0103d12
f010139b:	e8 4b ed ff ff       	call   f01000eb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013a0:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013a8:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01013af:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013b2:	83 ec 0c             	sub    $0xc,%esp
f01013b5:	6a 00                	push   $0x0
f01013b7:	e8 98 f9 ff ff       	call   f0100d54 <page_alloc>
f01013bc:	83 c4 10             	add    $0x10,%esp
f01013bf:	85 c0                	test   %eax,%eax
f01013c1:	74 19                	je     f01013dc <mem_init+0x2e3>
f01013c3:	68 a9 3e 10 f0       	push   $0xf0103ea9
f01013c8:	68 38 3d 10 f0       	push   $0xf0103d38
f01013cd:	68 a0 02 00 00       	push   $0x2a0
f01013d2:	68 12 3d 10 f0       	push   $0xf0103d12
f01013d7:	e8 0f ed ff ff       	call   f01000eb <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013dc:	83 ec 0c             	sub    $0xc,%esp
f01013df:	57                   	push   %edi
f01013e0:	e8 df f9 ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f01013e5:	89 34 24             	mov    %esi,(%esp)
f01013e8:	e8 d7 f9 ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f01013ed:	83 c4 04             	add    $0x4,%esp
f01013f0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013f3:	e8 cc f9 ff ff       	call   f0100dc4 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013ff:	e8 50 f9 ff ff       	call   f0100d54 <page_alloc>
f0101404:	89 c6                	mov    %eax,%esi
f0101406:	83 c4 10             	add    $0x10,%esp
f0101409:	85 c0                	test   %eax,%eax
f010140b:	75 19                	jne    f0101426 <mem_init+0x32d>
f010140d:	68 fe 3d 10 f0       	push   $0xf0103dfe
f0101412:	68 38 3d 10 f0       	push   $0xf0103d38
f0101417:	68 a7 02 00 00       	push   $0x2a7
f010141c:	68 12 3d 10 f0       	push   $0xf0103d12
f0101421:	e8 c5 ec ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f0101426:	83 ec 0c             	sub    $0xc,%esp
f0101429:	6a 00                	push   $0x0
f010142b:	e8 24 f9 ff ff       	call   f0100d54 <page_alloc>
f0101430:	89 c7                	mov    %eax,%edi
f0101432:	83 c4 10             	add    $0x10,%esp
f0101435:	85 c0                	test   %eax,%eax
f0101437:	75 19                	jne    f0101452 <mem_init+0x359>
f0101439:	68 14 3e 10 f0       	push   $0xf0103e14
f010143e:	68 38 3d 10 f0       	push   $0xf0103d38
f0101443:	68 a8 02 00 00       	push   $0x2a8
f0101448:	68 12 3d 10 f0       	push   $0xf0103d12
f010144d:	e8 99 ec ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f0101452:	83 ec 0c             	sub    $0xc,%esp
f0101455:	6a 00                	push   $0x0
f0101457:	e8 f8 f8 ff ff       	call   f0100d54 <page_alloc>
f010145c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010145f:	83 c4 10             	add    $0x10,%esp
f0101462:	85 c0                	test   %eax,%eax
f0101464:	75 19                	jne    f010147f <mem_init+0x386>
f0101466:	68 2a 3e 10 f0       	push   $0xf0103e2a
f010146b:	68 38 3d 10 f0       	push   $0xf0103d38
f0101470:	68 a9 02 00 00       	push   $0x2a9
f0101475:	68 12 3d 10 f0       	push   $0xf0103d12
f010147a:	e8 6c ec ff ff       	call   f01000eb <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010147f:	39 fe                	cmp    %edi,%esi
f0101481:	75 19                	jne    f010149c <mem_init+0x3a3>
f0101483:	68 40 3e 10 f0       	push   $0xf0103e40
f0101488:	68 38 3d 10 f0       	push   $0xf0103d38
f010148d:	68 ab 02 00 00       	push   $0x2ab
f0101492:	68 12 3d 10 f0       	push   $0xf0103d12
f0101497:	e8 4f ec ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010149c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149f:	39 c7                	cmp    %eax,%edi
f01014a1:	74 04                	je     f01014a7 <mem_init+0x3ae>
f01014a3:	39 c6                	cmp    %eax,%esi
f01014a5:	75 19                	jne    f01014c0 <mem_init+0x3c7>
f01014a7:	68 f8 41 10 f0       	push   $0xf01041f8
f01014ac:	68 38 3d 10 f0       	push   $0xf0103d38
f01014b1:	68 ac 02 00 00       	push   $0x2ac
f01014b6:	68 12 3d 10 f0       	push   $0xf0103d12
f01014bb:	e8 2b ec ff ff       	call   f01000eb <_panic>
	assert(!page_alloc(0));
f01014c0:	83 ec 0c             	sub    $0xc,%esp
f01014c3:	6a 00                	push   $0x0
f01014c5:	e8 8a f8 ff ff       	call   f0100d54 <page_alloc>
f01014ca:	83 c4 10             	add    $0x10,%esp
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	74 19                	je     f01014ea <mem_init+0x3f1>
f01014d1:	68 a9 3e 10 f0       	push   $0xf0103ea9
f01014d6:	68 38 3d 10 f0       	push   $0xf0103d38
f01014db:	68 ad 02 00 00       	push   $0x2ad
f01014e0:	68 12 3d 10 f0       	push   $0xf0103d12
f01014e5:	e8 01 ec ff ff       	call   f01000eb <_panic>
f01014ea:	89 f0                	mov    %esi,%eax
f01014ec:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01014f2:	c1 f8 03             	sar    $0x3,%eax
f01014f5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f8:	89 c2                	mov    %eax,%edx
f01014fa:	c1 ea 0c             	shr    $0xc,%edx
f01014fd:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0101503:	72 12                	jb     f0101517 <mem_init+0x41e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101505:	50                   	push   %eax
f0101506:	68 10 40 10 f0       	push   $0xf0104010
f010150b:	6a 52                	push   $0x52
f010150d:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0101512:	e8 d4 eb ff ff       	call   f01000eb <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101517:	83 ec 04             	sub    $0x4,%esp
f010151a:	68 00 10 00 00       	push   $0x1000
f010151f:	6a 01                	push   $0x1
f0101521:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101526:	50                   	push   %eax
f0101527:	e8 fb 1d 00 00       	call   f0103327 <memset>
	page_free(pp0);
f010152c:	89 34 24             	mov    %esi,(%esp)
f010152f:	e8 90 f8 ff ff       	call   f0100dc4 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101534:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010153b:	e8 14 f8 ff ff       	call   f0100d54 <page_alloc>
f0101540:	83 c4 10             	add    $0x10,%esp
f0101543:	85 c0                	test   %eax,%eax
f0101545:	75 19                	jne    f0101560 <mem_init+0x467>
f0101547:	68 b8 3e 10 f0       	push   $0xf0103eb8
f010154c:	68 38 3d 10 f0       	push   $0xf0103d38
f0101551:	68 b2 02 00 00       	push   $0x2b2
f0101556:	68 12 3d 10 f0       	push   $0xf0103d12
f010155b:	e8 8b eb ff ff       	call   f01000eb <_panic>
	assert(pp && pp0 == pp);
f0101560:	39 c6                	cmp    %eax,%esi
f0101562:	74 19                	je     f010157d <mem_init+0x484>
f0101564:	68 d6 3e 10 f0       	push   $0xf0103ed6
f0101569:	68 38 3d 10 f0       	push   $0xf0103d38
f010156e:	68 b3 02 00 00       	push   $0x2b3
f0101573:	68 12 3d 10 f0       	push   $0xf0103d12
f0101578:	e8 6e eb ff ff       	call   f01000eb <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010157d:	89 f0                	mov    %esi,%eax
f010157f:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101585:	c1 f8 03             	sar    $0x3,%eax
f0101588:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010158b:	89 c2                	mov    %eax,%edx
f010158d:	c1 ea 0c             	shr    $0xc,%edx
f0101590:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0101596:	72 12                	jb     f01015aa <mem_init+0x4b1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101598:	50                   	push   %eax
f0101599:	68 10 40 10 f0       	push   $0xf0104010
f010159e:	6a 52                	push   $0x52
f01015a0:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01015a5:	e8 41 eb ff ff       	call   f01000eb <_panic>
f01015aa:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015b0:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015b6:	80 38 00             	cmpb   $0x0,(%eax)
f01015b9:	74 19                	je     f01015d4 <mem_init+0x4db>
f01015bb:	68 e6 3e 10 f0       	push   $0xf0103ee6
f01015c0:	68 38 3d 10 f0       	push   $0xf0103d38
f01015c5:	68 b6 02 00 00       	push   $0x2b6
f01015ca:	68 12 3d 10 f0       	push   $0xf0103d12
f01015cf:	e8 17 eb ff ff       	call   f01000eb <_panic>
f01015d4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01015d7:	39 d0                	cmp    %edx,%eax
f01015d9:	75 db                	jne    f01015b6 <mem_init+0x4bd>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015de:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f01015e3:	83 ec 0c             	sub    $0xc,%esp
f01015e6:	56                   	push   %esi
f01015e7:	e8 d8 f7 ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f01015ec:	89 3c 24             	mov    %edi,(%esp)
f01015ef:	e8 d0 f7 ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f01015f4:	83 c4 04             	add    $0x4,%esp
f01015f7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015fa:	e8 c5 f7 ff ff       	call   f0100dc4 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015ff:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101604:	83 c4 10             	add    $0x10,%esp
f0101607:	eb 05                	jmp    f010160e <mem_init+0x515>
		--nfree;
f0101609:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010160c:	8b 00                	mov    (%eax),%eax
f010160e:	85 c0                	test   %eax,%eax
f0101610:	75 f7                	jne    f0101609 <mem_init+0x510>
		--nfree;
	assert(nfree == 0);
f0101612:	85 db                	test   %ebx,%ebx
f0101614:	74 19                	je     f010162f <mem_init+0x536>
f0101616:	68 f0 3e 10 f0       	push   $0xf0103ef0
f010161b:	68 38 3d 10 f0       	push   $0xf0103d38
f0101620:	68 c3 02 00 00       	push   $0x2c3
f0101625:	68 12 3d 10 f0       	push   $0xf0103d12
f010162a:	e8 bc ea ff ff       	call   f01000eb <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010162f:	83 ec 0c             	sub    $0xc,%esp
f0101632:	68 18 42 10 f0       	push   $0xf0104218
f0101637:	e8 9b 11 00 00       	call   f01027d7 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010163c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101643:	e8 0c f7 ff ff       	call   f0100d54 <page_alloc>
f0101648:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010164b:	83 c4 10             	add    $0x10,%esp
f010164e:	85 c0                	test   %eax,%eax
f0101650:	75 19                	jne    f010166b <mem_init+0x572>
f0101652:	68 fe 3d 10 f0       	push   $0xf0103dfe
f0101657:	68 38 3d 10 f0       	push   $0xf0103d38
f010165c:	68 1c 03 00 00       	push   $0x31c
f0101661:	68 12 3d 10 f0       	push   $0xf0103d12
f0101666:	e8 80 ea ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f010166b:	83 ec 0c             	sub    $0xc,%esp
f010166e:	6a 00                	push   $0x0
f0101670:	e8 df f6 ff ff       	call   f0100d54 <page_alloc>
f0101675:	89 c3                	mov    %eax,%ebx
f0101677:	83 c4 10             	add    $0x10,%esp
f010167a:	85 c0                	test   %eax,%eax
f010167c:	75 19                	jne    f0101697 <mem_init+0x59e>
f010167e:	68 14 3e 10 f0       	push   $0xf0103e14
f0101683:	68 38 3d 10 f0       	push   $0xf0103d38
f0101688:	68 1d 03 00 00       	push   $0x31d
f010168d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101692:	e8 54 ea ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f0101697:	83 ec 0c             	sub    $0xc,%esp
f010169a:	6a 00                	push   $0x0
f010169c:	e8 b3 f6 ff ff       	call   f0100d54 <page_alloc>
f01016a1:	89 c6                	mov    %eax,%esi
f01016a3:	83 c4 10             	add    $0x10,%esp
f01016a6:	85 c0                	test   %eax,%eax
f01016a8:	75 19                	jne    f01016c3 <mem_init+0x5ca>
f01016aa:	68 2a 3e 10 f0       	push   $0xf0103e2a
f01016af:	68 38 3d 10 f0       	push   $0xf0103d38
f01016b4:	68 1e 03 00 00       	push   $0x31e
f01016b9:	68 12 3d 10 f0       	push   $0xf0103d12
f01016be:	e8 28 ea ff ff       	call   f01000eb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016c3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01016c6:	75 19                	jne    f01016e1 <mem_init+0x5e8>
f01016c8:	68 40 3e 10 f0       	push   $0xf0103e40
f01016cd:	68 38 3d 10 f0       	push   $0xf0103d38
f01016d2:	68 21 03 00 00       	push   $0x321
f01016d7:	68 12 3d 10 f0       	push   $0xf0103d12
f01016dc:	e8 0a ea ff ff       	call   f01000eb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016e1:	39 c3                	cmp    %eax,%ebx
f01016e3:	74 05                	je     f01016ea <mem_init+0x5f1>
f01016e5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016e8:	75 19                	jne    f0101703 <mem_init+0x60a>
f01016ea:	68 f8 41 10 f0       	push   $0xf01041f8
f01016ef:	68 38 3d 10 f0       	push   $0xf0103d38
f01016f4:	68 22 03 00 00       	push   $0x322
f01016f9:	68 12 3d 10 f0       	push   $0xf0103d12
f01016fe:	e8 e8 e9 ff ff       	call   f01000eb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101703:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101708:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010170b:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101712:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101715:	83 ec 0c             	sub    $0xc,%esp
f0101718:	6a 00                	push   $0x0
f010171a:	e8 35 f6 ff ff       	call   f0100d54 <page_alloc>
f010171f:	83 c4 10             	add    $0x10,%esp
f0101722:	85 c0                	test   %eax,%eax
f0101724:	74 19                	je     f010173f <mem_init+0x646>
f0101726:	68 a9 3e 10 f0       	push   $0xf0103ea9
f010172b:	68 38 3d 10 f0       	push   $0xf0103d38
f0101730:	68 29 03 00 00       	push   $0x329
f0101735:	68 12 3d 10 f0       	push   $0xf0103d12
f010173a:	e8 ac e9 ff ff       	call   f01000eb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010173f:	83 ec 04             	sub    $0x4,%esp
f0101742:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101745:	50                   	push   %eax
f0101746:	6a 00                	push   $0x0
f0101748:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010174e:	e8 a0 f8 ff ff       	call   f0100ff3 <page_lookup>
f0101753:	83 c4 10             	add    $0x10,%esp
f0101756:	85 c0                	test   %eax,%eax
f0101758:	74 19                	je     f0101773 <mem_init+0x67a>
f010175a:	68 38 42 10 f0       	push   $0xf0104238
f010175f:	68 38 3d 10 f0       	push   $0xf0103d38
f0101764:	68 2c 03 00 00       	push   $0x32c
f0101769:	68 12 3d 10 f0       	push   $0xf0103d12
f010176e:	e8 78 e9 ff ff       	call   f01000eb <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101773:	6a 02                	push   $0x2
f0101775:	6a 00                	push   $0x0
f0101777:	53                   	push   %ebx
f0101778:	ff 35 48 79 11 f0    	pushl  0xf0117948
f010177e:	e8 fe f8 ff ff       	call   f0101081 <page_insert>
f0101783:	83 c4 10             	add    $0x10,%esp
f0101786:	85 c0                	test   %eax,%eax
f0101788:	78 19                	js     f01017a3 <mem_init+0x6aa>
f010178a:	68 70 42 10 f0       	push   $0xf0104270
f010178f:	68 38 3d 10 f0       	push   $0xf0103d38
f0101794:	68 2f 03 00 00       	push   $0x32f
f0101799:	68 12 3d 10 f0       	push   $0xf0103d12
f010179e:	e8 48 e9 ff ff       	call   f01000eb <_panic>
	
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017a3:	83 ec 0c             	sub    $0xc,%esp
f01017a6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a9:	e8 16 f6 ff ff       	call   f0100dc4 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017ae:	6a 02                	push   $0x2
f01017b0:	6a 00                	push   $0x0
f01017b2:	53                   	push   %ebx
f01017b3:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01017b9:	e8 c3 f8 ff ff       	call   f0101081 <page_insert>
f01017be:	83 c4 20             	add    $0x20,%esp
f01017c1:	85 c0                	test   %eax,%eax
f01017c3:	74 19                	je     f01017de <mem_init+0x6e5>
f01017c5:	68 a0 42 10 f0       	push   $0xf01042a0
f01017ca:	68 38 3d 10 f0       	push   $0xf0103d38
f01017cf:	68 33 03 00 00       	push   $0x333
f01017d4:	68 12 3d 10 f0       	push   $0xf0103d12
f01017d9:	e8 0d e9 ff ff       	call   f01000eb <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017de:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017e4:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01017e9:	89 c1                	mov    %eax,%ecx
f01017eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017ee:	8b 17                	mov    (%edi),%edx
f01017f0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f9:	29 c8                	sub    %ecx,%eax
f01017fb:	c1 f8 03             	sar    $0x3,%eax
f01017fe:	c1 e0 0c             	shl    $0xc,%eax
f0101801:	39 c2                	cmp    %eax,%edx
f0101803:	74 19                	je     f010181e <mem_init+0x725>
f0101805:	68 d0 42 10 f0       	push   $0xf01042d0
f010180a:	68 38 3d 10 f0       	push   $0xf0103d38
f010180f:	68 34 03 00 00       	push   $0x334
f0101814:	68 12 3d 10 f0       	push   $0xf0103d12
f0101819:	e8 cd e8 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010181e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101823:	89 f8                	mov    %edi,%eax
f0101825:	e8 91 f1 ff ff       	call   f01009bb <check_va2pa>
f010182a:	89 da                	mov    %ebx,%edx
f010182c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010182f:	c1 fa 03             	sar    $0x3,%edx
f0101832:	c1 e2 0c             	shl    $0xc,%edx
f0101835:	39 d0                	cmp    %edx,%eax
f0101837:	74 19                	je     f0101852 <mem_init+0x759>
f0101839:	68 f8 42 10 f0       	push   $0xf01042f8
f010183e:	68 38 3d 10 f0       	push   $0xf0103d38
f0101843:	68 35 03 00 00       	push   $0x335
f0101848:	68 12 3d 10 f0       	push   $0xf0103d12
f010184d:	e8 99 e8 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 1);
f0101852:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101857:	74 19                	je     f0101872 <mem_init+0x779>
f0101859:	68 fb 3e 10 f0       	push   $0xf0103efb
f010185e:	68 38 3d 10 f0       	push   $0xf0103d38
f0101863:	68 36 03 00 00       	push   $0x336
f0101868:	68 12 3d 10 f0       	push   $0xf0103d12
f010186d:	e8 79 e8 ff ff       	call   f01000eb <_panic>
	assert(pp0->pp_ref == 1);
f0101872:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101875:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010187a:	74 19                	je     f0101895 <mem_init+0x79c>
f010187c:	68 0c 3f 10 f0       	push   $0xf0103f0c
f0101881:	68 38 3d 10 f0       	push   $0xf0103d38
f0101886:	68 37 03 00 00       	push   $0x337
f010188b:	68 12 3d 10 f0       	push   $0xf0103d12
f0101890:	e8 56 e8 ff ff       	call   f01000eb <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101895:	6a 02                	push   $0x2
f0101897:	68 00 10 00 00       	push   $0x1000
f010189c:	56                   	push   %esi
f010189d:	57                   	push   %edi
f010189e:	e8 de f7 ff ff       	call   f0101081 <page_insert>
f01018a3:	83 c4 10             	add    $0x10,%esp
f01018a6:	85 c0                	test   %eax,%eax
f01018a8:	74 19                	je     f01018c3 <mem_init+0x7ca>
f01018aa:	68 28 43 10 f0       	push   $0xf0104328
f01018af:	68 38 3d 10 f0       	push   $0xf0103d38
f01018b4:	68 3a 03 00 00       	push   $0x33a
f01018b9:	68 12 3d 10 f0       	push   $0xf0103d12
f01018be:	e8 28 e8 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018c3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018c8:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f01018cd:	e8 e9 f0 ff ff       	call   f01009bb <check_va2pa>
f01018d2:	89 f2                	mov    %esi,%edx
f01018d4:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f01018da:	c1 fa 03             	sar    $0x3,%edx
f01018dd:	c1 e2 0c             	shl    $0xc,%edx
f01018e0:	39 d0                	cmp    %edx,%eax
f01018e2:	74 19                	je     f01018fd <mem_init+0x804>
f01018e4:	68 64 43 10 f0       	push   $0xf0104364
f01018e9:	68 38 3d 10 f0       	push   $0xf0103d38
f01018ee:	68 3b 03 00 00       	push   $0x33b
f01018f3:	68 12 3d 10 f0       	push   $0xf0103d12
f01018f8:	e8 ee e7 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f01018fd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101902:	74 19                	je     f010191d <mem_init+0x824>
f0101904:	68 1d 3f 10 f0       	push   $0xf0103f1d
f0101909:	68 38 3d 10 f0       	push   $0xf0103d38
f010190e:	68 3c 03 00 00       	push   $0x33c
f0101913:	68 12 3d 10 f0       	push   $0xf0103d12
f0101918:	e8 ce e7 ff ff       	call   f01000eb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010191d:	83 ec 0c             	sub    $0xc,%esp
f0101920:	6a 00                	push   $0x0
f0101922:	e8 2d f4 ff ff       	call   f0100d54 <page_alloc>
f0101927:	83 c4 10             	add    $0x10,%esp
f010192a:	85 c0                	test   %eax,%eax
f010192c:	74 19                	je     f0101947 <mem_init+0x84e>
f010192e:	68 a9 3e 10 f0       	push   $0xf0103ea9
f0101933:	68 38 3d 10 f0       	push   $0xf0103d38
f0101938:	68 3f 03 00 00       	push   $0x33f
f010193d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101942:	e8 a4 e7 ff ff       	call   f01000eb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101947:	6a 02                	push   $0x2
f0101949:	68 00 10 00 00       	push   $0x1000
f010194e:	56                   	push   %esi
f010194f:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101955:	e8 27 f7 ff ff       	call   f0101081 <page_insert>
f010195a:	83 c4 10             	add    $0x10,%esp
f010195d:	85 c0                	test   %eax,%eax
f010195f:	74 19                	je     f010197a <mem_init+0x881>
f0101961:	68 28 43 10 f0       	push   $0xf0104328
f0101966:	68 38 3d 10 f0       	push   $0xf0103d38
f010196b:	68 42 03 00 00       	push   $0x342
f0101970:	68 12 3d 10 f0       	push   $0xf0103d12
f0101975:	e8 71 e7 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010197a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010197f:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0101984:	e8 32 f0 ff ff       	call   f01009bb <check_va2pa>
f0101989:	89 f2                	mov    %esi,%edx
f010198b:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101991:	c1 fa 03             	sar    $0x3,%edx
f0101994:	c1 e2 0c             	shl    $0xc,%edx
f0101997:	39 d0                	cmp    %edx,%eax
f0101999:	74 19                	je     f01019b4 <mem_init+0x8bb>
f010199b:	68 64 43 10 f0       	push   $0xf0104364
f01019a0:	68 38 3d 10 f0       	push   $0xf0103d38
f01019a5:	68 43 03 00 00       	push   $0x343
f01019aa:	68 12 3d 10 f0       	push   $0xf0103d12
f01019af:	e8 37 e7 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f01019b4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019b9:	74 19                	je     f01019d4 <mem_init+0x8db>
f01019bb:	68 1d 3f 10 f0       	push   $0xf0103f1d
f01019c0:	68 38 3d 10 f0       	push   $0xf0103d38
f01019c5:	68 44 03 00 00       	push   $0x344
f01019ca:	68 12 3d 10 f0       	push   $0xf0103d12
f01019cf:	e8 17 e7 ff ff       	call   f01000eb <_panic>
	
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019d4:	83 ec 0c             	sub    $0xc,%esp
f01019d7:	6a 00                	push   $0x0
f01019d9:	e8 76 f3 ff ff       	call   f0100d54 <page_alloc>
f01019de:	83 c4 10             	add    $0x10,%esp
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	74 19                	je     f01019fe <mem_init+0x905>
f01019e5:	68 a9 3e 10 f0       	push   $0xf0103ea9
f01019ea:	68 38 3d 10 f0       	push   $0xf0103d38
f01019ef:	68 48 03 00 00       	push   $0x348
f01019f4:	68 12 3d 10 f0       	push   $0xf0103d12
f01019f9:	e8 ed e6 ff ff       	call   f01000eb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019fe:	8b 15 48 79 11 f0    	mov    0xf0117948,%edx
f0101a04:	8b 02                	mov    (%edx),%eax
f0101a06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a0b:	89 c1                	mov    %eax,%ecx
f0101a0d:	c1 e9 0c             	shr    $0xc,%ecx
f0101a10:	3b 0d 44 79 11 f0    	cmp    0xf0117944,%ecx
f0101a16:	72 15                	jb     f0101a2d <mem_init+0x934>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a18:	50                   	push   %eax
f0101a19:	68 10 40 10 f0       	push   $0xf0104010
f0101a1e:	68 4b 03 00 00       	push   $0x34b
f0101a23:	68 12 3d 10 f0       	push   $0xf0103d12
f0101a28:	e8 be e6 ff ff       	call   f01000eb <_panic>
f0101a2d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a35:	83 ec 04             	sub    $0x4,%esp
f0101a38:	6a 00                	push   $0x0
f0101a3a:	68 00 10 00 00       	push   $0x1000
f0101a3f:	52                   	push   %edx
f0101a40:	e8 24 f4 ff ff       	call   f0100e69 <pgdir_walk>
f0101a45:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a48:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	39 d0                	cmp    %edx,%eax
f0101a50:	74 19                	je     f0101a6b <mem_init+0x972>
f0101a52:	68 94 43 10 f0       	push   $0xf0104394
f0101a57:	68 38 3d 10 f0       	push   $0xf0103d38
f0101a5c:	68 4c 03 00 00       	push   $0x34c
f0101a61:	68 12 3d 10 f0       	push   $0xf0103d12
f0101a66:	e8 80 e6 ff ff       	call   f01000eb <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a6b:	6a 06                	push   $0x6
f0101a6d:	68 00 10 00 00       	push   $0x1000
f0101a72:	56                   	push   %esi
f0101a73:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101a79:	e8 03 f6 ff ff       	call   f0101081 <page_insert>
f0101a7e:	83 c4 10             	add    $0x10,%esp
f0101a81:	85 c0                	test   %eax,%eax
f0101a83:	74 19                	je     f0101a9e <mem_init+0x9a5>
f0101a85:	68 d4 43 10 f0       	push   $0xf01043d4
f0101a8a:	68 38 3d 10 f0       	push   $0xf0103d38
f0101a8f:	68 4f 03 00 00       	push   $0x34f
f0101a94:	68 12 3d 10 f0       	push   $0xf0103d12
f0101a99:	e8 4d e6 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a9e:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101aa4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aa9:	89 f8                	mov    %edi,%eax
f0101aab:	e8 0b ef ff ff       	call   f01009bb <check_va2pa>
f0101ab0:	89 f2                	mov    %esi,%edx
f0101ab2:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101ab8:	c1 fa 03             	sar    $0x3,%edx
f0101abb:	c1 e2 0c             	shl    $0xc,%edx
f0101abe:	39 d0                	cmp    %edx,%eax
f0101ac0:	74 19                	je     f0101adb <mem_init+0x9e2>
f0101ac2:	68 64 43 10 f0       	push   $0xf0104364
f0101ac7:	68 38 3d 10 f0       	push   $0xf0103d38
f0101acc:	68 50 03 00 00       	push   $0x350
f0101ad1:	68 12 3d 10 f0       	push   $0xf0103d12
f0101ad6:	e8 10 e6 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f0101adb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ae0:	74 19                	je     f0101afb <mem_init+0xa02>
f0101ae2:	68 1d 3f 10 f0       	push   $0xf0103f1d
f0101ae7:	68 38 3d 10 f0       	push   $0xf0103d38
f0101aec:	68 51 03 00 00       	push   $0x351
f0101af1:	68 12 3d 10 f0       	push   $0xf0103d12
f0101af6:	e8 f0 e5 ff ff       	call   f01000eb <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101afb:	83 ec 04             	sub    $0x4,%esp
f0101afe:	6a 00                	push   $0x0
f0101b00:	68 00 10 00 00       	push   $0x1000
f0101b05:	57                   	push   %edi
f0101b06:	e8 5e f3 ff ff       	call   f0100e69 <pgdir_walk>
f0101b0b:	83 c4 10             	add    $0x10,%esp
f0101b0e:	f6 00 04             	testb  $0x4,(%eax)
f0101b11:	75 19                	jne    f0101b2c <mem_init+0xa33>
f0101b13:	68 14 44 10 f0       	push   $0xf0104414
f0101b18:	68 38 3d 10 f0       	push   $0xf0103d38
f0101b1d:	68 52 03 00 00       	push   $0x352
f0101b22:	68 12 3d 10 f0       	push   $0xf0103d12
f0101b27:	e8 bf e5 ff ff       	call   f01000eb <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b2c:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0101b31:	f6 00 04             	testb  $0x4,(%eax)
f0101b34:	75 19                	jne    f0101b4f <mem_init+0xa56>
f0101b36:	68 2e 3f 10 f0       	push   $0xf0103f2e
f0101b3b:	68 38 3d 10 f0       	push   $0xf0103d38
f0101b40:	68 53 03 00 00       	push   $0x353
f0101b45:	68 12 3d 10 f0       	push   $0xf0103d12
f0101b4a:	e8 9c e5 ff ff       	call   f01000eb <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b4f:	6a 02                	push   $0x2
f0101b51:	68 00 10 00 00       	push   $0x1000
f0101b56:	56                   	push   %esi
f0101b57:	50                   	push   %eax
f0101b58:	e8 24 f5 ff ff       	call   f0101081 <page_insert>
f0101b5d:	83 c4 10             	add    $0x10,%esp
f0101b60:	85 c0                	test   %eax,%eax
f0101b62:	74 19                	je     f0101b7d <mem_init+0xa84>
f0101b64:	68 28 43 10 f0       	push   $0xf0104328
f0101b69:	68 38 3d 10 f0       	push   $0xf0103d38
f0101b6e:	68 56 03 00 00       	push   $0x356
f0101b73:	68 12 3d 10 f0       	push   $0xf0103d12
f0101b78:	e8 6e e5 ff ff       	call   f01000eb <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b7d:	83 ec 04             	sub    $0x4,%esp
f0101b80:	6a 00                	push   $0x0
f0101b82:	68 00 10 00 00       	push   $0x1000
f0101b87:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101b8d:	e8 d7 f2 ff ff       	call   f0100e69 <pgdir_walk>
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	f6 00 02             	testb  $0x2,(%eax)
f0101b98:	75 19                	jne    f0101bb3 <mem_init+0xaba>
f0101b9a:	68 48 44 10 f0       	push   $0xf0104448
f0101b9f:	68 38 3d 10 f0       	push   $0xf0103d38
f0101ba4:	68 57 03 00 00       	push   $0x357
f0101ba9:	68 12 3d 10 f0       	push   $0xf0103d12
f0101bae:	e8 38 e5 ff ff       	call   f01000eb <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bb3:	83 ec 04             	sub    $0x4,%esp
f0101bb6:	6a 00                	push   $0x0
f0101bb8:	68 00 10 00 00       	push   $0x1000
f0101bbd:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101bc3:	e8 a1 f2 ff ff       	call   f0100e69 <pgdir_walk>
f0101bc8:	83 c4 10             	add    $0x10,%esp
f0101bcb:	f6 00 04             	testb  $0x4,(%eax)
f0101bce:	74 19                	je     f0101be9 <mem_init+0xaf0>
f0101bd0:	68 7c 44 10 f0       	push   $0xf010447c
f0101bd5:	68 38 3d 10 f0       	push   $0xf0103d38
f0101bda:	68 58 03 00 00       	push   $0x358
f0101bdf:	68 12 3d 10 f0       	push   $0xf0103d12
f0101be4:	e8 02 e5 ff ff       	call   f01000eb <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101be9:	6a 02                	push   $0x2
f0101beb:	68 00 00 40 00       	push   $0x400000
f0101bf0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bf3:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101bf9:	e8 83 f4 ff ff       	call   f0101081 <page_insert>
f0101bfe:	83 c4 10             	add    $0x10,%esp
f0101c01:	85 c0                	test   %eax,%eax
f0101c03:	78 19                	js     f0101c1e <mem_init+0xb25>
f0101c05:	68 b4 44 10 f0       	push   $0xf01044b4
f0101c0a:	68 38 3d 10 f0       	push   $0xf0103d38
f0101c0f:	68 5b 03 00 00       	push   $0x35b
f0101c14:	68 12 3d 10 f0       	push   $0xf0103d12
f0101c19:	e8 cd e4 ff ff       	call   f01000eb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c1e:	6a 02                	push   $0x2
f0101c20:	68 00 10 00 00       	push   $0x1000
f0101c25:	53                   	push   %ebx
f0101c26:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101c2c:	e8 50 f4 ff ff       	call   f0101081 <page_insert>
f0101c31:	83 c4 10             	add    $0x10,%esp
f0101c34:	85 c0                	test   %eax,%eax
f0101c36:	74 19                	je     f0101c51 <mem_init+0xb58>
f0101c38:	68 ec 44 10 f0       	push   $0xf01044ec
f0101c3d:	68 38 3d 10 f0       	push   $0xf0103d38
f0101c42:	68 5e 03 00 00       	push   $0x35e
f0101c47:	68 12 3d 10 f0       	push   $0xf0103d12
f0101c4c:	e8 9a e4 ff ff       	call   f01000eb <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c51:	83 ec 04             	sub    $0x4,%esp
f0101c54:	6a 00                	push   $0x0
f0101c56:	68 00 10 00 00       	push   $0x1000
f0101c5b:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101c61:	e8 03 f2 ff ff       	call   f0100e69 <pgdir_walk>
f0101c66:	83 c4 10             	add    $0x10,%esp
f0101c69:	f6 00 04             	testb  $0x4,(%eax)
f0101c6c:	74 19                	je     f0101c87 <mem_init+0xb8e>
f0101c6e:	68 7c 44 10 f0       	push   $0xf010447c
f0101c73:	68 38 3d 10 f0       	push   $0xf0103d38
f0101c78:	68 5f 03 00 00       	push   $0x35f
f0101c7d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101c82:	e8 64 e4 ff ff       	call   f01000eb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c87:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101c8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c92:	89 f8                	mov    %edi,%eax
f0101c94:	e8 22 ed ff ff       	call   f01009bb <check_va2pa>
f0101c99:	89 c1                	mov    %eax,%ecx
f0101c9b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c9e:	89 d8                	mov    %ebx,%eax
f0101ca0:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101ca6:	c1 f8 03             	sar    $0x3,%eax
f0101ca9:	c1 e0 0c             	shl    $0xc,%eax
f0101cac:	39 c1                	cmp    %eax,%ecx
f0101cae:	74 19                	je     f0101cc9 <mem_init+0xbd0>
f0101cb0:	68 28 45 10 f0       	push   $0xf0104528
f0101cb5:	68 38 3d 10 f0       	push   $0xf0103d38
f0101cba:	68 62 03 00 00       	push   $0x362
f0101cbf:	68 12 3d 10 f0       	push   $0xf0103d12
f0101cc4:	e8 22 e4 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cc9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cce:	89 f8                	mov    %edi,%eax
f0101cd0:	e8 e6 ec ff ff       	call   f01009bb <check_va2pa>
f0101cd5:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101cd8:	74 19                	je     f0101cf3 <mem_init+0xbfa>
f0101cda:	68 54 45 10 f0       	push   $0xf0104554
f0101cdf:	68 38 3d 10 f0       	push   $0xf0103d38
f0101ce4:	68 63 03 00 00       	push   $0x363
f0101ce9:	68 12 3d 10 f0       	push   $0xf0103d12
f0101cee:	e8 f8 e3 ff ff       	call   f01000eb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cf3:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cf8:	74 19                	je     f0101d13 <mem_init+0xc1a>
f0101cfa:	68 44 3f 10 f0       	push   $0xf0103f44
f0101cff:	68 38 3d 10 f0       	push   $0xf0103d38
f0101d04:	68 65 03 00 00       	push   $0x365
f0101d09:	68 12 3d 10 f0       	push   $0xf0103d12
f0101d0e:	e8 d8 e3 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101d13:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d18:	74 19                	je     f0101d33 <mem_init+0xc3a>
f0101d1a:	68 55 3f 10 f0       	push   $0xf0103f55
f0101d1f:	68 38 3d 10 f0       	push   $0xf0103d38
f0101d24:	68 66 03 00 00       	push   $0x366
f0101d29:	68 12 3d 10 f0       	push   $0xf0103d12
f0101d2e:	e8 b8 e3 ff ff       	call   f01000eb <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d33:	83 ec 0c             	sub    $0xc,%esp
f0101d36:	6a 00                	push   $0x0
f0101d38:	e8 17 f0 ff ff       	call   f0100d54 <page_alloc>
f0101d3d:	83 c4 10             	add    $0x10,%esp
f0101d40:	85 c0                	test   %eax,%eax
f0101d42:	74 04                	je     f0101d48 <mem_init+0xc4f>
f0101d44:	39 c6                	cmp    %eax,%esi
f0101d46:	74 19                	je     f0101d61 <mem_init+0xc68>
f0101d48:	68 84 45 10 f0       	push   $0xf0104584
f0101d4d:	68 38 3d 10 f0       	push   $0xf0103d38
f0101d52:	68 69 03 00 00       	push   $0x369
f0101d57:	68 12 3d 10 f0       	push   $0xf0103d12
f0101d5c:	e8 8a e3 ff ff       	call   f01000eb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d61:	83 ec 08             	sub    $0x8,%esp
f0101d64:	6a 00                	push   $0x0
f0101d66:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101d6c:	e8 d5 f2 ff ff       	call   f0101046 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d71:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101d77:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d7c:	89 f8                	mov    %edi,%eax
f0101d7e:	e8 38 ec ff ff       	call   f01009bb <check_va2pa>
f0101d83:	83 c4 10             	add    $0x10,%esp
f0101d86:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d89:	74 19                	je     f0101da4 <mem_init+0xcab>
f0101d8b:	68 a8 45 10 f0       	push   $0xf01045a8
f0101d90:	68 38 3d 10 f0       	push   $0xf0103d38
f0101d95:	68 6d 03 00 00       	push   $0x36d
f0101d9a:	68 12 3d 10 f0       	push   $0xf0103d12
f0101d9f:	e8 47 e3 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101da4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da9:	89 f8                	mov    %edi,%eax
f0101dab:	e8 0b ec ff ff       	call   f01009bb <check_va2pa>
f0101db0:	89 da                	mov    %ebx,%edx
f0101db2:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f0101db8:	c1 fa 03             	sar    $0x3,%edx
f0101dbb:	c1 e2 0c             	shl    $0xc,%edx
f0101dbe:	39 d0                	cmp    %edx,%eax
f0101dc0:	74 19                	je     f0101ddb <mem_init+0xce2>
f0101dc2:	68 54 45 10 f0       	push   $0xf0104554
f0101dc7:	68 38 3d 10 f0       	push   $0xf0103d38
f0101dcc:	68 6e 03 00 00       	push   $0x36e
f0101dd1:	68 12 3d 10 f0       	push   $0xf0103d12
f0101dd6:	e8 10 e3 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 1);
f0101ddb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101de0:	74 19                	je     f0101dfb <mem_init+0xd02>
f0101de2:	68 fb 3e 10 f0       	push   $0xf0103efb
f0101de7:	68 38 3d 10 f0       	push   $0xf0103d38
f0101dec:	68 6f 03 00 00       	push   $0x36f
f0101df1:	68 12 3d 10 f0       	push   $0xf0103d12
f0101df6:	e8 f0 e2 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101dfb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e00:	74 19                	je     f0101e1b <mem_init+0xd22>
f0101e02:	68 55 3f 10 f0       	push   $0xf0103f55
f0101e07:	68 38 3d 10 f0       	push   $0xf0103d38
f0101e0c:	68 70 03 00 00       	push   $0x370
f0101e11:	68 12 3d 10 f0       	push   $0xf0103d12
f0101e16:	e8 d0 e2 ff ff       	call   f01000eb <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e1b:	6a 00                	push   $0x0
f0101e1d:	68 00 10 00 00       	push   $0x1000
f0101e22:	53                   	push   %ebx
f0101e23:	57                   	push   %edi
f0101e24:	e8 58 f2 ff ff       	call   f0101081 <page_insert>
f0101e29:	83 c4 10             	add    $0x10,%esp
f0101e2c:	85 c0                	test   %eax,%eax
f0101e2e:	74 19                	je     f0101e49 <mem_init+0xd50>
f0101e30:	68 cc 45 10 f0       	push   $0xf01045cc
f0101e35:	68 38 3d 10 f0       	push   $0xf0103d38
f0101e3a:	68 73 03 00 00       	push   $0x373
f0101e3f:	68 12 3d 10 f0       	push   $0xf0103d12
f0101e44:	e8 a2 e2 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref);
f0101e49:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e4e:	75 19                	jne    f0101e69 <mem_init+0xd70>
f0101e50:	68 66 3f 10 f0       	push   $0xf0103f66
f0101e55:	68 38 3d 10 f0       	push   $0xf0103d38
f0101e5a:	68 74 03 00 00       	push   $0x374
f0101e5f:	68 12 3d 10 f0       	push   $0xf0103d12
f0101e64:	e8 82 e2 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_link == NULL);
f0101e69:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e6c:	74 19                	je     f0101e87 <mem_init+0xd8e>
f0101e6e:	68 72 3f 10 f0       	push   $0xf0103f72
f0101e73:	68 38 3d 10 f0       	push   $0xf0103d38
f0101e78:	68 75 03 00 00       	push   $0x375
f0101e7d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101e82:	e8 64 e2 ff ff       	call   f01000eb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e87:	83 ec 08             	sub    $0x8,%esp
f0101e8a:	68 00 10 00 00       	push   $0x1000
f0101e8f:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0101e95:	e8 ac f1 ff ff       	call   f0101046 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e9a:	8b 3d 48 79 11 f0    	mov    0xf0117948,%edi
f0101ea0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea5:	89 f8                	mov    %edi,%eax
f0101ea7:	e8 0f eb ff ff       	call   f01009bb <check_va2pa>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb2:	74 19                	je     f0101ecd <mem_init+0xdd4>
f0101eb4:	68 a8 45 10 f0       	push   $0xf01045a8
f0101eb9:	68 38 3d 10 f0       	push   $0xf0103d38
f0101ebe:	68 79 03 00 00       	push   $0x379
f0101ec3:	68 12 3d 10 f0       	push   $0xf0103d12
f0101ec8:	e8 1e e2 ff ff       	call   f01000eb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ecd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed2:	89 f8                	mov    %edi,%eax
f0101ed4:	e8 e2 ea ff ff       	call   f01009bb <check_va2pa>
f0101ed9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101edc:	74 19                	je     f0101ef7 <mem_init+0xdfe>
f0101ede:	68 04 46 10 f0       	push   $0xf0104604
f0101ee3:	68 38 3d 10 f0       	push   $0xf0103d38
f0101ee8:	68 7a 03 00 00       	push   $0x37a
f0101eed:	68 12 3d 10 f0       	push   $0xf0103d12
f0101ef2:	e8 f4 e1 ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 0);
f0101ef7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101efc:	74 19                	je     f0101f17 <mem_init+0xe1e>
f0101efe:	68 87 3f 10 f0       	push   $0xf0103f87
f0101f03:	68 38 3d 10 f0       	push   $0xf0103d38
f0101f08:	68 7b 03 00 00       	push   $0x37b
f0101f0d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101f12:	e8 d4 e1 ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 0);
f0101f17:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f1c:	74 19                	je     f0101f37 <mem_init+0xe3e>
f0101f1e:	68 55 3f 10 f0       	push   $0xf0103f55
f0101f23:	68 38 3d 10 f0       	push   $0xf0103d38
f0101f28:	68 7c 03 00 00       	push   $0x37c
f0101f2d:	68 12 3d 10 f0       	push   $0xf0103d12
f0101f32:	e8 b4 e1 ff ff       	call   f01000eb <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f37:	83 ec 0c             	sub    $0xc,%esp
f0101f3a:	6a 00                	push   $0x0
f0101f3c:	e8 13 ee ff ff       	call   f0100d54 <page_alloc>
f0101f41:	83 c4 10             	add    $0x10,%esp
f0101f44:	39 c3                	cmp    %eax,%ebx
f0101f46:	75 04                	jne    f0101f4c <mem_init+0xe53>
f0101f48:	85 c0                	test   %eax,%eax
f0101f4a:	75 19                	jne    f0101f65 <mem_init+0xe6c>
f0101f4c:	68 2c 46 10 f0       	push   $0xf010462c
f0101f51:	68 38 3d 10 f0       	push   $0xf0103d38
f0101f56:	68 7f 03 00 00       	push   $0x37f
f0101f5b:	68 12 3d 10 f0       	push   $0xf0103d12
f0101f60:	e8 86 e1 ff ff       	call   f01000eb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f65:	83 ec 0c             	sub    $0xc,%esp
f0101f68:	6a 00                	push   $0x0
f0101f6a:	e8 e5 ed ff ff       	call   f0100d54 <page_alloc>
f0101f6f:	83 c4 10             	add    $0x10,%esp
f0101f72:	85 c0                	test   %eax,%eax
f0101f74:	74 19                	je     f0101f8f <mem_init+0xe96>
f0101f76:	68 a9 3e 10 f0       	push   $0xf0103ea9
f0101f7b:	68 38 3d 10 f0       	push   $0xf0103d38
f0101f80:	68 82 03 00 00       	push   $0x382
f0101f85:	68 12 3d 10 f0       	push   $0xf0103d12
f0101f8a:	e8 5c e1 ff ff       	call   f01000eb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f8f:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f0101f95:	8b 11                	mov    (%ecx),%edx
f0101f97:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f9d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa0:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0101fa6:	c1 f8 03             	sar    $0x3,%eax
f0101fa9:	c1 e0 0c             	shl    $0xc,%eax
f0101fac:	39 c2                	cmp    %eax,%edx
f0101fae:	74 19                	je     f0101fc9 <mem_init+0xed0>
f0101fb0:	68 d0 42 10 f0       	push   $0xf01042d0
f0101fb5:	68 38 3d 10 f0       	push   $0xf0103d38
f0101fba:	68 85 03 00 00       	push   $0x385
f0101fbf:	68 12 3d 10 f0       	push   $0xf0103d12
f0101fc4:	e8 22 e1 ff ff       	call   f01000eb <_panic>
	kern_pgdir[0] = 0;
f0101fc9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fd7:	74 19                	je     f0101ff2 <mem_init+0xef9>
f0101fd9:	68 0c 3f 10 f0       	push   $0xf0103f0c
f0101fde:	68 38 3d 10 f0       	push   $0xf0103d38
f0101fe3:	68 87 03 00 00       	push   $0x387
f0101fe8:	68 12 3d 10 f0       	push   $0xf0103d12
f0101fed:	e8 f9 e0 ff ff       	call   f01000eb <_panic>
	pp0->pp_ref = 0;
f0101ff2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ffb:	83 ec 0c             	sub    $0xc,%esp
f0101ffe:	50                   	push   %eax
f0101fff:	e8 c0 ed ff ff       	call   f0100dc4 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102004:	83 c4 0c             	add    $0xc,%esp
f0102007:	6a 01                	push   $0x1
f0102009:	68 00 10 40 00       	push   $0x401000
f010200e:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0102014:	e8 50 ee ff ff       	call   f0100e69 <pgdir_walk>
f0102019:	89 c7                	mov    %eax,%edi
f010201b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010201e:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0102023:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102026:	8b 40 04             	mov    0x4(%eax),%eax
f0102029:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010202e:	8b 0d 44 79 11 f0    	mov    0xf0117944,%ecx
f0102034:	89 c2                	mov    %eax,%edx
f0102036:	c1 ea 0c             	shr    $0xc,%edx
f0102039:	83 c4 10             	add    $0x10,%esp
f010203c:	39 ca                	cmp    %ecx,%edx
f010203e:	72 15                	jb     f0102055 <mem_init+0xf5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102040:	50                   	push   %eax
f0102041:	68 10 40 10 f0       	push   $0xf0104010
f0102046:	68 8e 03 00 00       	push   $0x38e
f010204b:	68 12 3d 10 f0       	push   $0xf0103d12
f0102050:	e8 96 e0 ff ff       	call   f01000eb <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102055:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010205a:	39 c7                	cmp    %eax,%edi
f010205c:	74 19                	je     f0102077 <mem_init+0xf7e>
f010205e:	68 98 3f 10 f0       	push   $0xf0103f98
f0102063:	68 38 3d 10 f0       	push   $0xf0103d38
f0102068:	68 8f 03 00 00       	push   $0x38f
f010206d:	68 12 3d 10 f0       	push   $0xf0103d12
f0102072:	e8 74 e0 ff ff       	call   f01000eb <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102077:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010207a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102081:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102084:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010208a:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0102090:	c1 f8 03             	sar    $0x3,%eax
f0102093:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102096:	89 c2                	mov    %eax,%edx
f0102098:	c1 ea 0c             	shr    $0xc,%edx
f010209b:	39 d1                	cmp    %edx,%ecx
f010209d:	77 12                	ja     f01020b1 <mem_init+0xfb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010209f:	50                   	push   %eax
f01020a0:	68 10 40 10 f0       	push   $0xf0104010
f01020a5:	6a 52                	push   $0x52
f01020a7:	68 1e 3d 10 f0       	push   $0xf0103d1e
f01020ac:	e8 3a e0 ff ff       	call   f01000eb <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020b1:	83 ec 04             	sub    $0x4,%esp
f01020b4:	68 00 10 00 00       	push   $0x1000
f01020b9:	68 ff 00 00 00       	push   $0xff
f01020be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020c3:	50                   	push   %eax
f01020c4:	e8 5e 12 00 00       	call   f0103327 <memset>
	page_free(pp0);
f01020c9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020cc:	89 3c 24             	mov    %edi,(%esp)
f01020cf:	e8 f0 ec ff ff       	call   f0100dc4 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020d4:	83 c4 0c             	add    $0xc,%esp
f01020d7:	6a 01                	push   $0x1
f01020d9:	6a 00                	push   $0x0
f01020db:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01020e1:	e8 83 ed ff ff       	call   f0100e69 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020e6:	89 fa                	mov    %edi,%edx
f01020e8:	2b 15 4c 79 11 f0    	sub    0xf011794c,%edx
f01020ee:	c1 fa 03             	sar    $0x3,%edx
f01020f1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020f4:	89 d0                	mov    %edx,%eax
f01020f6:	c1 e8 0c             	shr    $0xc,%eax
f01020f9:	83 c4 10             	add    $0x10,%esp
f01020fc:	3b 05 44 79 11 f0    	cmp    0xf0117944,%eax
f0102102:	72 12                	jb     f0102116 <mem_init+0x101d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102104:	52                   	push   %edx
f0102105:	68 10 40 10 f0       	push   $0xf0104010
f010210a:	6a 52                	push   $0x52
f010210c:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102111:	e8 d5 df ff ff       	call   f01000eb <_panic>
	return (void *)(pa + KERNBASE);
f0102116:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010211c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010211f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102125:	f6 00 01             	testb  $0x1,(%eax)
f0102128:	74 19                	je     f0102143 <mem_init+0x104a>
f010212a:	68 b0 3f 10 f0       	push   $0xf0103fb0
f010212f:	68 38 3d 10 f0       	push   $0xf0103d38
f0102134:	68 99 03 00 00       	push   $0x399
f0102139:	68 12 3d 10 f0       	push   $0xf0103d12
f010213e:	e8 a8 df ff ff       	call   f01000eb <_panic>
f0102143:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102146:	39 d0                	cmp    %edx,%eax
f0102148:	75 db                	jne    f0102125 <mem_init+0x102c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010214a:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f010214f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102155:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102158:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010215e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102161:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f0102167:	83 ec 0c             	sub    $0xc,%esp
f010216a:	50                   	push   %eax
f010216b:	e8 54 ec ff ff       	call   f0100dc4 <page_free>
	page_free(pp1);
f0102170:	89 1c 24             	mov    %ebx,(%esp)
f0102173:	e8 4c ec ff ff       	call   f0100dc4 <page_free>
	page_free(pp2);
f0102178:	89 34 24             	mov    %esi,(%esp)
f010217b:	e8 44 ec ff ff       	call   f0100dc4 <page_free>
	cprintf("check_page() succeeded!\n");
f0102180:	c7 04 24 c7 3f 10 f0 	movl   $0xf0103fc7,(%esp)
f0102187:	e8 4b 06 00 00       	call   f01027d7 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U);
f010218c:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102191:	83 c4 10             	add    $0x10,%esp
f0102194:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102199:	77 15                	ja     f01021b0 <mem_init+0x10b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010219b:	50                   	push   %eax
f010219c:	68 f8 40 10 f0       	push   $0xf01040f8
f01021a1:	68 c5 00 00 00       	push   $0xc5
f01021a6:	68 12 3d 10 f0       	push   $0xf0103d12
f01021ab:	e8 3b df ff ff       	call   f01000eb <_panic>
f01021b0:	83 ec 08             	sub    $0x8,%esp
f01021b3:	6a 04                	push   $0x4
f01021b5:	05 00 00 00 10       	add    $0x10000000,%eax
f01021ba:	50                   	push   %eax
f01021bb:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01021c0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021c5:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f01021ca:	e8 c0 ed ff ff       	call   f0100f8f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021cf:	83 c4 10             	add    $0x10,%esp
f01021d2:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f01021d7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021dc:	77 15                	ja     f01021f3 <mem_init+0x10fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021de:	50                   	push   %eax
f01021df:	68 f8 40 10 f0       	push   $0xf01040f8
f01021e4:	68 d3 00 00 00       	push   $0xd3
f01021e9:	68 12 3d 10 f0       	push   $0xf0103d12
f01021ee:	e8 f8 de ff ff       	call   f01000eb <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f01021f3:	83 ec 08             	sub    $0x8,%esp
f01021f6:	6a 02                	push   $0x2
f01021f8:	68 00 d0 10 00       	push   $0x10d000
f01021fd:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102202:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102207:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f010220c:	e8 7e ed ff ff       	call   f0100f8f <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W);
f0102211:	83 c4 08             	add    $0x8,%esp
f0102214:	6a 02                	push   $0x2
f0102216:	6a 00                	push   $0x0
f0102218:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010221d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102222:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0102227:	e8 63 ed ff ff       	call   f0100f8f <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010222c:	8b 35 48 79 11 f0    	mov    0xf0117948,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102232:	a1 44 79 11 f0       	mov    0xf0117944,%eax
f0102237:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010223a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102241:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102246:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102249:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010224f:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102252:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102255:	bb 00 00 00 00       	mov    $0x0,%ebx
f010225a:	eb 55                	jmp    f01022b1 <mem_init+0x11b8>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010225c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102262:	89 f0                	mov    %esi,%eax
f0102264:	e8 52 e7 ff ff       	call   f01009bb <check_va2pa>
f0102269:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102270:	77 15                	ja     f0102287 <mem_init+0x118e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102272:	57                   	push   %edi
f0102273:	68 f8 40 10 f0       	push   $0xf01040f8
f0102278:	68 db 02 00 00       	push   $0x2db
f010227d:	68 12 3d 10 f0       	push   $0xf0103d12
f0102282:	e8 64 de ff ff       	call   f01000eb <_panic>
f0102287:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f010228e:	39 c2                	cmp    %eax,%edx
f0102290:	74 19                	je     f01022ab <mem_init+0x11b2>
f0102292:	68 50 46 10 f0       	push   $0xf0104650
f0102297:	68 38 3d 10 f0       	push   $0xf0103d38
f010229c:	68 db 02 00 00       	push   $0x2db
f01022a1:	68 12 3d 10 f0       	push   $0xf0103d12
f01022a6:	e8 40 de ff ff       	call   f01000eb <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022b1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01022b4:	77 a6                	ja     f010225c <mem_init+0x1163>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022b6:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01022b9:	c1 e7 0c             	shl    $0xc,%edi
f01022bc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022c1:	eb 30                	jmp    f01022f3 <mem_init+0x11fa>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01022c3:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01022c9:	89 f0                	mov    %esi,%eax
f01022cb:	e8 eb e6 ff ff       	call   f01009bb <check_va2pa>
f01022d0:	39 c3                	cmp    %eax,%ebx
f01022d2:	74 19                	je     f01022ed <mem_init+0x11f4>
f01022d4:	68 84 46 10 f0       	push   $0xf0104684
f01022d9:	68 38 3d 10 f0       	push   $0xf0103d38
f01022de:	68 e0 02 00 00       	push   $0x2e0
f01022e3:	68 12 3d 10 f0       	push   $0xf0103d12
f01022e8:	e8 fe dd ff ff       	call   f01000eb <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022f3:	39 fb                	cmp    %edi,%ebx
f01022f5:	72 cc                	jb     f01022c3 <mem_init+0x11ca>
f01022f7:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022fc:	89 da                	mov    %ebx,%edx
f01022fe:	89 f0                	mov    %esi,%eax
f0102300:	e8 b6 e6 ff ff       	call   f01009bb <check_va2pa>
f0102305:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f010230b:	39 c2                	cmp    %eax,%edx
f010230d:	74 19                	je     f0102328 <mem_init+0x122f>
f010230f:	68 ac 46 10 f0       	push   $0xf01046ac
f0102314:	68 38 3d 10 f0       	push   $0xf0103d38
f0102319:	68 e4 02 00 00       	push   $0x2e4
f010231e:	68 12 3d 10 f0       	push   $0xf0103d12
f0102323:	e8 c3 dd ff ff       	call   f01000eb <_panic>
f0102328:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010232e:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102334:	75 c6                	jne    f01022fc <mem_init+0x1203>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102336:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010233b:	89 f0                	mov    %esi,%eax
f010233d:	e8 79 e6 ff ff       	call   f01009bb <check_va2pa>
f0102342:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102345:	74 51                	je     f0102398 <mem_init+0x129f>
f0102347:	68 f4 46 10 f0       	push   $0xf01046f4
f010234c:	68 38 3d 10 f0       	push   $0xf0103d38
f0102351:	68 e5 02 00 00       	push   $0x2e5
f0102356:	68 12 3d 10 f0       	push   $0xf0103d12
f010235b:	e8 8b dd ff ff       	call   f01000eb <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102360:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102365:	72 36                	jb     f010239d <mem_init+0x12a4>
f0102367:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010236c:	76 07                	jbe    f0102375 <mem_init+0x127c>
f010236e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102373:	75 28                	jne    f010239d <mem_init+0x12a4>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102375:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102379:	0f 85 83 00 00 00    	jne    f0102402 <mem_init+0x1309>
f010237f:	68 e0 3f 10 f0       	push   $0xf0103fe0
f0102384:	68 38 3d 10 f0       	push   $0xf0103d38
f0102389:	68 ed 02 00 00       	push   $0x2ed
f010238e:	68 12 3d 10 f0       	push   $0xf0103d12
f0102393:	e8 53 dd ff ff       	call   f01000eb <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102398:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010239d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023a2:	76 3f                	jbe    f01023e3 <mem_init+0x12ea>
				assert(pgdir[i] & PTE_P);
f01023a4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01023a7:	f6 c2 01             	test   $0x1,%dl
f01023aa:	75 19                	jne    f01023c5 <mem_init+0x12cc>
f01023ac:	68 e0 3f 10 f0       	push   $0xf0103fe0
f01023b1:	68 38 3d 10 f0       	push   $0xf0103d38
f01023b6:	68 f1 02 00 00       	push   $0x2f1
f01023bb:	68 12 3d 10 f0       	push   $0xf0103d12
f01023c0:	e8 26 dd ff ff       	call   f01000eb <_panic>
				assert(pgdir[i] & PTE_W);
f01023c5:	f6 c2 02             	test   $0x2,%dl
f01023c8:	75 38                	jne    f0102402 <mem_init+0x1309>
f01023ca:	68 f1 3f 10 f0       	push   $0xf0103ff1
f01023cf:	68 38 3d 10 f0       	push   $0xf0103d38
f01023d4:	68 f2 02 00 00       	push   $0x2f2
f01023d9:	68 12 3d 10 f0       	push   $0xf0103d12
f01023de:	e8 08 dd ff ff       	call   f01000eb <_panic>
			} else
				assert(pgdir[i] == 0);
f01023e3:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01023e7:	74 19                	je     f0102402 <mem_init+0x1309>
f01023e9:	68 02 40 10 f0       	push   $0xf0104002
f01023ee:	68 38 3d 10 f0       	push   $0xf0103d38
f01023f3:	68 f4 02 00 00       	push   $0x2f4
f01023f8:	68 12 3d 10 f0       	push   $0xf0103d12
f01023fd:	e8 e9 dc ff ff       	call   f01000eb <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102402:	83 c0 01             	add    $0x1,%eax
f0102405:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010240a:	0f 86 50 ff ff ff    	jbe    f0102360 <mem_init+0x1267>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102410:	83 ec 0c             	sub    $0xc,%esp
f0102413:	68 24 47 10 f0       	push   $0xf0104724
f0102418:	e8 ba 03 00 00       	call   f01027d7 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010241d:	a1 48 79 11 f0       	mov    0xf0117948,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102422:	83 c4 10             	add    $0x10,%esp
f0102425:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010242a:	77 15                	ja     f0102441 <mem_init+0x1348>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010242c:	50                   	push   %eax
f010242d:	68 f8 40 10 f0       	push   $0xf01040f8
f0102432:	68 ea 00 00 00       	push   $0xea
f0102437:	68 12 3d 10 f0       	push   $0xf0103d12
f010243c:	e8 aa dc ff ff       	call   f01000eb <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102441:	05 00 00 00 10       	add    $0x10000000,%eax
f0102446:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102449:	b8 00 00 00 00       	mov    $0x0,%eax
f010244e:	e8 cc e5 ff ff       	call   f0100a1f <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102453:	0f 20 c0             	mov    %cr0,%eax
f0102456:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102459:	0d 23 00 05 80       	or     $0x80050023,%eax
f010245e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102461:	83 ec 0c             	sub    $0xc,%esp
f0102464:	6a 00                	push   $0x0
f0102466:	e8 e9 e8 ff ff       	call   f0100d54 <page_alloc>
f010246b:	89 c3                	mov    %eax,%ebx
f010246d:	83 c4 10             	add    $0x10,%esp
f0102470:	85 c0                	test   %eax,%eax
f0102472:	75 19                	jne    f010248d <mem_init+0x1394>
f0102474:	68 fe 3d 10 f0       	push   $0xf0103dfe
f0102479:	68 38 3d 10 f0       	push   $0xf0103d38
f010247e:	68 b3 03 00 00       	push   $0x3b3
f0102483:	68 12 3d 10 f0       	push   $0xf0103d12
f0102488:	e8 5e dc ff ff       	call   f01000eb <_panic>
	assert((pp1 = page_alloc(0)));
f010248d:	83 ec 0c             	sub    $0xc,%esp
f0102490:	6a 00                	push   $0x0
f0102492:	e8 bd e8 ff ff       	call   f0100d54 <page_alloc>
f0102497:	89 c7                	mov    %eax,%edi
f0102499:	83 c4 10             	add    $0x10,%esp
f010249c:	85 c0                	test   %eax,%eax
f010249e:	75 19                	jne    f01024b9 <mem_init+0x13c0>
f01024a0:	68 14 3e 10 f0       	push   $0xf0103e14
f01024a5:	68 38 3d 10 f0       	push   $0xf0103d38
f01024aa:	68 b4 03 00 00       	push   $0x3b4
f01024af:	68 12 3d 10 f0       	push   $0xf0103d12
f01024b4:	e8 32 dc ff ff       	call   f01000eb <_panic>
	assert((pp2 = page_alloc(0)));
f01024b9:	83 ec 0c             	sub    $0xc,%esp
f01024bc:	6a 00                	push   $0x0
f01024be:	e8 91 e8 ff ff       	call   f0100d54 <page_alloc>
f01024c3:	89 c6                	mov    %eax,%esi
f01024c5:	83 c4 10             	add    $0x10,%esp
f01024c8:	85 c0                	test   %eax,%eax
f01024ca:	75 19                	jne    f01024e5 <mem_init+0x13ec>
f01024cc:	68 2a 3e 10 f0       	push   $0xf0103e2a
f01024d1:	68 38 3d 10 f0       	push   $0xf0103d38
f01024d6:	68 b5 03 00 00       	push   $0x3b5
f01024db:	68 12 3d 10 f0       	push   $0xf0103d12
f01024e0:	e8 06 dc ff ff       	call   f01000eb <_panic>
	page_free(pp0);
f01024e5:	83 ec 0c             	sub    $0xc,%esp
f01024e8:	53                   	push   %ebx
f01024e9:	e8 d6 e8 ff ff       	call   f0100dc4 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ee:	89 f8                	mov    %edi,%eax
f01024f0:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01024f6:	c1 f8 03             	sar    $0x3,%eax
f01024f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024fc:	89 c2                	mov    %eax,%edx
f01024fe:	c1 ea 0c             	shr    $0xc,%edx
f0102501:	83 c4 10             	add    $0x10,%esp
f0102504:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f010250a:	72 12                	jb     f010251e <mem_init+0x1425>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010250c:	50                   	push   %eax
f010250d:	68 10 40 10 f0       	push   $0xf0104010
f0102512:	6a 52                	push   $0x52
f0102514:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102519:	e8 cd db ff ff       	call   f01000eb <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010251e:	83 ec 04             	sub    $0x4,%esp
f0102521:	68 00 10 00 00       	push   $0x1000
f0102526:	6a 01                	push   $0x1
f0102528:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010252d:	50                   	push   %eax
f010252e:	e8 f4 0d 00 00       	call   f0103327 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102533:	89 f0                	mov    %esi,%eax
f0102535:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f010253b:	c1 f8 03             	sar    $0x3,%eax
f010253e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102541:	89 c2                	mov    %eax,%edx
f0102543:	c1 ea 0c             	shr    $0xc,%edx
f0102546:	83 c4 10             	add    $0x10,%esp
f0102549:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f010254f:	72 12                	jb     f0102563 <mem_init+0x146a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102551:	50                   	push   %eax
f0102552:	68 10 40 10 f0       	push   $0xf0104010
f0102557:	6a 52                	push   $0x52
f0102559:	68 1e 3d 10 f0       	push   $0xf0103d1e
f010255e:	e8 88 db ff ff       	call   f01000eb <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102563:	83 ec 04             	sub    $0x4,%esp
f0102566:	68 00 10 00 00       	push   $0x1000
f010256b:	6a 02                	push   $0x2
f010256d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102572:	50                   	push   %eax
f0102573:	e8 af 0d 00 00       	call   f0103327 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102578:	6a 02                	push   $0x2
f010257a:	68 00 10 00 00       	push   $0x1000
f010257f:	57                   	push   %edi
f0102580:	ff 35 48 79 11 f0    	pushl  0xf0117948
f0102586:	e8 f6 ea ff ff       	call   f0101081 <page_insert>
	assert(pp1->pp_ref == 1);
f010258b:	83 c4 20             	add    $0x20,%esp
f010258e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102593:	74 19                	je     f01025ae <mem_init+0x14b5>
f0102595:	68 fb 3e 10 f0       	push   $0xf0103efb
f010259a:	68 38 3d 10 f0       	push   $0xf0103d38
f010259f:	68 ba 03 00 00       	push   $0x3ba
f01025a4:	68 12 3d 10 f0       	push   $0xf0103d12
f01025a9:	e8 3d db ff ff       	call   f01000eb <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025ae:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025b5:	01 01 01 
f01025b8:	74 19                	je     f01025d3 <mem_init+0x14da>
f01025ba:	68 44 47 10 f0       	push   $0xf0104744
f01025bf:	68 38 3d 10 f0       	push   $0xf0103d38
f01025c4:	68 bb 03 00 00       	push   $0x3bb
f01025c9:	68 12 3d 10 f0       	push   $0xf0103d12
f01025ce:	e8 18 db ff ff       	call   f01000eb <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01025d3:	6a 02                	push   $0x2
f01025d5:	68 00 10 00 00       	push   $0x1000
f01025da:	56                   	push   %esi
f01025db:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01025e1:	e8 9b ea ff ff       	call   f0101081 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025e6:	83 c4 10             	add    $0x10,%esp
f01025e9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025f0:	02 02 02 
f01025f3:	74 19                	je     f010260e <mem_init+0x1515>
f01025f5:	68 68 47 10 f0       	push   $0xf0104768
f01025fa:	68 38 3d 10 f0       	push   $0xf0103d38
f01025ff:	68 bd 03 00 00       	push   $0x3bd
f0102604:	68 12 3d 10 f0       	push   $0xf0103d12
f0102609:	e8 dd da ff ff       	call   f01000eb <_panic>
	assert(pp2->pp_ref == 1);
f010260e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102613:	74 19                	je     f010262e <mem_init+0x1535>
f0102615:	68 1d 3f 10 f0       	push   $0xf0103f1d
f010261a:	68 38 3d 10 f0       	push   $0xf0103d38
f010261f:	68 be 03 00 00       	push   $0x3be
f0102624:	68 12 3d 10 f0       	push   $0xf0103d12
f0102629:	e8 bd da ff ff       	call   f01000eb <_panic>
	assert(pp1->pp_ref == 0);
f010262e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102633:	74 19                	je     f010264e <mem_init+0x1555>
f0102635:	68 87 3f 10 f0       	push   $0xf0103f87
f010263a:	68 38 3d 10 f0       	push   $0xf0103d38
f010263f:	68 bf 03 00 00       	push   $0x3bf
f0102644:	68 12 3d 10 f0       	push   $0xf0103d12
f0102649:	e8 9d da ff ff       	call   f01000eb <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010264e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102655:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102658:	89 f0                	mov    %esi,%eax
f010265a:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f0102660:	c1 f8 03             	sar    $0x3,%eax
f0102663:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102666:	89 c2                	mov    %eax,%edx
f0102668:	c1 ea 0c             	shr    $0xc,%edx
f010266b:	3b 15 44 79 11 f0    	cmp    0xf0117944,%edx
f0102671:	72 12                	jb     f0102685 <mem_init+0x158c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102673:	50                   	push   %eax
f0102674:	68 10 40 10 f0       	push   $0xf0104010
f0102679:	6a 52                	push   $0x52
f010267b:	68 1e 3d 10 f0       	push   $0xf0103d1e
f0102680:	e8 66 da ff ff       	call   f01000eb <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102685:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010268c:	03 03 03 
f010268f:	74 19                	je     f01026aa <mem_init+0x15b1>
f0102691:	68 8c 47 10 f0       	push   $0xf010478c
f0102696:	68 38 3d 10 f0       	push   $0xf0103d38
f010269b:	68 c1 03 00 00       	push   $0x3c1
f01026a0:	68 12 3d 10 f0       	push   $0xf0103d12
f01026a5:	e8 41 da ff ff       	call   f01000eb <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026aa:	83 ec 08             	sub    $0x8,%esp
f01026ad:	68 00 10 00 00       	push   $0x1000
f01026b2:	ff 35 48 79 11 f0    	pushl  0xf0117948
f01026b8:	e8 89 e9 ff ff       	call   f0101046 <page_remove>
	assert(pp2->pp_ref == 0);
f01026bd:	83 c4 10             	add    $0x10,%esp
f01026c0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026c5:	74 19                	je     f01026e0 <mem_init+0x15e7>
f01026c7:	68 55 3f 10 f0       	push   $0xf0103f55
f01026cc:	68 38 3d 10 f0       	push   $0xf0103d38
f01026d1:	68 c3 03 00 00       	push   $0x3c3
f01026d6:	68 12 3d 10 f0       	push   $0xf0103d12
f01026db:	e8 0b da ff ff       	call   f01000eb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026e0:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f01026e6:	8b 11                	mov    (%ecx),%edx
f01026e8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026ee:	89 d8                	mov    %ebx,%eax
f01026f0:	2b 05 4c 79 11 f0    	sub    0xf011794c,%eax
f01026f6:	c1 f8 03             	sar    $0x3,%eax
f01026f9:	c1 e0 0c             	shl    $0xc,%eax
f01026fc:	39 c2                	cmp    %eax,%edx
f01026fe:	74 19                	je     f0102719 <mem_init+0x1620>
f0102700:	68 d0 42 10 f0       	push   $0xf01042d0
f0102705:	68 38 3d 10 f0       	push   $0xf0103d38
f010270a:	68 c6 03 00 00       	push   $0x3c6
f010270f:	68 12 3d 10 f0       	push   $0xf0103d12
f0102714:	e8 d2 d9 ff ff       	call   f01000eb <_panic>
	kern_pgdir[0] = 0;
f0102719:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010271f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102724:	74 19                	je     f010273f <mem_init+0x1646>
f0102726:	68 0c 3f 10 f0       	push   $0xf0103f0c
f010272b:	68 38 3d 10 f0       	push   $0xf0103d38
f0102730:	68 c8 03 00 00       	push   $0x3c8
f0102735:	68 12 3d 10 f0       	push   $0xf0103d12
f010273a:	e8 ac d9 ff ff       	call   f01000eb <_panic>
	pp0->pp_ref = 0;
f010273f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102745:	83 ec 0c             	sub    $0xc,%esp
f0102748:	53                   	push   %ebx
f0102749:	e8 76 e6 ff ff       	call   f0100dc4 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010274e:	c7 04 24 b8 47 10 f0 	movl   $0xf01047b8,(%esp)
f0102755:	e8 7d 00 00 00       	call   f01027d7 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010275a:	83 c4 10             	add    $0x10,%esp
f010275d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102760:	5b                   	pop    %ebx
f0102761:	5e                   	pop    %esi
f0102762:	5f                   	pop    %edi
f0102763:	5d                   	pop    %ebp
f0102764:	c3                   	ret    

f0102765 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102765:	55                   	push   %ebp
f0102766:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102768:	8b 45 0c             	mov    0xc(%ebp),%eax
f010276b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010276e:	5d                   	pop    %ebp
f010276f:	c3                   	ret    

f0102770 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102770:	55                   	push   %ebp
f0102771:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102773:	ba 70 00 00 00       	mov    $0x70,%edx
f0102778:	8b 45 08             	mov    0x8(%ebp),%eax
f010277b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010277c:	ba 71 00 00 00       	mov    $0x71,%edx
f0102781:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102782:	0f b6 c0             	movzbl %al,%eax
}
f0102785:	5d                   	pop    %ebp
f0102786:	c3                   	ret    

f0102787 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102787:	55                   	push   %ebp
f0102788:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010278a:	ba 70 00 00 00       	mov    $0x70,%edx
f010278f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102792:	ee                   	out    %al,(%dx)
f0102793:	ba 71 00 00 00       	mov    $0x71,%edx
f0102798:	8b 45 0c             	mov    0xc(%ebp),%eax
f010279b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010279c:	5d                   	pop    %ebp
f010279d:	c3                   	ret    

f010279e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010279e:	55                   	push   %ebp
f010279f:	89 e5                	mov    %esp,%ebp
f01027a1:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01027a4:	ff 75 08             	pushl  0x8(%ebp)
f01027a7:	e8 b4 de ff ff       	call   f0100660 <cputchar>
	*cnt++;
}
f01027ac:	83 c4 10             	add    $0x10,%esp
f01027af:	c9                   	leave  
f01027b0:	c3                   	ret    

f01027b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01027b1:	55                   	push   %ebp
f01027b2:	89 e5                	mov    %esp,%ebp
f01027b4:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01027b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01027be:	ff 75 0c             	pushl  0xc(%ebp)
f01027c1:	ff 75 08             	pushl  0x8(%ebp)
f01027c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01027c7:	50                   	push   %eax
f01027c8:	68 9e 27 10 f0       	push   $0xf010279e
f01027cd:	e8 08 04 00 00       	call   f0102bda <vprintfmt>
	return cnt;
}
f01027d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027d5:	c9                   	leave  
f01027d6:	c3                   	ret    

f01027d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01027d7:	55                   	push   %ebp
f01027d8:	89 e5                	mov    %esp,%ebp
f01027da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01027dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01027e0:	50                   	push   %eax
f01027e1:	ff 75 08             	pushl  0x8(%ebp)
f01027e4:	e8 c8 ff ff ff       	call   f01027b1 <vcprintf>
	va_end(ap);

	return cnt;
}
f01027e9:	c9                   	leave  
f01027ea:	c3                   	ret    

f01027eb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01027eb:	55                   	push   %ebp
f01027ec:	89 e5                	mov    %esp,%ebp
f01027ee:	57                   	push   %edi
f01027ef:	56                   	push   %esi
f01027f0:	53                   	push   %ebx
f01027f1:	83 ec 14             	sub    $0x14,%esp
f01027f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01027f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01027fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01027fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102800:	8b 1a                	mov    (%edx),%ebx
f0102802:	8b 01                	mov    (%ecx),%eax
f0102804:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102807:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010280e:	eb 7f                	jmp    f010288f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0102810:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102813:	01 d8                	add    %ebx,%eax
f0102815:	89 c6                	mov    %eax,%esi
f0102817:	c1 ee 1f             	shr    $0x1f,%esi
f010281a:	01 c6                	add    %eax,%esi
f010281c:	d1 fe                	sar    %esi
f010281e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0102821:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102824:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102827:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102829:	eb 03                	jmp    f010282e <stab_binsearch+0x43>
			m--;
f010282b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010282e:	39 c3                	cmp    %eax,%ebx
f0102830:	7f 0d                	jg     f010283f <stab_binsearch+0x54>
f0102832:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102836:	83 ea 0c             	sub    $0xc,%edx
f0102839:	39 f9                	cmp    %edi,%ecx
f010283b:	75 ee                	jne    f010282b <stab_binsearch+0x40>
f010283d:	eb 05                	jmp    f0102844 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010283f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102842:	eb 4b                	jmp    f010288f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102844:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102847:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010284a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010284e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102851:	76 11                	jbe    f0102864 <stab_binsearch+0x79>
			*region_left = m;
f0102853:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102856:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0102858:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010285b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102862:	eb 2b                	jmp    f010288f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102864:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102867:	73 14                	jae    f010287d <stab_binsearch+0x92>
			*region_right = m - 1;
f0102869:	83 e8 01             	sub    $0x1,%eax
f010286c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010286f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102872:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102874:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010287b:	eb 12                	jmp    f010288f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010287d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102880:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102882:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0102886:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102888:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010288f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102892:	0f 8e 78 ff ff ff    	jle    f0102810 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102898:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010289c:	75 0f                	jne    f01028ad <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010289e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028a1:	8b 00                	mov    (%eax),%eax
f01028a3:	83 e8 01             	sub    $0x1,%eax
f01028a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028a9:	89 06                	mov    %eax,(%esi)
f01028ab:	eb 2c                	jmp    f01028d9 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028b0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01028b2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028b5:	8b 0e                	mov    (%esi),%ecx
f01028b7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01028ba:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01028bd:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028c0:	eb 03                	jmp    f01028c5 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01028c2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028c5:	39 c8                	cmp    %ecx,%eax
f01028c7:	7e 0b                	jle    f01028d4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01028c9:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01028cd:	83 ea 0c             	sub    $0xc,%edx
f01028d0:	39 df                	cmp    %ebx,%edi
f01028d2:	75 ee                	jne    f01028c2 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01028d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028d7:	89 06                	mov    %eax,(%esi)
	}
}
f01028d9:	83 c4 14             	add    $0x14,%esp
f01028dc:	5b                   	pop    %ebx
f01028dd:	5e                   	pop    %esi
f01028de:	5f                   	pop    %edi
f01028df:	5d                   	pop    %ebp
f01028e0:	c3                   	ret    

f01028e1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01028e1:	55                   	push   %ebp
f01028e2:	89 e5                	mov    %esp,%ebp
f01028e4:	57                   	push   %edi
f01028e5:	56                   	push   %esi
f01028e6:	53                   	push   %ebx
f01028e7:	83 ec 3c             	sub    $0x3c,%esp
f01028ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01028ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01028f0:	c7 03 e4 47 10 f0    	movl   $0xf01047e4,(%ebx)
	info->eip_line = 0;
f01028f6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01028fd:	c7 43 08 e4 47 10 f0 	movl   $0xf01047e4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102904:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010290b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010290e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102915:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010291b:	76 11                	jbe    f010292e <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010291d:	b8 a1 c2 10 f0       	mov    $0xf010c2a1,%eax
f0102922:	3d b5 a4 10 f0       	cmp    $0xf010a4b5,%eax
f0102927:	77 19                	ja     f0102942 <debuginfo_eip+0x61>
f0102929:	e9 a1 01 00 00       	jmp    f0102acf <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010292e:	83 ec 04             	sub    $0x4,%esp
f0102931:	68 ee 47 10 f0       	push   $0xf01047ee
f0102936:	6a 7f                	push   $0x7f
f0102938:	68 fb 47 10 f0       	push   $0xf01047fb
f010293d:	e8 a9 d7 ff ff       	call   f01000eb <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102942:	80 3d a0 c2 10 f0 00 	cmpb   $0x0,0xf010c2a0
f0102949:	0f 85 87 01 00 00    	jne    f0102ad6 <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010294f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102956:	b8 b4 a4 10 f0       	mov    $0xf010a4b4,%eax
f010295b:	2d 18 4a 10 f0       	sub    $0xf0104a18,%eax
f0102960:	c1 f8 02             	sar    $0x2,%eax
f0102963:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102969:	83 e8 01             	sub    $0x1,%eax
f010296c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010296f:	83 ec 08             	sub    $0x8,%esp
f0102972:	56                   	push   %esi
f0102973:	6a 64                	push   $0x64
f0102975:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102978:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010297b:	b8 18 4a 10 f0       	mov    $0xf0104a18,%eax
f0102980:	e8 66 fe ff ff       	call   f01027eb <stab_binsearch>
	if (lfile == 0)
f0102985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102988:	83 c4 10             	add    $0x10,%esp
f010298b:	85 c0                	test   %eax,%eax
f010298d:	0f 84 4a 01 00 00    	je     f0102add <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102993:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102996:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102999:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010299c:	83 ec 08             	sub    $0x8,%esp
f010299f:	56                   	push   %esi
f01029a0:	6a 24                	push   $0x24
f01029a2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01029a5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01029a8:	b8 18 4a 10 f0       	mov    $0xf0104a18,%eax
f01029ad:	e8 39 fe ff ff       	call   f01027eb <stab_binsearch>

	if (lfun <= rfun) {
f01029b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029b8:	83 c4 10             	add    $0x10,%esp
f01029bb:	39 d0                	cmp    %edx,%eax
f01029bd:	7f 40                	jg     f01029ff <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01029bf:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01029c2:	c1 e1 02             	shl    $0x2,%ecx
f01029c5:	8d b9 18 4a 10 f0    	lea    -0xfefb5e8(%ecx),%edi
f01029cb:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01029ce:	8b b9 18 4a 10 f0    	mov    -0xfefb5e8(%ecx),%edi
f01029d4:	b9 a1 c2 10 f0       	mov    $0xf010c2a1,%ecx
f01029d9:	81 e9 b5 a4 10 f0    	sub    $0xf010a4b5,%ecx
f01029df:	39 cf                	cmp    %ecx,%edi
f01029e1:	73 09                	jae    f01029ec <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01029e3:	81 c7 b5 a4 10 f0    	add    $0xf010a4b5,%edi
f01029e9:	89 7b 08             	mov    %edi,0x8(%ebx)
			
			
		info->eip_fn_addr = stabs[lfun].n_value;
f01029ec:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01029ef:	8b 4f 08             	mov    0x8(%edi),%ecx
f01029f2:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01029f5:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01029f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01029fa:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01029fd:	eb 0f                	jmp    f0102a0e <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01029ff:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102a02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a05:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102a08:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102a0e:	83 ec 08             	sub    $0x8,%esp
f0102a11:	6a 3a                	push   $0x3a
f0102a13:	ff 73 08             	pushl  0x8(%ebx)
f0102a16:	e8 f0 08 00 00       	call   f010330b <strfind>
f0102a1b:	2b 43 08             	sub    0x8(%ebx),%eax
f0102a1e:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102a21:	83 c4 08             	add    $0x8,%esp
f0102a24:	56                   	push   %esi
f0102a25:	6a 44                	push   $0x44
f0102a27:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102a2a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102a2d:	b8 18 4a 10 f0       	mov    $0xf0104a18,%eax
f0102a32:	e8 b4 fd ff ff       	call   f01027eb <stab_binsearch>
    info->eip_line=stabs[lline].n_desc;		
f0102a37:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a3a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a3d:	8d 04 85 18 4a 10 f0 	lea    -0xfefb5e8(,%eax,4),%eax
f0102a44:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102a48:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a4b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a4e:	83 c4 10             	add    $0x10,%esp
f0102a51:	eb 06                	jmp    f0102a59 <debuginfo_eip+0x178>
f0102a53:	83 ea 01             	sub    $0x1,%edx
f0102a56:	83 e8 0c             	sub    $0xc,%eax
f0102a59:	39 d6                	cmp    %edx,%esi
f0102a5b:	7f 34                	jg     f0102a91 <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0102a5d:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102a61:	80 f9 84             	cmp    $0x84,%cl
f0102a64:	74 0b                	je     f0102a71 <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102a66:	80 f9 64             	cmp    $0x64,%cl
f0102a69:	75 e8                	jne    f0102a53 <debuginfo_eip+0x172>
f0102a6b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102a6f:	74 e2                	je     f0102a53 <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a71:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a74:	8b 14 85 18 4a 10 f0 	mov    -0xfefb5e8(,%eax,4),%edx
f0102a7b:	b8 a1 c2 10 f0       	mov    $0xf010c2a1,%eax
f0102a80:	2d b5 a4 10 f0       	sub    $0xf010a4b5,%eax
f0102a85:	39 c2                	cmp    %eax,%edx
f0102a87:	73 08                	jae    f0102a91 <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102a89:	81 c2 b5 a4 10 f0    	add    $0xf010a4b5,%edx
f0102a8f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a91:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a94:	8b 75 d8             	mov    -0x28(%ebp),%esi
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102a97:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a9c:	39 f2                	cmp    %esi,%edx
f0102a9e:	7d 49                	jge    f0102ae9 <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0102aa0:	83 c2 01             	add    $0x1,%edx
f0102aa3:	89 d0                	mov    %edx,%eax
f0102aa5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102aa8:	8d 14 95 18 4a 10 f0 	lea    -0xfefb5e8(,%edx,4),%edx
f0102aaf:	eb 04                	jmp    f0102ab5 <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
		     {
			info->eip_fn_narg++;
f0102ab1:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102ab5:	39 c6                	cmp    %eax,%esi
f0102ab7:	7e 2b                	jle    f0102ae4 <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102ab9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102abd:	83 c0 01             	add    $0x1,%eax
f0102ac0:	83 c2 0c             	add    $0xc,%edx
f0102ac3:	80 f9 a0             	cmp    $0xa0,%cl
f0102ac6:	74 e9                	je     f0102ab1 <debuginfo_eip+0x1d0>
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102acd:	eb 1a                	jmp    f0102ae9 <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102acf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ad4:	eb 13                	jmp    f0102ae9 <debuginfo_eip+0x208>
f0102ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102adb:	eb 0c                	jmp    f0102ae9 <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102add:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ae2:	eb 05                	jmp    f0102ae9 <debuginfo_eip+0x208>
		     {
			info->eip_fn_narg++;
		}
		// give this to see number of arguments in init.c backtrace func
     //cprintf("m %d",info->eip_fn_narg);
	return 0;
f0102ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102aec:	5b                   	pop    %ebx
f0102aed:	5e                   	pop    %esi
f0102aee:	5f                   	pop    %edi
f0102aef:	5d                   	pop    %ebp
f0102af0:	c3                   	ret    

f0102af1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102af1:	55                   	push   %ebp
f0102af2:	89 e5                	mov    %esp,%ebp
f0102af4:	57                   	push   %edi
f0102af5:	56                   	push   %esi
f0102af6:	53                   	push   %ebx
f0102af7:	83 ec 1c             	sub    $0x1c,%esp
f0102afa:	89 c7                	mov    %eax,%edi
f0102afc:	89 d6                	mov    %edx,%esi
f0102afe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b01:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b04:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b07:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102b0d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b12:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102b15:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102b18:	39 d3                	cmp    %edx,%ebx
f0102b1a:	72 05                	jb     f0102b21 <printnum+0x30>
f0102b1c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102b1f:	77 45                	ja     f0102b66 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102b21:	83 ec 0c             	sub    $0xc,%esp
f0102b24:	ff 75 18             	pushl  0x18(%ebp)
f0102b27:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b2a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102b2d:	53                   	push   %ebx
f0102b2e:	ff 75 10             	pushl  0x10(%ebp)
f0102b31:	83 ec 08             	sub    $0x8,%esp
f0102b34:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b37:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b3a:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b3d:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b40:	e8 eb 09 00 00       	call   f0103530 <__udivdi3>
f0102b45:	83 c4 18             	add    $0x18,%esp
f0102b48:	52                   	push   %edx
f0102b49:	50                   	push   %eax
f0102b4a:	89 f2                	mov    %esi,%edx
f0102b4c:	89 f8                	mov    %edi,%eax
f0102b4e:	e8 9e ff ff ff       	call   f0102af1 <printnum>
f0102b53:	83 c4 20             	add    $0x20,%esp
f0102b56:	eb 18                	jmp    f0102b70 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b58:	83 ec 08             	sub    $0x8,%esp
f0102b5b:	56                   	push   %esi
f0102b5c:	ff 75 18             	pushl  0x18(%ebp)
f0102b5f:	ff d7                	call   *%edi
f0102b61:	83 c4 10             	add    $0x10,%esp
f0102b64:	eb 03                	jmp    f0102b69 <printnum+0x78>
f0102b66:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b69:	83 eb 01             	sub    $0x1,%ebx
f0102b6c:	85 db                	test   %ebx,%ebx
f0102b6e:	7f e8                	jg     f0102b58 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b70:	83 ec 08             	sub    $0x8,%esp
f0102b73:	56                   	push   %esi
f0102b74:	83 ec 04             	sub    $0x4,%esp
f0102b77:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b7a:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b7d:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b80:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b83:	e8 d8 0a 00 00       	call   f0103660 <__umoddi3>
f0102b88:	83 c4 14             	add    $0x14,%esp
f0102b8b:	0f be 80 09 48 10 f0 	movsbl -0xfefb7f7(%eax),%eax
f0102b92:	50                   	push   %eax
f0102b93:	ff d7                	call   *%edi
}
f0102b95:	83 c4 10             	add    $0x10,%esp
f0102b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b9b:	5b                   	pop    %ebx
f0102b9c:	5e                   	pop    %esi
f0102b9d:	5f                   	pop    %edi
f0102b9e:	5d                   	pop    %ebp
f0102b9f:	c3                   	ret    

f0102ba0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ba0:	55                   	push   %ebp
f0102ba1:	89 e5                	mov    %esp,%ebp
f0102ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102ba6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102baa:	8b 10                	mov    (%eax),%edx
f0102bac:	3b 50 04             	cmp    0x4(%eax),%edx
f0102baf:	73 0a                	jae    f0102bbb <sprintputch+0x1b>
		*b->buf++ = ch;
f0102bb1:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102bb4:	89 08                	mov    %ecx,(%eax)
f0102bb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bb9:	88 02                	mov    %al,(%edx)
}
f0102bbb:	5d                   	pop    %ebp
f0102bbc:	c3                   	ret    

f0102bbd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102bbd:	55                   	push   %ebp
f0102bbe:	89 e5                	mov    %esp,%ebp
f0102bc0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102bc3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102bc6:	50                   	push   %eax
f0102bc7:	ff 75 10             	pushl  0x10(%ebp)
f0102bca:	ff 75 0c             	pushl  0xc(%ebp)
f0102bcd:	ff 75 08             	pushl  0x8(%ebp)
f0102bd0:	e8 05 00 00 00       	call   f0102bda <vprintfmt>
	va_end(ap);
}
f0102bd5:	83 c4 10             	add    $0x10,%esp
f0102bd8:	c9                   	leave  
f0102bd9:	c3                   	ret    

f0102bda <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102bda:	55                   	push   %ebp
f0102bdb:	89 e5                	mov    %esp,%ebp
f0102bdd:	57                   	push   %edi
f0102bde:	56                   	push   %esi
f0102bdf:	53                   	push   %ebx
f0102be0:	83 ec 2c             	sub    $0x2c,%esp
f0102be3:	8b 75 08             	mov    0x8(%ebp),%esi
f0102be6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102be9:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102bec:	eb 12                	jmp    f0102c00 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102bee:	85 c0                	test   %eax,%eax
f0102bf0:	0f 84 6a 04 00 00    	je     f0103060 <vprintfmt+0x486>
				return;
			putch(ch, putdat);
f0102bf6:	83 ec 08             	sub    $0x8,%esp
f0102bf9:	53                   	push   %ebx
f0102bfa:	50                   	push   %eax
f0102bfb:	ff d6                	call   *%esi
f0102bfd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c00:	83 c7 01             	add    $0x1,%edi
f0102c03:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102c07:	83 f8 25             	cmp    $0x25,%eax
f0102c0a:	75 e2                	jne    f0102bee <vprintfmt+0x14>
f0102c0c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102c10:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102c17:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102c1e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102c25:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102c2a:	eb 07                	jmp    f0102c33 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102c2f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c33:	8d 47 01             	lea    0x1(%edi),%eax
f0102c36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c39:	0f b6 07             	movzbl (%edi),%eax
f0102c3c:	0f b6 d0             	movzbl %al,%edx
f0102c3f:	83 e8 23             	sub    $0x23,%eax
f0102c42:	3c 55                	cmp    $0x55,%al
f0102c44:	0f 87 fb 03 00 00    	ja     f0103045 <vprintfmt+0x46b>
f0102c4a:	0f b6 c0             	movzbl %al,%eax
f0102c4d:	ff 24 85 94 48 10 f0 	jmp    *-0xfefb76c(,%eax,4)
f0102c54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102c57:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c5b:	eb d6                	jmp    f0102c33 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c65:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102c68:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c6b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0102c6f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102c72:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102c75:	83 f9 09             	cmp    $0x9,%ecx
f0102c78:	77 3f                	ja     f0102cb9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102c7a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102c7d:	eb e9                	jmp    f0102c68 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102c7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c82:	8b 00                	mov    (%eax),%eax
f0102c84:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c87:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c8a:	8d 40 04             	lea    0x4(%eax),%eax
f0102c8d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102c93:	eb 2a                	jmp    f0102cbf <vprintfmt+0xe5>
f0102c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c98:	85 c0                	test   %eax,%eax
f0102c9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c9f:	0f 49 d0             	cmovns %eax,%edx
f0102ca2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ca5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ca8:	eb 89                	jmp    f0102c33 <vprintfmt+0x59>
f0102caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102cad:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102cb4:	e9 7a ff ff ff       	jmp    f0102c33 <vprintfmt+0x59>
f0102cb9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102cbc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102cbf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102cc3:	0f 89 6a ff ff ff    	jns    f0102c33 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102cc9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ccc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ccf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102cd6:	e9 58 ff ff ff       	jmp    f0102c33 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102cdb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102ce1:	e9 4d ff ff ff       	jmp    f0102c33 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102ce6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ce9:	8d 78 04             	lea    0x4(%eax),%edi
f0102cec:	83 ec 08             	sub    $0x8,%esp
f0102cef:	53                   	push   %ebx
f0102cf0:	ff 30                	pushl  (%eax)
f0102cf2:	ff d6                	call   *%esi
			break;
f0102cf4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102cf7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cfa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102cfd:	e9 fe fe ff ff       	jmp    f0102c00 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d02:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d05:	8d 78 04             	lea    0x4(%eax),%edi
f0102d08:	8b 00                	mov    (%eax),%eax
f0102d0a:	99                   	cltd   
f0102d0b:	31 d0                	xor    %edx,%eax
f0102d0d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102d0f:	83 f8 06             	cmp    $0x6,%eax
f0102d12:	7f 0b                	jg     f0102d1f <vprintfmt+0x145>
f0102d14:	8b 14 85 ec 49 10 f0 	mov    -0xfefb614(,%eax,4),%edx
f0102d1b:	85 d2                	test   %edx,%edx
f0102d1d:	75 1b                	jne    f0102d3a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0102d1f:	50                   	push   %eax
f0102d20:	68 21 48 10 f0       	push   $0xf0104821
f0102d25:	53                   	push   %ebx
f0102d26:	56                   	push   %esi
f0102d27:	e8 91 fe ff ff       	call   f0102bbd <printfmt>
f0102d2c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d2f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102d35:	e9 c6 fe ff ff       	jmp    f0102c00 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102d3a:	52                   	push   %edx
f0102d3b:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0102d40:	53                   	push   %ebx
f0102d41:	56                   	push   %esi
f0102d42:	e8 76 fe ff ff       	call   f0102bbd <printfmt>
f0102d47:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d4a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d50:	e9 ab fe ff ff       	jmp    f0102c00 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102d55:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d58:	83 c0 04             	add    $0x4,%eax
f0102d5b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102d5e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d61:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102d63:	85 ff                	test   %edi,%edi
f0102d65:	b8 1a 48 10 f0       	mov    $0xf010481a,%eax
f0102d6a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102d6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d71:	0f 8e 94 00 00 00    	jle    f0102e0b <vprintfmt+0x231>
f0102d77:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d7b:	0f 84 98 00 00 00    	je     f0102e19 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102d81:	83 ec 08             	sub    $0x8,%esp
f0102d84:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d87:	57                   	push   %edi
f0102d88:	e8 34 04 00 00       	call   f01031c1 <strnlen>
f0102d8d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102d90:	29 c1                	sub    %eax,%ecx
f0102d92:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102d95:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102d98:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d9f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102da2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102da4:	eb 0f                	jmp    f0102db5 <vprintfmt+0x1db>
					putch(padc, putdat);
f0102da6:	83 ec 08             	sub    $0x8,%esp
f0102da9:	53                   	push   %ebx
f0102daa:	ff 75 e0             	pushl  -0x20(%ebp)
f0102dad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102daf:	83 ef 01             	sub    $0x1,%edi
f0102db2:	83 c4 10             	add    $0x10,%esp
f0102db5:	85 ff                	test   %edi,%edi
f0102db7:	7f ed                	jg     f0102da6 <vprintfmt+0x1cc>
f0102db9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102dbc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102dbf:	85 c9                	test   %ecx,%ecx
f0102dc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dc6:	0f 49 c1             	cmovns %ecx,%eax
f0102dc9:	29 c1                	sub    %eax,%ecx
f0102dcb:	89 75 08             	mov    %esi,0x8(%ebp)
f0102dce:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102dd1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102dd4:	89 cb                	mov    %ecx,%ebx
f0102dd6:	eb 4d                	jmp    f0102e25 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102dd8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102ddc:	74 1b                	je     f0102df9 <vprintfmt+0x21f>
f0102dde:	0f be c0             	movsbl %al,%eax
f0102de1:	83 e8 20             	sub    $0x20,%eax
f0102de4:	83 f8 5e             	cmp    $0x5e,%eax
f0102de7:	76 10                	jbe    f0102df9 <vprintfmt+0x21f>
					putch('?', putdat);
f0102de9:	83 ec 08             	sub    $0x8,%esp
f0102dec:	ff 75 0c             	pushl  0xc(%ebp)
f0102def:	6a 3f                	push   $0x3f
f0102df1:	ff 55 08             	call   *0x8(%ebp)
f0102df4:	83 c4 10             	add    $0x10,%esp
f0102df7:	eb 0d                	jmp    f0102e06 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0102df9:	83 ec 08             	sub    $0x8,%esp
f0102dfc:	ff 75 0c             	pushl  0xc(%ebp)
f0102dff:	52                   	push   %edx
f0102e00:	ff 55 08             	call   *0x8(%ebp)
f0102e03:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e06:	83 eb 01             	sub    $0x1,%ebx
f0102e09:	eb 1a                	jmp    f0102e25 <vprintfmt+0x24b>
f0102e0b:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e0e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e11:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e14:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e17:	eb 0c                	jmp    f0102e25 <vprintfmt+0x24b>
f0102e19:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e1c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e1f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e22:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e25:	83 c7 01             	add    $0x1,%edi
f0102e28:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e2c:	0f be d0             	movsbl %al,%edx
f0102e2f:	85 d2                	test   %edx,%edx
f0102e31:	74 23                	je     f0102e56 <vprintfmt+0x27c>
f0102e33:	85 f6                	test   %esi,%esi
f0102e35:	78 a1                	js     f0102dd8 <vprintfmt+0x1fe>
f0102e37:	83 ee 01             	sub    $0x1,%esi
f0102e3a:	79 9c                	jns    f0102dd8 <vprintfmt+0x1fe>
f0102e3c:	89 df                	mov    %ebx,%edi
f0102e3e:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e44:	eb 18                	jmp    f0102e5e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102e46:	83 ec 08             	sub    $0x8,%esp
f0102e49:	53                   	push   %ebx
f0102e4a:	6a 20                	push   $0x20
f0102e4c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102e4e:	83 ef 01             	sub    $0x1,%edi
f0102e51:	83 c4 10             	add    $0x10,%esp
f0102e54:	eb 08                	jmp    f0102e5e <vprintfmt+0x284>
f0102e56:	89 df                	mov    %ebx,%edi
f0102e58:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e5e:	85 ff                	test   %edi,%edi
f0102e60:	7f e4                	jg     f0102e46 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102e62:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e65:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e6b:	e9 90 fd ff ff       	jmp    f0102c00 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e70:	83 f9 01             	cmp    $0x1,%ecx
f0102e73:	7e 19                	jle    f0102e8e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0102e75:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e78:	8b 50 04             	mov    0x4(%eax),%edx
f0102e7b:	8b 00                	mov    (%eax),%eax
f0102e7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e80:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e83:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e86:	8d 40 08             	lea    0x8(%eax),%eax
f0102e89:	89 45 14             	mov    %eax,0x14(%ebp)
f0102e8c:	eb 38                	jmp    f0102ec6 <vprintfmt+0x2ec>
	else if (lflag)
f0102e8e:	85 c9                	test   %ecx,%ecx
f0102e90:	74 1b                	je     f0102ead <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0102e92:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e95:	8b 00                	mov    (%eax),%eax
f0102e97:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e9a:	89 c1                	mov    %eax,%ecx
f0102e9c:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e9f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102ea2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ea5:	8d 40 04             	lea    0x4(%eax),%eax
f0102ea8:	89 45 14             	mov    %eax,0x14(%ebp)
f0102eab:	eb 19                	jmp    f0102ec6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0102ead:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eb0:	8b 00                	mov    (%eax),%eax
f0102eb2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102eb5:	89 c1                	mov    %eax,%ecx
f0102eb7:	c1 f9 1f             	sar    $0x1f,%ecx
f0102eba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102ebd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ec0:	8d 40 04             	lea    0x4(%eax),%eax
f0102ec3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102ec6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102ec9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102ecc:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102ed1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102ed5:	0f 89 36 01 00 00    	jns    f0103011 <vprintfmt+0x437>
				putch('-', putdat);
f0102edb:	83 ec 08             	sub    $0x8,%esp
f0102ede:	53                   	push   %ebx
f0102edf:	6a 2d                	push   $0x2d
f0102ee1:	ff d6                	call   *%esi
				num = -(long long) num;
f0102ee3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102ee6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102ee9:	f7 da                	neg    %edx
f0102eeb:	83 d1 00             	adc    $0x0,%ecx
f0102eee:	f7 d9                	neg    %ecx
f0102ef0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102ef3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102ef8:	e9 14 01 00 00       	jmp    f0103011 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102efd:	83 f9 01             	cmp    $0x1,%ecx
f0102f00:	7e 18                	jle    f0102f1a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0102f02:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f05:	8b 10                	mov    (%eax),%edx
f0102f07:	8b 48 04             	mov    0x4(%eax),%ecx
f0102f0a:	8d 40 08             	lea    0x8(%eax),%eax
f0102f0d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f10:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102f15:	e9 f7 00 00 00       	jmp    f0103011 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102f1a:	85 c9                	test   %ecx,%ecx
f0102f1c:	74 1a                	je     f0102f38 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0102f1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f21:	8b 10                	mov    (%eax),%edx
f0102f23:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102f28:	8d 40 04             	lea    0x4(%eax),%eax
f0102f2b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f2e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102f33:	e9 d9 00 00 00       	jmp    f0103011 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102f38:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f3b:	8b 10                	mov    (%eax),%edx
f0102f3d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102f42:	8d 40 04             	lea    0x4(%eax),%eax
f0102f45:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f48:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102f4d:	e9 bf 00 00 00       	jmp    f0103011 <vprintfmt+0x437>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f52:	83 f9 01             	cmp    $0x1,%ecx
f0102f55:	7e 13                	jle    f0102f6a <vprintfmt+0x390>
		return va_arg(*ap, long long);
f0102f57:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f5a:	8b 50 04             	mov    0x4(%eax),%edx
f0102f5d:	8b 00                	mov    (%eax),%eax
f0102f5f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f62:	8d 49 08             	lea    0x8(%ecx),%ecx
f0102f65:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102f68:	eb 28                	jmp    f0102f92 <vprintfmt+0x3b8>
	else if (lflag)
f0102f6a:	85 c9                	test   %ecx,%ecx
f0102f6c:	74 13                	je     f0102f81 <vprintfmt+0x3a7>
		return va_arg(*ap, long);
f0102f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f71:	8b 10                	mov    (%eax),%edx
f0102f73:	89 d0                	mov    %edx,%eax
f0102f75:	99                   	cltd   
f0102f76:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f79:	8d 49 04             	lea    0x4(%ecx),%ecx
f0102f7c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102f7f:	eb 11                	jmp    f0102f92 <vprintfmt+0x3b8>
	else
		return va_arg(*ap, int);
f0102f81:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f84:	8b 10                	mov    (%eax),%edx
f0102f86:	89 d0                	mov    %edx,%eax
f0102f88:	99                   	cltd   
f0102f89:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102f8c:	8d 49 04             	lea    0x4(%ecx),%ecx
f0102f8f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f0102f92:	89 d1                	mov    %edx,%ecx
f0102f94:	89 c2                	mov    %eax,%edx
			base = 8;
f0102f96:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0102f9b:	eb 74                	jmp    f0103011 <vprintfmt+0x437>

		// pointer
		case 'p':
			putch('0', putdat);
f0102f9d:	83 ec 08             	sub    $0x8,%esp
f0102fa0:	53                   	push   %ebx
f0102fa1:	6a 30                	push   $0x30
f0102fa3:	ff d6                	call   *%esi
			putch('x', putdat);
f0102fa5:	83 c4 08             	add    $0x8,%esp
f0102fa8:	53                   	push   %ebx
f0102fa9:	6a 78                	push   $0x78
f0102fab:	ff d6                	call   *%esi
			num = (unsigned long long)
f0102fad:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fb0:	8b 10                	mov    (%eax),%edx
f0102fb2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102fb7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102fba:	8d 40 04             	lea    0x4(%eax),%eax
f0102fbd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102fc0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102fc5:	eb 4a                	jmp    f0103011 <vprintfmt+0x437>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102fc7:	83 f9 01             	cmp    $0x1,%ecx
f0102fca:	7e 15                	jle    f0102fe1 <vprintfmt+0x407>
		return va_arg(*ap, unsigned long long);
f0102fcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fcf:	8b 10                	mov    (%eax),%edx
f0102fd1:	8b 48 04             	mov    0x4(%eax),%ecx
f0102fd4:	8d 40 08             	lea    0x8(%eax),%eax
f0102fd7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fda:	b8 10 00 00 00       	mov    $0x10,%eax
f0102fdf:	eb 30                	jmp    f0103011 <vprintfmt+0x437>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102fe1:	85 c9                	test   %ecx,%ecx
f0102fe3:	74 17                	je     f0102ffc <vprintfmt+0x422>
		return va_arg(*ap, unsigned long);
f0102fe5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fe8:	8b 10                	mov    (%eax),%edx
f0102fea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fef:	8d 40 04             	lea    0x4(%eax),%eax
f0102ff2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102ff5:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ffa:	eb 15                	jmp    f0103011 <vprintfmt+0x437>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102ffc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fff:	8b 10                	mov    (%eax),%edx
f0103001:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103006:	8d 40 04             	lea    0x4(%eax),%eax
f0103009:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f010300c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103011:	83 ec 0c             	sub    $0xc,%esp
f0103014:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103018:	57                   	push   %edi
f0103019:	ff 75 e0             	pushl  -0x20(%ebp)
f010301c:	50                   	push   %eax
f010301d:	51                   	push   %ecx
f010301e:	52                   	push   %edx
f010301f:	89 da                	mov    %ebx,%edx
f0103021:	89 f0                	mov    %esi,%eax
f0103023:	e8 c9 fa ff ff       	call   f0102af1 <printnum>
			break;
f0103028:	83 c4 20             	add    $0x20,%esp
f010302b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010302e:	e9 cd fb ff ff       	jmp    f0102c00 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103033:	83 ec 08             	sub    $0x8,%esp
f0103036:	53                   	push   %ebx
f0103037:	52                   	push   %edx
f0103038:	ff d6                	call   *%esi
			break;
f010303a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010303d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103040:	e9 bb fb ff ff       	jmp    f0102c00 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103045:	83 ec 08             	sub    $0x8,%esp
f0103048:	53                   	push   %ebx
f0103049:	6a 25                	push   $0x25
f010304b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010304d:	83 c4 10             	add    $0x10,%esp
f0103050:	eb 03                	jmp    f0103055 <vprintfmt+0x47b>
f0103052:	83 ef 01             	sub    $0x1,%edi
f0103055:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103059:	75 f7                	jne    f0103052 <vprintfmt+0x478>
f010305b:	e9 a0 fb ff ff       	jmp    f0102c00 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103060:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103063:	5b                   	pop    %ebx
f0103064:	5e                   	pop    %esi
f0103065:	5f                   	pop    %edi
f0103066:	5d                   	pop    %ebp
f0103067:	c3                   	ret    

f0103068 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103068:	55                   	push   %ebp
f0103069:	89 e5                	mov    %esp,%ebp
f010306b:	83 ec 18             	sub    $0x18,%esp
f010306e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103071:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103074:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103077:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010307b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010307e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103085:	85 c0                	test   %eax,%eax
f0103087:	74 26                	je     f01030af <vsnprintf+0x47>
f0103089:	85 d2                	test   %edx,%edx
f010308b:	7e 22                	jle    f01030af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010308d:	ff 75 14             	pushl  0x14(%ebp)
f0103090:	ff 75 10             	pushl  0x10(%ebp)
f0103093:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103096:	50                   	push   %eax
f0103097:	68 a0 2b 10 f0       	push   $0xf0102ba0
f010309c:	e8 39 fb ff ff       	call   f0102bda <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01030a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01030a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01030a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030aa:	83 c4 10             	add    $0x10,%esp
f01030ad:	eb 05                	jmp    f01030b4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01030af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01030b4:	c9                   	leave  
f01030b5:	c3                   	ret    

f01030b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01030b6:	55                   	push   %ebp
f01030b7:	89 e5                	mov    %esp,%ebp
f01030b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01030bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01030bf:	50                   	push   %eax
f01030c0:	ff 75 10             	pushl  0x10(%ebp)
f01030c3:	ff 75 0c             	pushl  0xc(%ebp)
f01030c6:	ff 75 08             	pushl  0x8(%ebp)
f01030c9:	e8 9a ff ff ff       	call   f0103068 <vsnprintf>
	va_end(ap);

	return rc;
}
f01030ce:	c9                   	leave  
f01030cf:	c3                   	ret    

f01030d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01030d0:	55                   	push   %ebp
f01030d1:	89 e5                	mov    %esp,%ebp
f01030d3:	57                   	push   %edi
f01030d4:	56                   	push   %esi
f01030d5:	53                   	push   %ebx
f01030d6:	83 ec 0c             	sub    $0xc,%esp
f01030d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01030dc:	85 c0                	test   %eax,%eax
f01030de:	74 11                	je     f01030f1 <readline+0x21>
		cprintf("%s", prompt);
f01030e0:	83 ec 08             	sub    $0x8,%esp
f01030e3:	50                   	push   %eax
f01030e4:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01030e9:	e8 e9 f6 ff ff       	call   f01027d7 <cprintf>
f01030ee:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01030f1:	83 ec 0c             	sub    $0xc,%esp
f01030f4:	6a 00                	push   $0x0
f01030f6:	e8 86 d5 ff ff       	call   f0100681 <iscons>
f01030fb:	89 c7                	mov    %eax,%edi
f01030fd:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103100:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103105:	e8 66 d5 ff ff       	call   f0100670 <getchar>
f010310a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010310c:	85 c0                	test   %eax,%eax
f010310e:	79 18                	jns    f0103128 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103110:	83 ec 08             	sub    $0x8,%esp
f0103113:	50                   	push   %eax
f0103114:	68 08 4a 10 f0       	push   $0xf0104a08
f0103119:	e8 b9 f6 ff ff       	call   f01027d7 <cprintf>
			return NULL;
f010311e:	83 c4 10             	add    $0x10,%esp
f0103121:	b8 00 00 00 00       	mov    $0x0,%eax
f0103126:	eb 79                	jmp    f01031a1 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103128:	83 f8 08             	cmp    $0x8,%eax
f010312b:	0f 94 c2             	sete   %dl
f010312e:	83 f8 7f             	cmp    $0x7f,%eax
f0103131:	0f 94 c0             	sete   %al
f0103134:	08 c2                	or     %al,%dl
f0103136:	74 1a                	je     f0103152 <readline+0x82>
f0103138:	85 f6                	test   %esi,%esi
f010313a:	7e 16                	jle    f0103152 <readline+0x82>
			if (echoing)
f010313c:	85 ff                	test   %edi,%edi
f010313e:	74 0d                	je     f010314d <readline+0x7d>
				cputchar('\b');
f0103140:	83 ec 0c             	sub    $0xc,%esp
f0103143:	6a 08                	push   $0x8
f0103145:	e8 16 d5 ff ff       	call   f0100660 <cputchar>
f010314a:	83 c4 10             	add    $0x10,%esp
			i--;
f010314d:	83 ee 01             	sub    $0x1,%esi
f0103150:	eb b3                	jmp    f0103105 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103152:	83 fb 1f             	cmp    $0x1f,%ebx
f0103155:	7e 23                	jle    f010317a <readline+0xaa>
f0103157:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010315d:	7f 1b                	jg     f010317a <readline+0xaa>
			if (echoing)
f010315f:	85 ff                	test   %edi,%edi
f0103161:	74 0c                	je     f010316f <readline+0x9f>
				cputchar(c);
f0103163:	83 ec 0c             	sub    $0xc,%esp
f0103166:	53                   	push   %ebx
f0103167:	e8 f4 d4 ff ff       	call   f0100660 <cputchar>
f010316c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010316f:	88 9e 40 75 11 f0    	mov    %bl,-0xfee8ac0(%esi)
f0103175:	8d 76 01             	lea    0x1(%esi),%esi
f0103178:	eb 8b                	jmp    f0103105 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010317a:	83 fb 0a             	cmp    $0xa,%ebx
f010317d:	74 05                	je     f0103184 <readline+0xb4>
f010317f:	83 fb 0d             	cmp    $0xd,%ebx
f0103182:	75 81                	jne    f0103105 <readline+0x35>
			if (echoing)
f0103184:	85 ff                	test   %edi,%edi
f0103186:	74 0d                	je     f0103195 <readline+0xc5>
				cputchar('\n');
f0103188:	83 ec 0c             	sub    $0xc,%esp
f010318b:	6a 0a                	push   $0xa
f010318d:	e8 ce d4 ff ff       	call   f0100660 <cputchar>
f0103192:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103195:	c6 86 40 75 11 f0 00 	movb   $0x0,-0xfee8ac0(%esi)
			return buf;
f010319c:	b8 40 75 11 f0       	mov    $0xf0117540,%eax
		}
	}
}
f01031a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031a4:	5b                   	pop    %ebx
f01031a5:	5e                   	pop    %esi
f01031a6:	5f                   	pop    %edi
f01031a7:	5d                   	pop    %ebp
f01031a8:	c3                   	ret    

f01031a9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01031a9:	55                   	push   %ebp
f01031aa:	89 e5                	mov    %esp,%ebp
f01031ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01031af:	b8 00 00 00 00       	mov    $0x0,%eax
f01031b4:	eb 03                	jmp    f01031b9 <strlen+0x10>
		n++;
f01031b6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01031b9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01031bd:	75 f7                	jne    f01031b6 <strlen+0xd>
		n++;
	return n;
}
f01031bf:	5d                   	pop    %ebp
f01031c0:	c3                   	ret    

f01031c1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01031c1:	55                   	push   %ebp
f01031c2:	89 e5                	mov    %esp,%ebp
f01031c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01031ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01031cf:	eb 03                	jmp    f01031d4 <strnlen+0x13>
		n++;
f01031d1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01031d4:	39 c2                	cmp    %eax,%edx
f01031d6:	74 08                	je     f01031e0 <strnlen+0x1f>
f01031d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01031dc:	75 f3                	jne    f01031d1 <strnlen+0x10>
f01031de:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01031e0:	5d                   	pop    %ebp
f01031e1:	c3                   	ret    

f01031e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01031e2:	55                   	push   %ebp
f01031e3:	89 e5                	mov    %esp,%ebp
f01031e5:	53                   	push   %ebx
f01031e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01031ec:	89 c2                	mov    %eax,%edx
f01031ee:	83 c2 01             	add    $0x1,%edx
f01031f1:	83 c1 01             	add    $0x1,%ecx
f01031f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01031f8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031fb:	84 db                	test   %bl,%bl
f01031fd:	75 ef                	jne    f01031ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01031ff:	5b                   	pop    %ebx
f0103200:	5d                   	pop    %ebp
f0103201:	c3                   	ret    

f0103202 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103202:	55                   	push   %ebp
f0103203:	89 e5                	mov    %esp,%ebp
f0103205:	53                   	push   %ebx
f0103206:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103209:	53                   	push   %ebx
f010320a:	e8 9a ff ff ff       	call   f01031a9 <strlen>
f010320f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103212:	ff 75 0c             	pushl  0xc(%ebp)
f0103215:	01 d8                	add    %ebx,%eax
f0103217:	50                   	push   %eax
f0103218:	e8 c5 ff ff ff       	call   f01031e2 <strcpy>
	return dst;
}
f010321d:	89 d8                	mov    %ebx,%eax
f010321f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103222:	c9                   	leave  
f0103223:	c3                   	ret    

f0103224 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103224:	55                   	push   %ebp
f0103225:	89 e5                	mov    %esp,%ebp
f0103227:	56                   	push   %esi
f0103228:	53                   	push   %ebx
f0103229:	8b 75 08             	mov    0x8(%ebp),%esi
f010322c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010322f:	89 f3                	mov    %esi,%ebx
f0103231:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103234:	89 f2                	mov    %esi,%edx
f0103236:	eb 0f                	jmp    f0103247 <strncpy+0x23>
		*dst++ = *src;
f0103238:	83 c2 01             	add    $0x1,%edx
f010323b:	0f b6 01             	movzbl (%ecx),%eax
f010323e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103241:	80 39 01             	cmpb   $0x1,(%ecx)
f0103244:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103247:	39 da                	cmp    %ebx,%edx
f0103249:	75 ed                	jne    f0103238 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010324b:	89 f0                	mov    %esi,%eax
f010324d:	5b                   	pop    %ebx
f010324e:	5e                   	pop    %esi
f010324f:	5d                   	pop    %ebp
f0103250:	c3                   	ret    

f0103251 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103251:	55                   	push   %ebp
f0103252:	89 e5                	mov    %esp,%ebp
f0103254:	56                   	push   %esi
f0103255:	53                   	push   %ebx
f0103256:	8b 75 08             	mov    0x8(%ebp),%esi
f0103259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010325c:	8b 55 10             	mov    0x10(%ebp),%edx
f010325f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103261:	85 d2                	test   %edx,%edx
f0103263:	74 21                	je     f0103286 <strlcpy+0x35>
f0103265:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103269:	89 f2                	mov    %esi,%edx
f010326b:	eb 09                	jmp    f0103276 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010326d:	83 c2 01             	add    $0x1,%edx
f0103270:	83 c1 01             	add    $0x1,%ecx
f0103273:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103276:	39 c2                	cmp    %eax,%edx
f0103278:	74 09                	je     f0103283 <strlcpy+0x32>
f010327a:	0f b6 19             	movzbl (%ecx),%ebx
f010327d:	84 db                	test   %bl,%bl
f010327f:	75 ec                	jne    f010326d <strlcpy+0x1c>
f0103281:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103283:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103286:	29 f0                	sub    %esi,%eax
}
f0103288:	5b                   	pop    %ebx
f0103289:	5e                   	pop    %esi
f010328a:	5d                   	pop    %ebp
f010328b:	c3                   	ret    

f010328c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010328c:	55                   	push   %ebp
f010328d:	89 e5                	mov    %esp,%ebp
f010328f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103292:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103295:	eb 06                	jmp    f010329d <strcmp+0x11>
		p++, q++;
f0103297:	83 c1 01             	add    $0x1,%ecx
f010329a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010329d:	0f b6 01             	movzbl (%ecx),%eax
f01032a0:	84 c0                	test   %al,%al
f01032a2:	74 04                	je     f01032a8 <strcmp+0x1c>
f01032a4:	3a 02                	cmp    (%edx),%al
f01032a6:	74 ef                	je     f0103297 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01032a8:	0f b6 c0             	movzbl %al,%eax
f01032ab:	0f b6 12             	movzbl (%edx),%edx
f01032ae:	29 d0                	sub    %edx,%eax
}
f01032b0:	5d                   	pop    %ebp
f01032b1:	c3                   	ret    

f01032b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01032b2:	55                   	push   %ebp
f01032b3:	89 e5                	mov    %esp,%ebp
f01032b5:	53                   	push   %ebx
f01032b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032bc:	89 c3                	mov    %eax,%ebx
f01032be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01032c1:	eb 06                	jmp    f01032c9 <strncmp+0x17>
		n--, p++, q++;
f01032c3:	83 c0 01             	add    $0x1,%eax
f01032c6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01032c9:	39 d8                	cmp    %ebx,%eax
f01032cb:	74 15                	je     f01032e2 <strncmp+0x30>
f01032cd:	0f b6 08             	movzbl (%eax),%ecx
f01032d0:	84 c9                	test   %cl,%cl
f01032d2:	74 04                	je     f01032d8 <strncmp+0x26>
f01032d4:	3a 0a                	cmp    (%edx),%cl
f01032d6:	74 eb                	je     f01032c3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01032d8:	0f b6 00             	movzbl (%eax),%eax
f01032db:	0f b6 12             	movzbl (%edx),%edx
f01032de:	29 d0                	sub    %edx,%eax
f01032e0:	eb 05                	jmp    f01032e7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01032e2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01032e7:	5b                   	pop    %ebx
f01032e8:	5d                   	pop    %ebp
f01032e9:	c3                   	ret    

f01032ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01032ea:	55                   	push   %ebp
f01032eb:	89 e5                	mov    %esp,%ebp
f01032ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032f4:	eb 07                	jmp    f01032fd <strchr+0x13>
		if (*s == c)
f01032f6:	38 ca                	cmp    %cl,%dl
f01032f8:	74 0f                	je     f0103309 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01032fa:	83 c0 01             	add    $0x1,%eax
f01032fd:	0f b6 10             	movzbl (%eax),%edx
f0103300:	84 d2                	test   %dl,%dl
f0103302:	75 f2                	jne    f01032f6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103304:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103309:	5d                   	pop    %ebp
f010330a:	c3                   	ret    

f010330b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010330b:	55                   	push   %ebp
f010330c:	89 e5                	mov    %esp,%ebp
f010330e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103311:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103315:	eb 03                	jmp    f010331a <strfind+0xf>
f0103317:	83 c0 01             	add    $0x1,%eax
f010331a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010331d:	38 ca                	cmp    %cl,%dl
f010331f:	74 04                	je     f0103325 <strfind+0x1a>
f0103321:	84 d2                	test   %dl,%dl
f0103323:	75 f2                	jne    f0103317 <strfind+0xc>
			break;
	return (char *) s;
}
f0103325:	5d                   	pop    %ebp
f0103326:	c3                   	ret    

f0103327 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103327:	55                   	push   %ebp
f0103328:	89 e5                	mov    %esp,%ebp
f010332a:	57                   	push   %edi
f010332b:	56                   	push   %esi
f010332c:	53                   	push   %ebx
f010332d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103330:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103333:	85 c9                	test   %ecx,%ecx
f0103335:	74 36                	je     f010336d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103337:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010333d:	75 28                	jne    f0103367 <memset+0x40>
f010333f:	f6 c1 03             	test   $0x3,%cl
f0103342:	75 23                	jne    f0103367 <memset+0x40>
		c &= 0xFF;
f0103344:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103348:	89 d3                	mov    %edx,%ebx
f010334a:	c1 e3 08             	shl    $0x8,%ebx
f010334d:	89 d6                	mov    %edx,%esi
f010334f:	c1 e6 18             	shl    $0x18,%esi
f0103352:	89 d0                	mov    %edx,%eax
f0103354:	c1 e0 10             	shl    $0x10,%eax
f0103357:	09 f0                	or     %esi,%eax
f0103359:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010335b:	89 d8                	mov    %ebx,%eax
f010335d:	09 d0                	or     %edx,%eax
f010335f:	c1 e9 02             	shr    $0x2,%ecx
f0103362:	fc                   	cld    
f0103363:	f3 ab                	rep stos %eax,%es:(%edi)
f0103365:	eb 06                	jmp    f010336d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103367:	8b 45 0c             	mov    0xc(%ebp),%eax
f010336a:	fc                   	cld    
f010336b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010336d:	89 f8                	mov    %edi,%eax
f010336f:	5b                   	pop    %ebx
f0103370:	5e                   	pop    %esi
f0103371:	5f                   	pop    %edi
f0103372:	5d                   	pop    %ebp
f0103373:	c3                   	ret    

f0103374 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103374:	55                   	push   %ebp
f0103375:	89 e5                	mov    %esp,%ebp
f0103377:	57                   	push   %edi
f0103378:	56                   	push   %esi
f0103379:	8b 45 08             	mov    0x8(%ebp),%eax
f010337c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010337f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103382:	39 c6                	cmp    %eax,%esi
f0103384:	73 35                	jae    f01033bb <memmove+0x47>
f0103386:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103389:	39 d0                	cmp    %edx,%eax
f010338b:	73 2e                	jae    f01033bb <memmove+0x47>
		s += n;
		d += n;
f010338d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103390:	89 d6                	mov    %edx,%esi
f0103392:	09 fe                	or     %edi,%esi
f0103394:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010339a:	75 13                	jne    f01033af <memmove+0x3b>
f010339c:	f6 c1 03             	test   $0x3,%cl
f010339f:	75 0e                	jne    f01033af <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01033a1:	83 ef 04             	sub    $0x4,%edi
f01033a4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01033a7:	c1 e9 02             	shr    $0x2,%ecx
f01033aa:	fd                   	std    
f01033ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01033ad:	eb 09                	jmp    f01033b8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01033af:	83 ef 01             	sub    $0x1,%edi
f01033b2:	8d 72 ff             	lea    -0x1(%edx),%esi
f01033b5:	fd                   	std    
f01033b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01033b8:	fc                   	cld    
f01033b9:	eb 1d                	jmp    f01033d8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01033bb:	89 f2                	mov    %esi,%edx
f01033bd:	09 c2                	or     %eax,%edx
f01033bf:	f6 c2 03             	test   $0x3,%dl
f01033c2:	75 0f                	jne    f01033d3 <memmove+0x5f>
f01033c4:	f6 c1 03             	test   $0x3,%cl
f01033c7:	75 0a                	jne    f01033d3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01033c9:	c1 e9 02             	shr    $0x2,%ecx
f01033cc:	89 c7                	mov    %eax,%edi
f01033ce:	fc                   	cld    
f01033cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01033d1:	eb 05                	jmp    f01033d8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01033d3:	89 c7                	mov    %eax,%edi
f01033d5:	fc                   	cld    
f01033d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01033d8:	5e                   	pop    %esi
f01033d9:	5f                   	pop    %edi
f01033da:	5d                   	pop    %ebp
f01033db:	c3                   	ret    

f01033dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01033dc:	55                   	push   %ebp
f01033dd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01033df:	ff 75 10             	pushl  0x10(%ebp)
f01033e2:	ff 75 0c             	pushl  0xc(%ebp)
f01033e5:	ff 75 08             	pushl  0x8(%ebp)
f01033e8:	e8 87 ff ff ff       	call   f0103374 <memmove>
}
f01033ed:	c9                   	leave  
f01033ee:	c3                   	ret    

f01033ef <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01033ef:	55                   	push   %ebp
f01033f0:	89 e5                	mov    %esp,%ebp
f01033f2:	56                   	push   %esi
f01033f3:	53                   	push   %ebx
f01033f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033fa:	89 c6                	mov    %eax,%esi
f01033fc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033ff:	eb 1a                	jmp    f010341b <memcmp+0x2c>
		if (*s1 != *s2)
f0103401:	0f b6 08             	movzbl (%eax),%ecx
f0103404:	0f b6 1a             	movzbl (%edx),%ebx
f0103407:	38 d9                	cmp    %bl,%cl
f0103409:	74 0a                	je     f0103415 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010340b:	0f b6 c1             	movzbl %cl,%eax
f010340e:	0f b6 db             	movzbl %bl,%ebx
f0103411:	29 d8                	sub    %ebx,%eax
f0103413:	eb 0f                	jmp    f0103424 <memcmp+0x35>
		s1++, s2++;
f0103415:	83 c0 01             	add    $0x1,%eax
f0103418:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010341b:	39 f0                	cmp    %esi,%eax
f010341d:	75 e2                	jne    f0103401 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010341f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103424:	5b                   	pop    %ebx
f0103425:	5e                   	pop    %esi
f0103426:	5d                   	pop    %ebp
f0103427:	c3                   	ret    

f0103428 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103428:	55                   	push   %ebp
f0103429:	89 e5                	mov    %esp,%ebp
f010342b:	53                   	push   %ebx
f010342c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010342f:	89 c1                	mov    %eax,%ecx
f0103431:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103434:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103438:	eb 0a                	jmp    f0103444 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010343a:	0f b6 10             	movzbl (%eax),%edx
f010343d:	39 da                	cmp    %ebx,%edx
f010343f:	74 07                	je     f0103448 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103441:	83 c0 01             	add    $0x1,%eax
f0103444:	39 c8                	cmp    %ecx,%eax
f0103446:	72 f2                	jb     f010343a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103448:	5b                   	pop    %ebx
f0103449:	5d                   	pop    %ebp
f010344a:	c3                   	ret    

f010344b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010344b:	55                   	push   %ebp
f010344c:	89 e5                	mov    %esp,%ebp
f010344e:	57                   	push   %edi
f010344f:	56                   	push   %esi
f0103450:	53                   	push   %ebx
f0103451:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103454:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103457:	eb 03                	jmp    f010345c <strtol+0x11>
		s++;
f0103459:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010345c:	0f b6 01             	movzbl (%ecx),%eax
f010345f:	3c 20                	cmp    $0x20,%al
f0103461:	74 f6                	je     f0103459 <strtol+0xe>
f0103463:	3c 09                	cmp    $0x9,%al
f0103465:	74 f2                	je     f0103459 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103467:	3c 2b                	cmp    $0x2b,%al
f0103469:	75 0a                	jne    f0103475 <strtol+0x2a>
		s++;
f010346b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010346e:	bf 00 00 00 00       	mov    $0x0,%edi
f0103473:	eb 11                	jmp    f0103486 <strtol+0x3b>
f0103475:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010347a:	3c 2d                	cmp    $0x2d,%al
f010347c:	75 08                	jne    f0103486 <strtol+0x3b>
		s++, neg = 1;
f010347e:	83 c1 01             	add    $0x1,%ecx
f0103481:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103486:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010348c:	75 15                	jne    f01034a3 <strtol+0x58>
f010348e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103491:	75 10                	jne    f01034a3 <strtol+0x58>
f0103493:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103497:	75 7c                	jne    f0103515 <strtol+0xca>
		s += 2, base = 16;
f0103499:	83 c1 02             	add    $0x2,%ecx
f010349c:	bb 10 00 00 00       	mov    $0x10,%ebx
f01034a1:	eb 16                	jmp    f01034b9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01034a3:	85 db                	test   %ebx,%ebx
f01034a5:	75 12                	jne    f01034b9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01034a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034ac:	80 39 30             	cmpb   $0x30,(%ecx)
f01034af:	75 08                	jne    f01034b9 <strtol+0x6e>
		s++, base = 8;
f01034b1:	83 c1 01             	add    $0x1,%ecx
f01034b4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01034b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01034be:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01034c1:	0f b6 11             	movzbl (%ecx),%edx
f01034c4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01034c7:	89 f3                	mov    %esi,%ebx
f01034c9:	80 fb 09             	cmp    $0x9,%bl
f01034cc:	77 08                	ja     f01034d6 <strtol+0x8b>
			dig = *s - '0';
f01034ce:	0f be d2             	movsbl %dl,%edx
f01034d1:	83 ea 30             	sub    $0x30,%edx
f01034d4:	eb 22                	jmp    f01034f8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01034d6:	8d 72 9f             	lea    -0x61(%edx),%esi
f01034d9:	89 f3                	mov    %esi,%ebx
f01034db:	80 fb 19             	cmp    $0x19,%bl
f01034de:	77 08                	ja     f01034e8 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01034e0:	0f be d2             	movsbl %dl,%edx
f01034e3:	83 ea 57             	sub    $0x57,%edx
f01034e6:	eb 10                	jmp    f01034f8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01034e8:	8d 72 bf             	lea    -0x41(%edx),%esi
f01034eb:	89 f3                	mov    %esi,%ebx
f01034ed:	80 fb 19             	cmp    $0x19,%bl
f01034f0:	77 16                	ja     f0103508 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01034f2:	0f be d2             	movsbl %dl,%edx
f01034f5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01034f8:	3b 55 10             	cmp    0x10(%ebp),%edx
f01034fb:	7d 0b                	jge    f0103508 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01034fd:	83 c1 01             	add    $0x1,%ecx
f0103500:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103504:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103506:	eb b9                	jmp    f01034c1 <strtol+0x76>

	if (endptr)
f0103508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010350c:	74 0d                	je     f010351b <strtol+0xd0>
		*endptr = (char *) s;
f010350e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103511:	89 0e                	mov    %ecx,(%esi)
f0103513:	eb 06                	jmp    f010351b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103515:	85 db                	test   %ebx,%ebx
f0103517:	74 98                	je     f01034b1 <strtol+0x66>
f0103519:	eb 9e                	jmp    f01034b9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010351b:	89 c2                	mov    %eax,%edx
f010351d:	f7 da                	neg    %edx
f010351f:	85 ff                	test   %edi,%edi
f0103521:	0f 45 c2             	cmovne %edx,%eax
}
f0103524:	5b                   	pop    %ebx
f0103525:	5e                   	pop    %esi
f0103526:	5f                   	pop    %edi
f0103527:	5d                   	pop    %ebp
f0103528:	c3                   	ret    
f0103529:	66 90                	xchg   %ax,%ax
f010352b:	66 90                	xchg   %ax,%ax
f010352d:	66 90                	xchg   %ax,%ax
f010352f:	90                   	nop

f0103530 <__udivdi3>:
f0103530:	55                   	push   %ebp
f0103531:	57                   	push   %edi
f0103532:	56                   	push   %esi
f0103533:	53                   	push   %ebx
f0103534:	83 ec 1c             	sub    $0x1c,%esp
f0103537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010353b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010353f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103543:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103547:	85 f6                	test   %esi,%esi
f0103549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010354d:	89 ca                	mov    %ecx,%edx
f010354f:	89 f8                	mov    %edi,%eax
f0103551:	75 3d                	jne    f0103590 <__udivdi3+0x60>
f0103553:	39 cf                	cmp    %ecx,%edi
f0103555:	0f 87 c5 00 00 00    	ja     f0103620 <__udivdi3+0xf0>
f010355b:	85 ff                	test   %edi,%edi
f010355d:	89 fd                	mov    %edi,%ebp
f010355f:	75 0b                	jne    f010356c <__udivdi3+0x3c>
f0103561:	b8 01 00 00 00       	mov    $0x1,%eax
f0103566:	31 d2                	xor    %edx,%edx
f0103568:	f7 f7                	div    %edi
f010356a:	89 c5                	mov    %eax,%ebp
f010356c:	89 c8                	mov    %ecx,%eax
f010356e:	31 d2                	xor    %edx,%edx
f0103570:	f7 f5                	div    %ebp
f0103572:	89 c1                	mov    %eax,%ecx
f0103574:	89 d8                	mov    %ebx,%eax
f0103576:	89 cf                	mov    %ecx,%edi
f0103578:	f7 f5                	div    %ebp
f010357a:	89 c3                	mov    %eax,%ebx
f010357c:	89 d8                	mov    %ebx,%eax
f010357e:	89 fa                	mov    %edi,%edx
f0103580:	83 c4 1c             	add    $0x1c,%esp
f0103583:	5b                   	pop    %ebx
f0103584:	5e                   	pop    %esi
f0103585:	5f                   	pop    %edi
f0103586:	5d                   	pop    %ebp
f0103587:	c3                   	ret    
f0103588:	90                   	nop
f0103589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103590:	39 ce                	cmp    %ecx,%esi
f0103592:	77 74                	ja     f0103608 <__udivdi3+0xd8>
f0103594:	0f bd fe             	bsr    %esi,%edi
f0103597:	83 f7 1f             	xor    $0x1f,%edi
f010359a:	0f 84 98 00 00 00    	je     f0103638 <__udivdi3+0x108>
f01035a0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01035a5:	89 f9                	mov    %edi,%ecx
f01035a7:	89 c5                	mov    %eax,%ebp
f01035a9:	29 fb                	sub    %edi,%ebx
f01035ab:	d3 e6                	shl    %cl,%esi
f01035ad:	89 d9                	mov    %ebx,%ecx
f01035af:	d3 ed                	shr    %cl,%ebp
f01035b1:	89 f9                	mov    %edi,%ecx
f01035b3:	d3 e0                	shl    %cl,%eax
f01035b5:	09 ee                	or     %ebp,%esi
f01035b7:	89 d9                	mov    %ebx,%ecx
f01035b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035bd:	89 d5                	mov    %edx,%ebp
f01035bf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01035c3:	d3 ed                	shr    %cl,%ebp
f01035c5:	89 f9                	mov    %edi,%ecx
f01035c7:	d3 e2                	shl    %cl,%edx
f01035c9:	89 d9                	mov    %ebx,%ecx
f01035cb:	d3 e8                	shr    %cl,%eax
f01035cd:	09 c2                	or     %eax,%edx
f01035cf:	89 d0                	mov    %edx,%eax
f01035d1:	89 ea                	mov    %ebp,%edx
f01035d3:	f7 f6                	div    %esi
f01035d5:	89 d5                	mov    %edx,%ebp
f01035d7:	89 c3                	mov    %eax,%ebx
f01035d9:	f7 64 24 0c          	mull   0xc(%esp)
f01035dd:	39 d5                	cmp    %edx,%ebp
f01035df:	72 10                	jb     f01035f1 <__udivdi3+0xc1>
f01035e1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01035e5:	89 f9                	mov    %edi,%ecx
f01035e7:	d3 e6                	shl    %cl,%esi
f01035e9:	39 c6                	cmp    %eax,%esi
f01035eb:	73 07                	jae    f01035f4 <__udivdi3+0xc4>
f01035ed:	39 d5                	cmp    %edx,%ebp
f01035ef:	75 03                	jne    f01035f4 <__udivdi3+0xc4>
f01035f1:	83 eb 01             	sub    $0x1,%ebx
f01035f4:	31 ff                	xor    %edi,%edi
f01035f6:	89 d8                	mov    %ebx,%eax
f01035f8:	89 fa                	mov    %edi,%edx
f01035fa:	83 c4 1c             	add    $0x1c,%esp
f01035fd:	5b                   	pop    %ebx
f01035fe:	5e                   	pop    %esi
f01035ff:	5f                   	pop    %edi
f0103600:	5d                   	pop    %ebp
f0103601:	c3                   	ret    
f0103602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103608:	31 ff                	xor    %edi,%edi
f010360a:	31 db                	xor    %ebx,%ebx
f010360c:	89 d8                	mov    %ebx,%eax
f010360e:	89 fa                	mov    %edi,%edx
f0103610:	83 c4 1c             	add    $0x1c,%esp
f0103613:	5b                   	pop    %ebx
f0103614:	5e                   	pop    %esi
f0103615:	5f                   	pop    %edi
f0103616:	5d                   	pop    %ebp
f0103617:	c3                   	ret    
f0103618:	90                   	nop
f0103619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103620:	89 d8                	mov    %ebx,%eax
f0103622:	f7 f7                	div    %edi
f0103624:	31 ff                	xor    %edi,%edi
f0103626:	89 c3                	mov    %eax,%ebx
f0103628:	89 d8                	mov    %ebx,%eax
f010362a:	89 fa                	mov    %edi,%edx
f010362c:	83 c4 1c             	add    $0x1c,%esp
f010362f:	5b                   	pop    %ebx
f0103630:	5e                   	pop    %esi
f0103631:	5f                   	pop    %edi
f0103632:	5d                   	pop    %ebp
f0103633:	c3                   	ret    
f0103634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103638:	39 ce                	cmp    %ecx,%esi
f010363a:	72 0c                	jb     f0103648 <__udivdi3+0x118>
f010363c:	31 db                	xor    %ebx,%ebx
f010363e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103642:	0f 87 34 ff ff ff    	ja     f010357c <__udivdi3+0x4c>
f0103648:	bb 01 00 00 00       	mov    $0x1,%ebx
f010364d:	e9 2a ff ff ff       	jmp    f010357c <__udivdi3+0x4c>
f0103652:	66 90                	xchg   %ax,%ax
f0103654:	66 90                	xchg   %ax,%ax
f0103656:	66 90                	xchg   %ax,%ax
f0103658:	66 90                	xchg   %ax,%ax
f010365a:	66 90                	xchg   %ax,%ax
f010365c:	66 90                	xchg   %ax,%ax
f010365e:	66 90                	xchg   %ax,%ax

f0103660 <__umoddi3>:
f0103660:	55                   	push   %ebp
f0103661:	57                   	push   %edi
f0103662:	56                   	push   %esi
f0103663:	53                   	push   %ebx
f0103664:	83 ec 1c             	sub    $0x1c,%esp
f0103667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010366b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010366f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103673:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103677:	85 d2                	test   %edx,%edx
f0103679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010367d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103681:	89 f3                	mov    %esi,%ebx
f0103683:	89 3c 24             	mov    %edi,(%esp)
f0103686:	89 74 24 04          	mov    %esi,0x4(%esp)
f010368a:	75 1c                	jne    f01036a8 <__umoddi3+0x48>
f010368c:	39 f7                	cmp    %esi,%edi
f010368e:	76 50                	jbe    f01036e0 <__umoddi3+0x80>
f0103690:	89 c8                	mov    %ecx,%eax
f0103692:	89 f2                	mov    %esi,%edx
f0103694:	f7 f7                	div    %edi
f0103696:	89 d0                	mov    %edx,%eax
f0103698:	31 d2                	xor    %edx,%edx
f010369a:	83 c4 1c             	add    $0x1c,%esp
f010369d:	5b                   	pop    %ebx
f010369e:	5e                   	pop    %esi
f010369f:	5f                   	pop    %edi
f01036a0:	5d                   	pop    %ebp
f01036a1:	c3                   	ret    
f01036a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01036a8:	39 f2                	cmp    %esi,%edx
f01036aa:	89 d0                	mov    %edx,%eax
f01036ac:	77 52                	ja     f0103700 <__umoddi3+0xa0>
f01036ae:	0f bd ea             	bsr    %edx,%ebp
f01036b1:	83 f5 1f             	xor    $0x1f,%ebp
f01036b4:	75 5a                	jne    f0103710 <__umoddi3+0xb0>
f01036b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01036ba:	0f 82 e0 00 00 00    	jb     f01037a0 <__umoddi3+0x140>
f01036c0:	39 0c 24             	cmp    %ecx,(%esp)
f01036c3:	0f 86 d7 00 00 00    	jbe    f01037a0 <__umoddi3+0x140>
f01036c9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01036cd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01036d1:	83 c4 1c             	add    $0x1c,%esp
f01036d4:	5b                   	pop    %ebx
f01036d5:	5e                   	pop    %esi
f01036d6:	5f                   	pop    %edi
f01036d7:	5d                   	pop    %ebp
f01036d8:	c3                   	ret    
f01036d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01036e0:	85 ff                	test   %edi,%edi
f01036e2:	89 fd                	mov    %edi,%ebp
f01036e4:	75 0b                	jne    f01036f1 <__umoddi3+0x91>
f01036e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01036eb:	31 d2                	xor    %edx,%edx
f01036ed:	f7 f7                	div    %edi
f01036ef:	89 c5                	mov    %eax,%ebp
f01036f1:	89 f0                	mov    %esi,%eax
f01036f3:	31 d2                	xor    %edx,%edx
f01036f5:	f7 f5                	div    %ebp
f01036f7:	89 c8                	mov    %ecx,%eax
f01036f9:	f7 f5                	div    %ebp
f01036fb:	89 d0                	mov    %edx,%eax
f01036fd:	eb 99                	jmp    f0103698 <__umoddi3+0x38>
f01036ff:	90                   	nop
f0103700:	89 c8                	mov    %ecx,%eax
f0103702:	89 f2                	mov    %esi,%edx
f0103704:	83 c4 1c             	add    $0x1c,%esp
f0103707:	5b                   	pop    %ebx
f0103708:	5e                   	pop    %esi
f0103709:	5f                   	pop    %edi
f010370a:	5d                   	pop    %ebp
f010370b:	c3                   	ret    
f010370c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103710:	8b 34 24             	mov    (%esp),%esi
f0103713:	bf 20 00 00 00       	mov    $0x20,%edi
f0103718:	89 e9                	mov    %ebp,%ecx
f010371a:	29 ef                	sub    %ebp,%edi
f010371c:	d3 e0                	shl    %cl,%eax
f010371e:	89 f9                	mov    %edi,%ecx
f0103720:	89 f2                	mov    %esi,%edx
f0103722:	d3 ea                	shr    %cl,%edx
f0103724:	89 e9                	mov    %ebp,%ecx
f0103726:	09 c2                	or     %eax,%edx
f0103728:	89 d8                	mov    %ebx,%eax
f010372a:	89 14 24             	mov    %edx,(%esp)
f010372d:	89 f2                	mov    %esi,%edx
f010372f:	d3 e2                	shl    %cl,%edx
f0103731:	89 f9                	mov    %edi,%ecx
f0103733:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103737:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010373b:	d3 e8                	shr    %cl,%eax
f010373d:	89 e9                	mov    %ebp,%ecx
f010373f:	89 c6                	mov    %eax,%esi
f0103741:	d3 e3                	shl    %cl,%ebx
f0103743:	89 f9                	mov    %edi,%ecx
f0103745:	89 d0                	mov    %edx,%eax
f0103747:	d3 e8                	shr    %cl,%eax
f0103749:	89 e9                	mov    %ebp,%ecx
f010374b:	09 d8                	or     %ebx,%eax
f010374d:	89 d3                	mov    %edx,%ebx
f010374f:	89 f2                	mov    %esi,%edx
f0103751:	f7 34 24             	divl   (%esp)
f0103754:	89 d6                	mov    %edx,%esi
f0103756:	d3 e3                	shl    %cl,%ebx
f0103758:	f7 64 24 04          	mull   0x4(%esp)
f010375c:	39 d6                	cmp    %edx,%esi
f010375e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103762:	89 d1                	mov    %edx,%ecx
f0103764:	89 c3                	mov    %eax,%ebx
f0103766:	72 08                	jb     f0103770 <__umoddi3+0x110>
f0103768:	75 11                	jne    f010377b <__umoddi3+0x11b>
f010376a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010376e:	73 0b                	jae    f010377b <__umoddi3+0x11b>
f0103770:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103774:	1b 14 24             	sbb    (%esp),%edx
f0103777:	89 d1                	mov    %edx,%ecx
f0103779:	89 c3                	mov    %eax,%ebx
f010377b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010377f:	29 da                	sub    %ebx,%edx
f0103781:	19 ce                	sbb    %ecx,%esi
f0103783:	89 f9                	mov    %edi,%ecx
f0103785:	89 f0                	mov    %esi,%eax
f0103787:	d3 e0                	shl    %cl,%eax
f0103789:	89 e9                	mov    %ebp,%ecx
f010378b:	d3 ea                	shr    %cl,%edx
f010378d:	89 e9                	mov    %ebp,%ecx
f010378f:	d3 ee                	shr    %cl,%esi
f0103791:	09 d0                	or     %edx,%eax
f0103793:	89 f2                	mov    %esi,%edx
f0103795:	83 c4 1c             	add    $0x1c,%esp
f0103798:	5b                   	pop    %ebx
f0103799:	5e                   	pop    %esi
f010379a:	5f                   	pop    %edi
f010379b:	5d                   	pop    %ebp
f010379c:	c3                   	ret    
f010379d:	8d 76 00             	lea    0x0(%esi),%esi
f01037a0:	29 f9                	sub    %edi,%ecx
f01037a2:	19 d6                	sbb    %edx,%esi
f01037a4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01037ac:	e9 18 ff ff ff       	jmp    f01036c9 <__umoddi3+0x69>
