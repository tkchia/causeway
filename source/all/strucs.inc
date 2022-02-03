;------------------------------------------------------------------------------
;
;Some equates to make stacked register access simpler.
;
Int_EDI equ	0
Int_DI	equ	0
Int_ESI equ	4
Int_SI	equ	4
Int_EBP equ	8
Int_BP	equ	8
Int_ESP equ	12
Int_SP	equ	12
Int_EBX equ	16
Int_BX	equ	16
Int_BL	equ	16
Int_BH	equ	17
Int_EDX equ	20
Int_DX	equ	20
Int_DL	equ	20
Int_DH	equ	21
Int_ECX equ	24
Int_CX	equ	24
Int_CL	equ	24
Int_CH	equ	25
Int_EAX equ	28
Int_AX	equ	28
Int_AL	equ	28
Int_AH	equ	29
Int_GS	equ	32
Int_FS	equ	36
Int_ES	equ	40
Int_DS	equ	44
Int_Off equ	48
Int_Seg16	equ	50
Int_Seg32	equ	52
Int_Flags16	equ	52
Int_Flags32	equ	56


ResSize equ	4096		;Size of resource block.
ResHead equ	16		;Size of main header.
ResNum	equ	((((4096-ResHead)/5) >> 2) << 2)	;Number of entries.
ResCount	equ	ResNum-4		;count for free entry checking.

Res_NULL	equ	0	;MUST be zero.
Res_PSP equ	1	;single entry.
Res_SEL equ	2	;single entry.
Res_MEM equ	3	;3 entries.
Res_LOCK	equ	4	;2 entries.
Res_DOSMEM	equ	5	;?
Res_CALLBACK	equ	6	;3 entries.
Res_NOTHING	equ	254
Res_CHAIN	equ	255	;single entry.



MEM_FREE	equ	0	;Free page.
MEM_START	equ	1	;Used page, start of block.
MEM_END equ	2	;Used page, end of block.
MEM_MASK	equ	3
;
MEM_LOCK	equ	4	;Start of lock count.
MEM_LOCK_MASK	equ	15	;4 bit lock count.
MEM_LOCK_SHIFT	equ	2
;
MEM_PHYS	equ	32	;physical mapping.
;
MEM_FILL	equ	(MEM_LOCK_MASK << MEM_LOCK_SHIFT)+MEM_START


;; MED 02/16/96
MaxCallBacks		equ	32+3		;maximum number of call back table entries.
;MaxCallBacks		equ	32+4		;maximum number of call back table entries.

;; MED increased 512 to 1024, 12/05/95
%ifdef BIGSTACK
RawStackDif		equ	5*1024		;size of interrupt stacks.
%else
;RawStackDif		equ	1280		;size of interrupt stacks.
RawStackDif		equ	1024		;size of interrupt stacks.
;RawStackDif		equ	512		;size of interupt stacks.
%endif

%ifdef BIGSTACK
RawStackTotal	equ	(10*RawStackDif)+RawStackDif
%else
;RawStackTotal	equ	8192+512
RawStackTotal	equ	8192+RawStackDif
;RawStackTotal	equ	(16*RawStackDif)+RawStackDif
%endif

tPL2StackSize	equ	4		;other priveledge level stacks. never used.
tPL1StackSize	equ	4
tPL0StackSize	equ	256		;Interupt catcher stack.


GDTNul		equ	00h			;Null entry.
;
VCPI_0		equ	08h			;blank entries for VCPI to fill in.
VCPI_1		equ	10h			;/
VCPI_2		equ	18h			;/
;
KernalTS		equ	20h+3			;Kernal TSS
KernalCS0		equ	28h			;Kernal PL0 code seg.
KernalPL0		equ	30h			;PL0 stack.
KernalSwitchPL0 equ	38h			;Mode switch PL0 stack.
Kernal40h		equ	40h+3			;DOS/BIOS data area access.
KernalPL3_2_PL0 equ	48h+3			;PL3 to PL0 call gate.
;
KernalLDT		equ	50h+3
KernalCS		equ	58h+3			;Kernal CS
KernalDS		equ	60h+3			;Kernal DS
KernalSS		equ	68h+3			;Kernal SS
KernalZero		equ	70h+3			;Kernal 0-4G data referance.
;
MainCS		equ	78h+3			;Main code seg.
MainDS		equ	80h+3			;Main data seg.
MainSS		equ	88h+3			;Main stack seg.
MainPSP		equ	90h+3			;PSP segment.
MainEnv		equ	98h+3			;Enviroment segment.
;
InitCS		equ	0a0h+3		;Init code seg.
InitCS0		equ	0a8h			;Init code seg at PL0.
InitDS		equ	0b0h+3		;Init data seg.
InitPL3_2_PL0	equ	0b8h+3
;
DpmiEmuCS		equ	0c0h+3		;DPMI emulator code seg.
DpmiEmuCS0		equ	0c8h			;DPMI emulator code seg at PL0.
DpmiEmuDS		equ	0d0h+3		;DPMI emulator data seg.
DpmiEmuPL3_2_PL0	equ	0d8h+3
;
GDTData		equ	0e0h+3
;
GDT_Entries		equ	0f0h/8		;GDT entries to allocate.
;
KernalB000		equ	0b000h+3
KernalB800		equ	0b800h+3
KernalA000		equ	0a000h+3

