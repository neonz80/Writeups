<h1 align="center">A Visual Journey from CP to LD</h1>

<p align="center"><img src="media/a_visual_journey_from_cp_to_ld-screenshot.png"></p>

<p align="center">A 16 byte intro for the ZX Spectrum released at Lovebyte 2025.</p>

<p align="center">
• <a href="https://darkside.no/zx/darklite-a_visual_journey_from_cp_to_ld.zip">Release</a>
• <a href="https://youtu.be/N42H2eTo7gM">Video</a>
• <a href="https://github.com/neonz80/Writeups/tree/main/a_visual_journey_from_cp_to_ld/src/">Source</a>
•</p>

## Introduction

This intro was an experiment to see what could be done with self
modifying code in a tiny intro. Self modifying code is a quite common
technique on the Z80 and I'm using it all the time to speed up
code. In most cases I use it to modify immediate values, basically
storing variables directly in the code.

In this intro however, I wanted to write some kind of loop that
manipulated a value with one or more instructions and wrote the value
to the screen. What would happen if one of these instructions was
changed over time?

## Choosing instructions

A tiny way to change an instruction is to let `hl` point to the
instruction and then use `inc (hl)` or `dec (hl)` to change it. The
opcode range from 0x78 to 0xbf turns out to contain instruction that
only modify the accumulator and/or the flags. These instructions are
`ld a, X`, `add X`, `adc X`, `sub X`, `sbc X`, `and X`, `xor X`, `or
X` and `cp X`. `X` is `b`, `c`, `d`, `e`, `h`, `l`, `(hl)` and `a`.

## The code

Here is a breakdown of the source code. See [here](src/journey.asm)
for the full source.


```
        ORG 0xbf14
```

This is the start address of the intro. The significance of this will
be explained below.

```
        di
```

The intro will write to the memory from 0x4000 to 0x7fff and since
some of this memory is used by the ROM interrupt handler, I figured it
was a good idea to disable interrupts. This is probably not needed but
I somehow left this in.

```
        db      0x21
```

0x21 is the opcode for `ld hl, immediate`. The next two bytes contains
the immediate value to load (in little endian). To save bytes, these
two bytes are reused as instructions in the loop.

```
loop:
        rla
        cp      a
```

This is the start of the loop in the intro. The opcodes for these two
bytes are 0x17 0xbf. At startup, the `ld hl, immediate` above will
load 0xbf17 into hl instead of executing these two bytes. Since the
program is loaded at 0xbf14, 0xbf17 is the address of the `cp a`
instruction.

For the rest of the program, these instructions modifies the accumulator
and the carry flag. The `cp a` instruction is the instruction
that will be modified.

The accumulator and the carry flag are not modified by any other
instructions.

```
        inc     d
        res     7, d
        ld      (de), a
        inc     e
```

This writes the `a` register to memory address in `de`. `res 7, d`
makes sure that `de` stays within 0x0000 to 0x7fff. `inc d` and `inc
e` increments the high and low bytes of `de`. 

```
        djnz    loop
```

This will run the inner loop 256 times (except for the first iteration
where `b` is 0xbf).

```
        inc     e
        jr      nz, loop
```

After the inner loop, `e` is incremented and then the code jumps back
to run the inner loop as long as `e` is not zero. `e` is modified in
the inner loop as well, but since that loop runs 256 times the end
result this loop also will run 256 times. 



```
        dec     (hl)
        jp      (hl)
```

After 256*256 iterations of the inner loops, the `cp a` (0xbf)
instruction is decremented by `dec (hl)`, ending up as `cp (hl)`
(0xbe). The code then jumps to the modified instruction. The `rla` is
skipped, but this is not important.

### Stopping

The intro runs until the modified instruction changes to 0x77, or `ld
(hl), a`. This will overwrite the instruction again with the current
value of `a` which is 0x01. This value is the opcode for `ld bc,
immediate`, a 3 byte instruction. The `inc d` instruction and the
prefix of the `res 7, d` instruction will therefore never be executed
and the inner loop now looks like this:

```
loop:
        rla
        ld      bc, 0xcb14
        cp      d
        ld      (de), a
        inc     e
        djnz    loop
```

This code will run forever since `b` never reaches zero. `de` points
to the rom so the screen will not change.

## Final words

When writing this intro I tried several different ways to modify `a`
and different ways of iterating through memory. In the end it was this
version that ended up looking "best". 

I also tried incrementing instead of decrementing the
instruction. This basically reverses the patterns shown but will crash
at the end since instruction 0xc0 is `ret nz`. 
