**NOTE! This is a work in progress and may change**

Here are writeups and sources for some of my demos and intros. For now
there are only small intros here (up to 256 bytes).

The writeups + sources are also available at [github](https://github.com/neonz80/Writeups/).

## Lovebyte 2025
- [Channel 36 (ZX Spectrum, 16 bytes)](channel_36/)
- [A Visual Journey from CP to LD (ZX Spectrum, 16 bytes)](a_visual_journey_from_cp_to_ld/)
- [A Prison for Your Mind (ZX Spectrum, 32 bytes)](a_prison_for_your_mind/)
- [Lovebyte Partyscroller (ZX Spectrum, 64 bytes)](lovebyte_partyscroller/)
- [Aurora Borealis (ZX Spectrum, 128 bytes)](aurora_borealis/)

## Notes

I'm using SDCC (mostly just the included assembler) and my own linker
for Z80 development. This is not the most common assembler for
democoding. To make these writeups a bit more accessible, all sources
have been rewritten to work with
[sjasmplus](https://github.com/z00m128/sjasmplus).

For each demo there is a Makefile that works with GNU Make. Python 3
is used to create the tap files. If you want to build a demo on
Windows, either install GNU Make or run sjasmplus manually.
