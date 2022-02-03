%define	b	byte
%define	w	word
%define	d	dword
%define	f

%macro	Pushm	1-*
	%rep	%0
	push	%1
	%rotate	1
	%endrep
%endmacro

%macro	Popm	1-*
	%rep	%0
	%rotate	-1
	pop	%1
	%endrep
%endmacro

%macro	Rep_movs 0
	push	ecx
	shr	ecx,1
	push	ecx
	shr	ecx,1
	rep	movsd
	pop	ecx
	and	ecx,1
	rep	movsw
	pop	ecx
	and	ecx,1
	rep	movsb
%endmacro

%macro	Rep_stos 0
	push	ecx
	shr	ecx,1
	push	ecx
	shr	ecx,1
	rep	stosd
	pop	ecx
	and	ecx,1
	rep	stosw
	pop	ecx
	and	ecx,1
	rep	stosb
%endmacro