;
struc	CallBackStruc
CallBackFlags	resb 1
CallBackNum		resb 1
CallBackOff		resw 1
CallBackProt		resw 3
CallBackRegs		resw 3
CallBackReal		resd 1
CallBackStackSel	resw 1
		resw 1
endstruc
;
struc	Desc
Limit		resw 1		;Offset of last byte.
Base_l		resw 1		;Low 16 bits of 32-bit address.
Base_m		resb 1		;Bits 16-23 of base.
Access		resb 1		;Access privaledge level.
Gran		resb 1		;Granularity and limit.
Base_H		resb 1		;bits 24-31 of base.
endstruc

DescPresent		equ	1 << 7 ;Segment is present.
Desc32Bit		equ	1 << 6 ;Segment is 32 bit (not 16!).
DescAvailable	equ	1 << 4 ;Available for our use.
;
DescPL0		equ	0 << 5 ;PL0
DescPL1		equ	1 << 5 ;PL1
DescPL2		equ	2 << 5 ;PL2
DescPL3		equ	3 << 5 ;PL3
;
DescMemory		equ	1 << 4 ;Segment is memory (not system gate etc.)
;
DescRData		equ	0	;Read only data segment. (eg, ROM)
DescRWData		equ	2	;Read/Write data.
DescRDataDown	equ	4	;Read only expand down data segment.
DescRWDataDown	equ	6	;Read/write expand down data segment.
DescECode		equ	8	;Execute only code.
DescERCode		equ	10	;Execute/read code.
DescECCode		equ	12	;Execute only conforming code.
DescERCCode		equ	14	;Execute/read conforming code.
;
Desc286Tss		equ	1	;Available 286 TSS.
DescLDT		equ	2	;LDT.
Desc286TssB		equ	3	;Busy 286 TSS.
Desc286Call		equ	4	;286 call gate.
DescTssGate		equ	5	;TSS gate.
Desc286Int		equ	6	;286 interupt gate.
Desc286Trap		equ	7	;286 trap gate.
Desc386Tss		equ	9	;Available 386 TSS.
Desc386TssB		equ	11	;Busy 386 TSS.
Desc386Call		equ	12	;386 call gate.
Desc386Int		equ	14	;386 interupt gate.
Desc386Trap		equ	15	;386 trap gate.


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
struc	v86CallStruc
v86CallEDI		resd 1
v86CallESI		resd 1
v86CallEBP		resd 1
		resd 1
v86CallEBX		resd 1
v86CallEDX		resd 1
v86CallECX		resd 1
v86CallEAX		resd 1
v86CallFlags		resw 1
v86CallES		resw 1
v86CallDS		resw 1
v86CallFS		resw 1
v86CallGS		resw 1
v86CallIP		resw 1
v86CallCS		resw 1
v86CallSP		resw 1
v86CallSS		resw 1
endstruc
;


;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
struc	TSSFields
;
;Task segment structure.
;
Back		resw 1		;Back link to any previous TSS.
		resw 1		;Reserved.
ESP0		resd 1		;SP for level 0 interupt.
SS0		resw 1
		resw 1		;reserved.
ESP1		resd 1		;Level 1 interupt handlers stack.
SS1		resw 1
		resw 1		;reserved.
ESP2		resd 1		;Level 2 interupt handlers stack.
SS2		resw 1
		resw 1		;reserved.
tCR3		resd 1		;CR3 value.
tEIP		resd 1		;Instruction pointer.
tEFlags		resw 1		;EFlags.
		resw 1
tEAX		resd 1		;AX for init.
tECX		resd 1		;CX for init.
tEDX		resd 1		;DX for init.
tEBX		resd 1
tESP		resd 1
tEBP		resd 1
tESI		resd 1
tEDI		resd 1
tES		resw 1
		resw 1		;reserved.
tCS		resw 1
		resw 1		;reserved.
tSS		resw 1
		resw 1		;reserved.
tDS		resw 1
		resw 1		;reserved.
tFS		resw 1
		resw 1		;reserved.
tGS		resw 1
		resw 1		;reserved.
tLDT		resw 1
		resw 1		;reserved.
		resw 1		;reserved.
