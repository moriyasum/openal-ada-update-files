# openal-ada-update-files
File modifications required for using Coreland OpenAL on Ubuntu.  
Modifications made to address installation errors when installing Coreland OpenAL on Ubuntu and to fix issues with Capture functionality.  
  
Confirmed versions:  
Ubuntu: 24.04.2 LTS, Gnat: 14.2.1, Gtkada:25.0.1  
PC: OMEN 17-ck2095cl, i9-13900HX, RTX-4080  
  
See more detail at: https://n7sd.com/ada1-2/openal-ada-1-1-1-coreland-with-gnat20202021-on-ubuntu-installation/  
  
There are 13 files to edit (x12) and create (x1).  
Files 1-9: To resolve build errors.  
Files 10-13: To fix issues with Capture functionality.  
  
```
1, EDIT 2 FILES  
Modify settings (current directory: ~/ada/AL1):    
  
File 1:  ./conf-cc  
change the first line    cc ——>  gcc  
==========  
  
File 2:  ./conf-ld  
change the first line    cc ——>  gcc  
==========  
  
  
2, CREATE 1 FILE  
  
File 3: ./conf-adaldflags  
Enter the top line only   -lopenal  
==========  
  
  
3, COMMENT OUT 6 FILES  
  
File 4: ./UNIT_TESTS/alc_001.adb (3 lines)  
4   — with OpenAL.Context.Error;  
12  —  package ALC_Error renames OpenAL.Context.Error;  
26  —  use type ALC_Error.Error_t;  
==========  
  
File 5: ./UNIT_TESTS/efx_001.adb (3 lines)  
1  — with OpenAL.Context.Error;  
8  —  package ALC_Error renames OpenAL.Context.Error;  
20  —  use type ALC_Error.Error_t;  
==========  

File 6: ./UNIT_TESTS/efx_002.adb (3 lines)  
1  — with OpenAL.Context.Error;  
8  —  package ALC_Error renames OpenAL.Context.Error;  
19  —  use type ALC_Error.Error_t;  
==========  

File 7: ./UNIT_TESTS/global_001.adb (3 lines)  
2 — with OpenAL.Context.Error;  
10 —  package ALC_Error renames OpenAL.Context.Error;  
20 —  use type ALC_Error.Error_t;  
==========  
  
File 8:   /UNIT_TESTS/init_004.adb (2 lines, not Error items)  
4   — with OpenAL.Types;  
19  —  use type OpenAL.Types.Frequency_t;  
==========  
  
File 9: ./openal-source.adb (1 line)  
5 — use type Types.Size_t;  
==========  
  
  
4, EDIT 4 FILES  (added 8/19/2025)  
  
These modifications need for Capturing audio.  
Line numbers refer to the original, unmodified source.
==========  
  
File 10: openal-context.ads  
20  type    Format_t         is (Mono_8, Stereo_8, Mono_16, Stereo_16, Unknown);  
21  subtype Request_Format_t is Format_t range Mono_8 .. Stereo_16;  
22  
--  Added 3 lines  
  function Is_Capture_Device (Device : Device_t) return Boolean;  
  function Get_Capture_Format (Device : Device_t) return Format_t;  
  function Is_Valid_Device (Device : Device_t) return Boolean;  
23  --  
24  -- API  
25  --  
  
==========
  
File 11: openal-context.adb
  
4  with System;  
5  with OpenAL.ALC_Thin;  use OpenAL.ALC_Thin;   --  Added 1 line  
6  package body OpenAL.Context is  
7    package C         renames Interfaces.C;  
8    package C_Strings renames Interfaces.C.Strings;  
9  
10    --  
11  -- Close_Device  
  
  
–  Delete 1 line  
108 --  use type ALC_Thin.Device_t;  
  
  
142    return List;  
143  end Get_Available_Playback_Devices;  
--  Added 5 lines  
  function Get_Capture_Format (Device : Device_t) return Format_t is  
  begin  
    return Device.Capture_Format;  
  end Get_Capture_Format;  
--  
145  function Get_Capture_Samples  
146    (Device : in Device_t) return Natural  
147  is  
  
  
308    return Boolean'Val (Value);  
309  end Get_Synchronous;  
  
--  Added 5 lines  
  function Is_Capture_Device (Device : Device_t) return Boolean is  
  begin  
    return Device.Capture;  
  end Is_Capture_Device;  
--  
311  --  
312  -- Is_Extension_Present  
313  --  
314  
315  function Is_Extension_Present  
316    (Device : in Device_t;  
317     Name   : in String) return Boolean  
  
  
  
308       Extension_Name => C_Name (C_Name'First)'Address));  
309  end Is_Extension_Present;  
  
--  Added 5 lines  
  function Is_Valid_Device (Device : Device_t) return Boolean is  
  begin  
    return Device.Device_Data /= ALC_Thin.Invalid_Device;  
  end Is_Valid_Device;  
--  
326  --  
327  -- Make_Context_Current  
328  --  
329  
330  function Make_Context_Current  
331    (Context : in Context_t) return Boolean is  
NOTE:  
Function names must be in alphabetical order, otherwise you’ll get a “not in alphabetical order” error.  
  
===========  
  
  
File 12: openal-context-capture.adb  
  
5  with System;  
6  use type OpenAL.ALC_Thin.Device_t;   --  Added 1 line  
7  package body OpenAL.Context.Capture is  
  
  
48  function Open_Default_Device  
    (Frequency   : in Types.Frequency_t;  
     Format      : in Request_Format_t;  
     Buffer_Size : in Buffer_Size_t) return Device_t  
  is  
    Device : Device_t;  
  begin  
    Device.Device_Data := ALC_Thin.Capture_Open_Device  
      (Name        => System.Null_Address,  
       Frequency   => Types.Unsigned_Integer_t (Frequency),  
       Format      => Map_Format (Format),  
59   Buffer_Size => Types.Size_t (Buffer_Size));  
--  Added 8 line  
    if Device.Device_Data /= ALC_Thin.Invalid_Device then  
        Device.Capture := True;  
        Device.Capture_Format := Format;  
    else  
        Device.Capture := False;  
        Device.Capture_Format := Unknown;  
    end if;  
--  
    return Device;  
  end Open_Default_Device;  
  
  
63  function Open_Device  
    (Name        : in String;  
     Frequency   : in Types.Frequency_t;  
     Format      : in Request_Format_t;  
     Buffer_Size : in Buffer_Size_t) return Device_t  
  is  
    C_Name : aliased C.char_array := C.To_C (Name);  
    Device : Device_t;  
  begin  
72 Device.Device_Data := ALC_Thin.Capture_Open_Device  
--  Deleted one line and added 3 lines  
--      (Name        => C_Name (C_Name'First)'Address,  –  Delete this line  
      (Name        =>  
         (if Name = "" then System.Null_Address  
          else C_Name (C_Name'First)'Address),  
       Frequency   => Types.Unsigned_Integer_t (Frequency),  
       Format      => Map_Format (Format),  
       Buffer_Size => Types.Size_t (Buffer_Size));  
--  Added 8 lines  
   if Device.Device_Data /= ALC_Thin.Invalid_Device then --  Added  
      Device.Capture := True;  
      Device.Capture_Format := Format;  
   else  
      Device.Capture := False;  
      Device.Capture_Format := Unknown;  
   end if;  
--  
    return Device;  
  end Open_Device;  
  
==========
  
  
File 13: openal_info.ads  
  
1  package OpenAL_Info is  
2    procedure Run;  
  procedure Init;   --  Added  
  procedure List_Playback_Devices;  
  procedure List_Capture_Devices;  
  procedure Defaults;  
--  procedure Open_Device;  This name may conflict with the regular Open_Device  
--  procedure Versions; This prototype is on the adb file  
  procedure Finish;  
3  end OpenAL_Info;  
  
==========
```
