# NES Starter Kit
This is a starter kit for developing Nintendo Entertainment System games using 6502 Assembly language.  I've included both code and tools for getting started in your adventure creating NES games for emulators or even cartridges.  I will be stepping through this code in tutorials on youtube as well as in this readme.  We will be using the [CA65 Assembler](https://www.cc65.org/index.php#Download) to assemble our program into the iNES Rom format.

[More NES Tutorials](https://www.embed.com/nes)

## NES Architecture
![alt text](https://github.com/battlelinegames/nes-starter-kit/blob/master/img/NES-Architecture.png?raw=true "NES Architecture")
The NES uses a variant of the 6502 processor as it's CPU.  If you'd like to write code for the NES I'd highly recommend learning 6502 assembly language.  The NES also has a PPU (Picture Processing Unit).  The PPU was a kind of early stage GPU (graphics processing unit) which was capable of drawing images to the screen based on what was in the PPU's memory.  The NES had no operating system, so early NES cartridges had 2 ROM chips in them.  An 8K CHR ROM which contained all of the sprite and background image data using 2 bits per pixel.  There was also a 32K PRG ROM wich contained all of the program data your game would run.  Those ROM Chips were wired directly into the system's memory space.  When we write a game using an emulator, we mimic this memory arrangement.  

## 6502 CPU
### Actually a 2A03 CPU variant of the 6502 processor
![alt text](https://github.com/battlelinegames/nes-starter-kit/blob/master/img/6502.png?raw=true)
The 6502 was a popular CPU in the late 1970s and early 1980s for home systems and video games because it was cheap.  It was used for several Atari systems including the 2600, by Commodore for the C64, and Apple for the Apple II.  

### The 6502 is slow
Programming with assembly languge can be quite time intensive.  It takes many lines of code to do things that could be accomplished in a few lines of javascript.  But by today's standards a 6502 is shockingly slow.  It ran at 1.7Mhz (Million Cycles / Second).  That may sound like a lot, but if you are trying to draw 60 frames per second, you have to divide 1700000 / 60 giving you about 28,000 or so cycles to draw a frame.  On top of that there are no instructions that take less than 2 cycles, and most take many more.  What it boils down to is you have a few thousand lines of assembly code to do everything.  On top of that you only have 32,000 bytes to write your code.  (later in the NES lifecycle chips were added into the carts to get around some of these limitations, but I won't be going into mappers here).

### 6502 Assembly has 56 documented commands
Having to learn the 56 Assembly language commands isn't too bad.  
[Here's a link to my favorite 6502 reference](http://www.obelisk.me.uk/6502/reference.html)
From what I can tell, there are 4 categories of commands
* Move data commands (LDA, STA, LDX, TAX)
* Status flag setting commands (CPA, BIT, SEC)
* Math and Logic commands (ADC, SBC, AND)
* Branching Commands (BEQ, JMP, BPL)

6502 Assembly doesn't really have variables.  It just has places in RAM where you can put stuff.  You can assign labels to these memory locations and they kind of act like variables, but these labels are effectively global in scope.  

## Author: Rick Battagline of BattleLine Games LLC.
Significant portions were lifted from            
Brad Smith's (rainwarrior) ca65 example code     

## File: compile.bat                                
This code was taken from rainwarrior's example    
code.  Basically it runs all the ca65 commands    
that build and link your project.  I've also      
included all the ca65 exe files in the cc65       
directory in this project.  It's not necessary to 
put that in every project you build, but I feel   
that it makes things a bit easier when you're     
starting out.                                     


## File: starter.cfg                                                                          
This is the ca65 config file which is used by ca65 to figure out how the output rom binary    
file is going to be arranged.  If you open up an early NES cartridge like Super Mario Bros    
(the original) you'll find it contains 2 ROM chips.  One chip labeled PRG and the other       
labeled CHR.                                                                                  


**CHR** contains the sprite (character) data that gets loaded into the                            
**PPU** (Picture Processing Unit) and is used to draw game graphics.                             
**PRG** contains the program ROM data as well as other constant data that is non graphical.      

The first portion of the file contains the **MEMORY** section.  The lines HDR, PRG, and CHR have 
file = %0 in them.  This tells the assembler that those sections will actually be placed     
inside the game's rom file when assembled.  The three lines ZP, OAM, and RAM have file = ""  
which indicates to the assembler that these parts of memory will be generated at run time and
will not have an area of memory in the ROM file itself.                                      

    MEMORY {                                                                                      
      ZP:     start = $00,    size = $0100, type = rw, file = "";                                 
      OAM:    start = $0200,  size = $0100, type = rw, file = "";                                 
      RAM:    start = $0300,  size = $0500, type = rw, file = "";                                 
      HDR:    start = $0000,  size = $0010, type = ro, file = %O, fill = yes, fillval = $00;      
      PRG:    start = $8000,  size = $8000, type = ro, file = %O, fill = yes, fillval = $00;      
      CHR:    start = $0000,  size = $2000, type = ro, file = %O, fill = yes, fillval = $00;      
    }                                                                                             

The **SEGMENTS** portion of the file will allow you to tell the assembler from the code where in  
memory, or in the rom file you would like your code, or your variables to go.  For instance,
you may have something like this:                                                            


    .segment "ZEROPAGE"                                                                           
      frequently_used_var_1: .res 1                                                               
      frequently_used_var_2: .res 1                                                               
      frequently_used_var_3: .res 1                                                               
                                                                                              
    .segment "VARS"                                                                               
      less_frequently_used_var_1: .res 1                                                          
      less_frequently_used_var_2: .res 1                                                          
                                                                                              
    .segment "CODE"                                                                               
      .proc adding_procedure                                                                      
          lda frequently_used_var_1       ; load frequently_used_var_1 into register a            
          clc                             ; clear the carry flag                                  
          adc frequently_used_var_2       ; add frequently_used_var_2 to register a               
          sta less_frequently_used_var_1  ; store the results in less_frequently_used_var_1       
          rts                                                                                     
      .endproc                                                                                    


The segments we used above have to correspond to segments defined in the .cfg file that point
to parts of memory.  In the **SEGMENTS** section of our config file we create **ZEROPAGE** to point
to the **ZEROPAGE** portion of memory.  This part of memory executes a few cycles faster than the
rest of memory.  The **OAM** portion is used to transfer sprite data to the PPU.  **VARS** can be used
to create variables in memory.  It is slower than the **ZEROPAGE** segment, but there is much more
of it.  The **HEADER** segment is used to create the iNES header that is used by an emulator.  It doesn't
correspond to anything that was on a cartridge.  The **CODE** segment corresponds to a PRG ROM chip on
the cartridge.  You can use this for a place to put assembly code.  **ROMDATA** is pointing at the 
later portion of the PRG ROM.  If you like you can remove this line and use CODE for all of your
constant data, but this gives us a nice way to separate it.  You may want to adjust the start = 
part of that line if you find yourself using more **ROMDATA** than assembly code.  You can use **ROMDATA**
for constant information like level definitions or enemy definitions.  The IMG corresponds to the 
CHR ROM and is where you should put your .chr file.

    SEGMENTS {                                                
        ZEROPAGE: load = ZP,  type = zp;                                             
        OAM:      load = OAM, type = bss, align = $100;                              
        VARS:     load = RAM, type = bss;                                            
        HEADER:   load = HDR, type = ro;                                             
        CODE:     load = PRG, type = ro,  start = $8000;                             
        ROMDATA:  load = PRG, type = ro,  start = $E000;                             
        VECTORS:  load = PRG, type = ro,  start = $FFFA;                             
        IMG:      load = CHR, type = ro;                                             
    }                                                                                


## File: starter.asm     

#### This is the primary orgainizing file for the starter project.                             


This file contains a series of .include directives to include all of the other files we are using in 
this project.  It also contains the main game loop.  For this particular project the game loop won't
be doing anything.  In a typical game, you would want to include all the code that does not directly 
interact with the PPU in this game loop.  Because all we are doing is drawing "HELLO WORLD" to the  
game screen.  You would usually want to process the movement of all of your game objects inside the 
game loop, then move your data to the PPU inside the NMI.

## File: header.asm                                                                           
### Directory: def                                                                            

#### iNES header setup is done here, as well as the vector setup                                   
                                                                                              
This file sets up the first 13 bytes of the .nes file that this project will output.  These bytes
don't correspond to anything that would be on the cartridge.  They are used by an emulator to 
configure the software to know what kind of hardware you're emulating.  

The first 4 bytes are always the same "NES" followed by a hex $1A.  An emulator would first look
at these 4 bytes so it would know that yes, this really is an iNES file.

The fifth byte tells the emulator how many 16K memory banks the program is using.  We have 2 program
banks we are using.  If you want to use more than that, you need what is called a Mapper.  I won't 
be covering those here, so I suggest leaving that number alone.

The sixth byte tells the emulator how many 8K memory banks you are using for image data.  Unfortunately
if you're not using a mapper, this number has to stay at 1.  

The seventh byte contains a bunch of flags and values that are used for more advanced NES game programming.
For this project we are going to leave all of those flags set to 0.

After that we are using six more bytes of padding that were meant for expansion of the iNES format, but
probably will never be used for anything.

At the very end of the header.asm file we set the last 6 bytes of your file.  These bytes are used by 
all 6502 programs to know where to execute three interrupts


    .segment "VECTORS" ; THIS IS THE LAST 6 BYTES OF THE FILE, USED AS ADDRESSES FOR INTERRUPTS
    .word nmi                                                                                  
    .word reset                                                                                
    .word irq                                                                                  


The three .word values point to labels declared in the 3 vector files.  You will find those files
in the vectors directory.  They are nmi.asm, reset.asm, and irq.asm.  I will explain more later

## File: palette.asm                                                                             
### Directory: def                                                                                

#### file that defines the colors associated with each hex value and the default palettes         

At the beginning of this file I define a bunch of hex values with the colors they represent.
The file also defines in **ROMDATA** a palette for the background and a palette for the sprites.

## File: ppu.asm                                                                                 
### Directory: def                                                                               

#### definitions for ppu flags, registers, and helper procedures                                 

The ppu.asm file defines all the PPU registers we will be interacting with as we write our game.  
We've also defined some procedures that interact with the PPU including the following

**load_attribute** - loads the attribute table in the PPU
**load_palettes** - load the sprite and background palettes into the PPU
**oam_dma** - used to move all the sprite data to the PPU

we also define the oam memory block of 256 bytes in this file

## File: gamepad.asm                                                                            
### Directory: lib                                                                               

#### definitions for gamepad flags, gamepad state variables and procedures for determining gamepad state.                                                                                       

I've used this to define several variables that will hold the gamepad buttons that are currently pressed,
newly pressed, and newly released.  I also have a bunch of defines for the button flags like **PRESS_A** 
and **PRESS_START** which you can check with an **AND** or a **BIT** test against **gamepad_press** or **gamepad_new_press**.
The values in these variables are set when you call the **set_gamepad** procedure that should be executed in
the game loop.

## File: hello_world.asm                                                                         
### Directory: lib                                                                               

#### This is the application specific library for your hello world application                   

In this file I create the macro printf_nmi.  This printf doesn't really take variables.  You have
to pass in assembly time constants.  This is basically where the "HELLO WORLD" happens.

## File: utils.asm                                                                              
### Directory: lib                                                                              

#### This file contains utility procedures and macros.                                          

A lot of general use utility macros like wait_for_vblank which just loops until the next vblank hits.
set for instance just sets the first variable to the value in the second.  It basically just does an
lda and an sta because I find myself doing that all the time.


## File: irq.asm                                                                                 
### Directory: vectors                                                                           

#### label used by the irq vector is in this file.                                                

This is the file that contains the label where we set the irq vector.  We aren't using this right now,
but if you get into mappers you may have one that does use this interrupt.  You can kick off the irq
in the code if you want with the BRK command, but we will not be doing that in this game.


## File: nmi.asm                                                                                 
### Directory: vectors                                                                            

#### label used by the nmi vector is in this file.                                                 

NMI stands for Non-Maskable Interrupt.  The NMI is executed whenever the screen is in the middle
of a refresh and not drawing anything.  You can only interact with the PPU when it is not busy
drawing the game screen, so you have about 2200 cycles to work with inside the NMI to interact
with the PPU.  Around 500 of those cycles are used to move sprite data to the PPU in what is called
a DMA, which leaves you about 1700 cycles to modify the background.


## File: reset.asm                                                                          
### Directory: vectors                                                                      

#### label used by the reset vector is in this file.  This vector gets called when the game console powers on and when the player hits the reset button.

The reset vector gets called when the system powers up, and when the player hits the "Reset" button
on the game console.  Since the console has random data in it's memory when it powers up, you should
clear all data when you start up.


## File: starter.asm                                                                            

This is the primary game file.  It must include all other files you want to use.  This file also includes the game loop.                 


# SHAMELESS PLUG from Rick Battagline            

I make web games for a living, and if you want to help me out please play them when you're bored at work. (win, win)                                  

https://www.classicsolitaire.com                             

https://www.icardgames.com                                    

https://www.candymahjong.com                                  

https://www.embed.com                                         

I plan on making this and other tutorials and NES Game ROMS available in the near future at https://www.embed.com/nes                         
                                                  