IOMap		resw 1		;displacement to I/O map.
;
tPL3Stack		resb tPL2StackSize
tPL2Stack		resb tPL1StackSize

tPL1Stack		resb tPL0StackSize

tPL0Stack		resw 1
endstruc

struc	NewHeaderStruc
NewID		db '3P' ;'3P' identifier.
NewSize		resd 1		;byte size of 3P section of file.
NewLength		resd 1		;byte size of exe image data.
NewAlloc		resd 1		;byte size of program.
NewSegments		resw 1		;number of segment definitions.
NewRelocs		resd 1		;number of relocation table entries.
NewEntryEIP		resd 1		;entry offset.
NewEntryCS		resw 1		;segment list entry number for entry CS.
NewEntryESP		resd 1		;ESP offset.
NewEntrySS		resw 1		;segment list entry number for SS.
NewFlags		resd 1		;Control flags.
NewAutoStack		resd 1		;Auto stack size.
NewAutoDS		resw 1		;Auto DS segment number +1
NewExports		resd 1		;Length of EXPORT section.
NewImports		resd 1		;Length of IMPORT section.
NewImportModCnt resd 1		;Number of IMPORT modules.
NewReserved		resb 10
endstruc
;


struc	PSP_Struc
;
;First the standard DOS PSP structure. Won't use any of existing entries for
;extended info incase currently un-used entries get used at a later data.
;
 PSP_INT20		resw 1		;INT 20 instruction for CP/M CALL 0 program
				;termination the CDh 20h here is often used as a
				;signature for a valid PSP
 PSP_MemTop		resw 1		;segment of first byte beyond memory allocated to
				;program. N/A
 PSP_Filler1		resb 1		;unused filler

 PSP_CPM		resb 1		;CP/M CALL 5 service request (FAR JMP to 000C0h)
				;BUG: (DOS 2+) PSPs created by INT 21/AH=4Bh
				;point at 000BEh
		resw 1		;CP/M compatibility--size of first segment for
				;.COM files
		resw 1		;remainder of FAR JMP at 05h
 PSP_INT22		resd 1		;stored INT 22 termination address
 PSP_INT23		resd 1		;stored INT 23 control-Break handler address
 PSP_INT24		resd 1		;DOS 1.1+ stored INT 24 critical error handler
				;address
 PSP_Parent		resw 1		;segment of parent PSP
 PSP_HandleList resb 20		;DOS 2+ Job File Table, one byte per file
				;handle, FFh = closed
 PSP_Environment	resw 1		;segment of environment for process
 PSP_INT21SSSP	resd 1		;N/A
 PSP_Handles		resw 1		;DOS 3+ number of entries in JFT (default 20)
 PSP_HandlePtr	resd 1		;DOS 3+ pointer to JFT (default PSP:0018h)
 PSP_Previous	resd 1		;DOS 3+ pointer to previous PSP (default
				;FFFFFFFFh in 3.x) used by SHARE in DOS 3.3.
 PSP_Filler2		resd 1		;unused by DOS versions <= 6.00
				;reportedly used by Novell NetWare shell 3.x
 PSP_DOSVersion resw 1		;DOS 5+ version to return on INT 21/AH=30h
 PSP_NextPSP		resw 1		;(MSWin3) selector of next PSP (PDB) in linked
				;list Windows keeps a linked list of Windows
				;programs only
 PSP_Filler3		resd 1		;unused by DOS versions <= 6.00
 PSP_WinOldAp	resb 1		;(MSWindows3) bit 0 set if non-Windows
				;application (WINOLDAP)
 PSP_Filler4		resb 7 ;unused by DOS versions <= 6.00
 PSP_INT21		resb 3 ;DOS 2+ service request (INT 21/RETF instructions)
 PSP_Filler5		resb 9 ;unused in DOS versions <= 6.00
 PSP_FCB1		resb 16 ;first default FCB, filled in from first
				;commandline argument overwrites second FCB if
				;opened
 PSP_FCB2		resb 16 ;second default FCB, filled in from second
				;commandline argument overwrites beginning of
				;commandline if opened
 PSP_Filler6		resd 1		;unused
 PSP_CommandTail	resb 128 ;commandline / default DTA
				;command tail is BYTE for length of tail, N BYTEs
				;for the tail, followed by a BYTE containing 0Dh
endstruc


LE_OBJ_Flags_Read	equ 1	;Readable.
LE_OBJ_Flags_Write	equ 2	;Writeable.
LE_OBJ_Flags_Exec	equ 4	;Executable.
LE_OBJ_Flags_Res	equ 8	;Resource.
LE_OBJ_Flags_Discard	equ 16	;Discardable.
LE_OBJ_Flags_Shared	equ 32	;Shared.
LE_OBJ_Flags_PreLoad	equ 64	;Preload.
LE_OBJ_Flags_Invalid	equ 128 ;Invalid.
LE_OBJ_Flags_FillMsk	equ 256+512	;Mask for fill type bits.
LE_OBJ_Flags_Normal	equ 0	;Normal fill type.
LE_OBJ_Flags_Zero	equ 256 ;Zero filled.
LE_OBJ_Flags_Res1	equ 512 ;resident.
LE_OBJ_Flags_Res2	equ 256+512	;resident/contiguous.
LE_OBJ_Flags_LongLoc	equ 1024	;long lockable.
LE_OBJ_Flags_16Alias	equ 4096	;16:16_ALIAS
LE_OBJ_Flags_Big	equ 8192	;"BIG" (Huge: 32-bit)
LE_OBJ_Flags_Conform	equ 16384	;Conforming.
LE_OBJ_Flags_IOPriv	equ 32768	;"OBJECT_I/O_PRIVILEGE_LEVEL

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;
;LE header format.
;
struc	LE_Header
LE_ID		resw 1	;"LE" text identifier.
LE_ByteOrder		resb 1	;byte order, 0=little-endian, none-zero=big.
LE_WordOrder		resb 1	;word order.
LE_Format		resd 1	;format level.
;
LE_CPU		resw 1	;CPU type.
LE_CPU_286		equ 1
LE_CPU_386		equ 2
LE_CPU_486		equ 3
LE_CPU_586		equ 4
LE_CPU_i860		equ 20h
LE_CPU_N11		equ 21h
LE_CPU_R2000		equ 40h
LE_CPU_R6000		equ 41h
LE_CPU_R4000		equ 42h
;
LE_OS		resw 1	;Target operating system.
LE_OS_OS2		equ 1
LE_OS_Windows		equ 2
LE_OS_DOS4		equ 3
LE_OS_Win386		equ 4
;
LE_Version		resd 1	;Module version.
;
LE_Type		resd 1	;Module type.
LE_Type_InitPer equ 1 << 2	;initialise per process.
LE_Type_IntFixup	equ 1 << 4	;no internal fixups.
LE_Type_ExtFixup	equ 1 << 5	;no external fixups.
LE_Type_NoLoad		equ 1 << 13	;module not loadable.
LE_Type_DLL		equ 1 << 15	;DLL
;
LE_Pages		resd 1	;number of memory pages.
LE_EntryCS		resd 1	;Entry CS object.
LE_EntryEIP		resd 1	;Entry EIP.
LE_EntrySS		resd 1	;Entry SS object.
LE_EntryESP		resd 1	;Entry ESP.
LE_PageSize		resd 1	;Page size.
LE_LastBytes		resd 1	;Bytes on last page.
LE_FixupSize		resd 1	;fixup section size.
LE_FixupChk		resd 1	;fixup section check sum.
LE_LoaderSize		resd 1	;loader section size.
LE_LoaderChk		resd 1	;loader section check sum.
LE_ObjOffset		resd 1	;offset of object table.
LE_ObjNum		resd 1	;object table entries
LE_PageMap		resd 1	;object page map table offset.
LE_IterateMap		resd 1	;object iterate data map offset.
LE_Resource		resd 1	;resource table offset
LE_ResourceNum		resd 1	;resource table entries.
LE_ResidentNames	resd 1	;resident names table offset.
LE_EntryTable		resd 1	;entry table offset.
LE_Directives		resd 1	;module directives table offset.
LE_DirectivesNum	resd 1	;module directives entries.
LE_Fixups		resd 1	;fixup page table offset.
LE_FixupsRec		resd 1	;fixup record table offset.
LE_ImportModNames	resd 1	;imported module name table offset.
LE_ImportModNum resd 1	;imported modules count.
LE_ImportNames		resd 1	;imported procedures name table offset.
LE_PageChk		resd 1	;per-page checksum table offset.
LE_Data		resd 1	;data pages offset.
LE_PreLoadNum		resd 1	;pre-load page count.
LE_NoneRes		resd 1	;non-resident names table offset.
LE_NoneResSize		resd 1	;non-resident names table length.
LE_NoneResChk		resd 1	;non-resident names checksum.
LE_AutoDS		resd 1	;automatic data object.
LE_Debug		resd 1	;debug information offset.
LE_DebugSize		resd 1	;debug information size.
LE_PreLoadInstNum	resd 1	;pre-load instance pages number.
LE_DemandInstNum	resd 1	;demand instance pages number.
LE_HeapExtra		resd 1	;extra heap alloction.
LE_Reserved		db 20 dup (?) ;reserved.
LE_DeviceID		resw 1	;device ID (Windows VxD only).
LE_DDK		resw 1	;DDK version number.
endstruc
